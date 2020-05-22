//
//  pdl_malloc_zone.c
//  Poodle
//
//  Created by Poodle on 2020/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_malloc_zone.h"
#import <pthread/pthread.h>
#import <stdio.h>
#import <assert.h>
#import <string.h>
#import <os/lock.h>
#import <sys/mman.h>
#import <mach/mach.h>
#import "pdl_backtrace.h"
#import "pdl_dictionary.h"

static pdl_malloc_trace_policy _policy = pdl_malloc_trace_policy_live_allocations;

static malloc_zone_t *_zone = NULL;

#pragma mark - debug

pthread_key_t pdl_malloc_debug_key = 0;

#if 0
#define PDL_MALLOC_DEBUG_BEGIN \
{\
    void *value = pthread_getspecific(pdl_malloc_debug_key);\
    pthread_setspecific(pdl_malloc_debug_key, value + 1);\
}

#define PDL_MALLOC_DEBUG_END \
{\
    void *value = pthread_getspecific(pdl_malloc_debug_key);\
    pthread_setspecific(pdl_malloc_debug_key, value - 1);\
}

#define PDL_MALLOC_DEBUG_IS_DEBUGGING \
({\
void *value = pthread_getspecific(pdl_malloc_debug_key);\
value;\
})

#else

#define PDL_MALLOC_DEBUG_BEGIN
#define PDL_MALLOC_DEBUG_END
#define PDL_MALLOC_DEBUG_IS_DEBUGGING false

#endif

extern int backtrace(void **array, int size);
extern char **backtrace_symbols(void *const *array, int size);
extern void backtrace_symbols_fd(void *const *array, int size, int fd);

#if 0
__attribute__((naked))
static void pdl_malloc_log(const char *format, ...) {
#if defined(__arm__) || defined(__arm64__)
    __asm__ volatile ("b _malloc_printf");
#else
    __asm__ volatile ("jmp _malloc_printf");
#endif
}
#else
static void pdl_malloc_log(const char *format, ...) {
    ;
}
#endif

#define pdl_malloc_warning malloc_printf
#define pdl_malloc_error malloc_printf

#ifdef DEBUG
#define PDL_MALLOC_ASSERT_ENABLED_DEFAULT true
#else
#define PDL_MALLOC_ASSERT_ENABLED_DEFAULT false
#endif

static bool _pdl_malloc_assert_enabled = PDL_MALLOC_ASSERT_ENABLED_DEFAULT;
bool pdl_malloc_assert_enabled(void) {
    return _pdl_malloc_assert_enabled;
}

void pdl_malloc_assert_set_enabled(bool enabled) {
    _pdl_malloc_assert_enabled = enabled;
}

static void pdl_malloc_assert(bool e) {
    if (_pdl_malloc_assert_enabled) {
        assert(e);
    }
}

#pragma mark - pdl_zone

malloc_zone_t *pdl_malloc_zone(void) {
    static malloc_zone_t *_pdl_zone = NULL;
    if (!_pdl_zone) {
        malloc_zone_t *zone = malloc_create_zone(0, 0);
        malloc_set_zone_name(zone, "pdl_zone");
        _pdl_zone = zone;
    }
    return _pdl_zone;
}

void *pdl_malloc_zone_malloc(size_t size) {
    void *ptr = malloc_zone_malloc(pdl_malloc_zone(), size);
    return ptr;
}

void *pdl_malloc_zone_realloc(void *ptr, size_t size) {
    return malloc_zone_realloc(pdl_malloc_zone(), ptr, size);
}

void pdl_malloc_zone_free(void *ptr) {
    malloc_zone_free(pdl_malloc_zone(), ptr);
}

#pragma mark - zone enumerator

struct pdl_malloc_zone_enumerator_context {
    void *data;
    void(*function)(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops);
};

static void pdl_malloc_zone_recorder(task_t task, void *context, unsigned int type, vm_range_t *ranges, unsigned int count) {
    struct pdl_malloc_zone_enumerator_context *enumerator_context = context;
    bool stops = false;
    for (unsigned int i = 0; i < count; i++) {
        vm_range_t range = ranges[i];
        enumerator_context->function(enumerator_context->data, range, type, count, i, &stops);
        if (stops) {
            break;
        }
    }
}

static kern_return_t pdl_malloc_zone_reader(__unused task_t remote_task, vm_address_t remote_address, __unused vm_size_t size, void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

void pdl_malloc_zone_enumerate(malloc_zone_t *zone, void *data, void(*function)(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops)) {
    if (zone->introspect && zone->introspect->enumerator) {
        struct pdl_malloc_zone_enumerator_context context = {data, function};
        zone->introspect->enumerator(TASK_NULL, &context, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, pdl_malloc_zone_reader, pdl_malloc_zone_recorder);
    }
}

#pragma mark - storage

static pdl_dictionary_t pdl_malloc_map(void) {
    static pdl_dictionary_t _dictionary = NULL;
    if (!_dictionary) {
        _dictionary = pdl_dictionary_create_with_malloc_pointers(&pdl_malloc_zone_malloc, &pdl_malloc_zone_free);
    }
    return _dictionary;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

static pthread_mutex_t _mutex = PTHREAD_MUTEX_INITIALIZER;
static os_unfair_lock _unfair_lock = OS_UNFAIR_LOCK_INIT;

static void pdl_malloc_map_lock() {
    if (&os_unfair_lock_lock) {
        os_unfair_lock_lock(&_unfair_lock);
    } else {
        pthread_mutex_lock(&_mutex);
    }
}

static void pdl_malloc_map_unlock() {
    if (&os_unfair_lock_unlock) {
        os_unfair_lock_unlock(&_unfair_lock);
    } else {
        pthread_mutex_unlock(&_mutex);
    }
}

#pragma clang diagnostic pop

static void *pdl_malloc_map_get(void *key, bool lock) {
    if (lock) {
        pdl_malloc_map_lock();
    }

    pdl_dictionary_t map = pdl_malloc_map();
    void *value = NULL;
    void **object = pdl_dictionary_objectForKey(map, key);
    if (object) {
        value = *object;
    }
    if (lock) {
        pdl_malloc_map_unlock();
    }
    return value;
}

static void pdl_malloc_map_set(void *key, void *value) {
    pdl_malloc_map_lock();
    pdl_dictionary_t map = pdl_malloc_map();
    pdl_dictionary_setObjectForKey(map, value, key);
    pdl_malloc_map_unlock();
}

#pragma mark - trace info

#define PDL_MALLOC_INFO_MAGIC 0x4c4450

typedef struct pdl_malloc_info {
    unsigned long magic;
    unsigned long size;
    struct pdl_backtrace *bt;
    bool live;
} pdl_malloc_info, *pdl_malloc_info_t;

static void pdl_malloc_init(void *ptr, size_t size, bool records) {
    if (!ptr) {
        return;
    }

    pdl_malloc_info_t info = pdl_malloc_map_get(ptr, true);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);

        if (!records) {
            return;
        }

        if (info->live) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_malloc_error("pdl_malloc_error init %p is live\n", ptr);
            pdl_malloc_assert(info->live == false);
        }
        pdl_backtrace_destroy(info->bt);
    } else {
        info = pdl_malloc_zone_malloc(sizeof(pdl_malloc_info));
        info->magic = PDL_MALLOC_INFO_MAGIC;
        pdl_malloc_map_set(ptr, info);
    }

    info->size = size;
    info->bt = pdl_backtrace_create_with_malloc_pointers(&pdl_malloc_zone_malloc, &pdl_malloc_zone_free);
    char name[32];
    snprintf(name, sizeof(name), "malloc_%p", ptr);
    pdl_backtrace_set_name(info->bt, name);
    if (records) {
        pdl_backtrace_record(info->bt);
    }
    info->live = true;
    pdl_malloc_log("%s %p %d %d\n", "pdl_malloc_init", ptr, size, false);
}

static void pdl_malloc_destroy(void *ptr, size_t rsize, size_t size) {
    if (!ptr) {
        return;
    }

    pdl_malloc_info_t info = (pdl_malloc_info_t)pdl_malloc_map_get(ptr, true);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);
        if (info->live == false) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_malloc_error("pdl_malloc_error destroy %p is not live\n", ptr);
            pdl_malloc_assert(0);
        }
        info->live = false;
        if (size == 0) {
            memset(ptr, 0x55, rsize);
        }
        pdl_malloc_log("%s %p %d %d\n", "pdl_malloc_destroy", ptr, rsize, size, true);
        switch (_policy) {
            case pdl_malloc_trace_policy_live_allocations:
                pdl_backtrace_destroy(info->bt);
                pdl_malloc_zone_free(info);
                pdl_malloc_map_set(ptr, NULL);
                pdl_malloc_assert(pdl_malloc_map_get(ptr, true) == NULL);
                break;

            default:
                break;
        }
    } else {
        pdl_malloc_error("pdl_malloc_error destroy %p no info\n", ptr);
        pdl_malloc_assert(0);
    }
}

static void pdl_malloc_backtrace(void *ptr) {
    pdl_malloc_info_t info = pdl_malloc_map_get(ptr, true);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);
        pdl_backtrace_thread_show(info->bt, true);
    }
}

#pragma mark - trace functions

static void *(*pdl_trace_malloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_trace_malloc(malloc_zone_t *zone, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_trace_malloc_og(zone, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_trace_calloc_og)(malloc_zone_t *zone, size_t num_items, size_t size) = NULL;
static void *pdl_trace_calloc(malloc_zone_t *zone, size_t num_items, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_trace_calloc_og(zone, num_items, size);
    pdl_malloc_init(ptr, num_items * size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_trace_valloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_trace_valloc(malloc_zone_t *zone, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_trace_valloc_og(zone, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_trace_free_og)(malloc_zone_t *zone, void *ptr) = NULL;
static void pdl_trace_free(malloc_zone_t *zone, void *ptr) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t size = malloc_size(ptr);
    if (ptr && size == 0) {
        pdl_malloc_backtrace(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, size, 0);
    pdl_trace_free_og(zone, ptr);
    PDL_MALLOC_DEBUG_END;
}

static void *(*pdl_trace_realloc_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void *pdl_trace_realloc(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_backtrace(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, _size, size);
    void *p = pdl_trace_realloc_og(zone, ptr, size);
    pdl_malloc_init(p, size, true);
    PDL_MALLOC_DEBUG_END;
    return p;
}

static unsigned int (*pdl_trace_batch_malloc_og)(malloc_zone_t *zone, size_t size, void **results, unsigned num_requested) = NULL;
static unsigned int pdl_trace_batch_malloc(malloc_zone_t *zone, size_t size, void **results, unsigned num_requested) {
    PDL_MALLOC_DEBUG_BEGIN;
    unsigned int ret = pdl_trace_batch_malloc_og(zone, size, results, num_requested);
    for (unsigned int i = 0; i < ret; i++) {
        void *ptr = results[i];
        pdl_malloc_init(ptr, size, true);
    }
    PDL_MALLOC_DEBUG_END;
    return ret;
}

static void (*pdl_trace_batch_free_og)(malloc_zone_t *zone, void **to_be_freed, unsigned int num_to_be_freed) = NULL;
static void pdl_trace_batch_free(malloc_zone_t *zone, void **to_be_freed, unsigned int num_to_be_freed) {
    PDL_MALLOC_DEBUG_BEGIN;
    for (unsigned int i = 0; i < num_to_be_freed; i++) {
        void *ptr = to_be_freed[i];
        size_t size = malloc_size(ptr);
        if (ptr && size == 0) {
            pdl_malloc_backtrace(ptr);
            pdl_malloc_assert(0);
        }
        pdl_malloc_destroy(ptr, size, 0);
    }
    pdl_trace_batch_free_og(zone, to_be_freed, num_to_be_freed);
    PDL_MALLOC_DEBUG_END;
}

static void *(*(pdl_trace_memalign_og))(malloc_zone_t *zone, size_t alignment, size_t size) = NULL;
static void *pdl_trace_memalign(malloc_zone_t *zone, size_t alignment, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_trace_memalign_og(zone, alignment, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_trace_free_definite_size_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void pdl_trace_free_definite_size(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_backtrace(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, _size, 0);
    pdl_trace_free_definite_size_og(zone, ptr, size);
    PDL_MALLOC_DEBUG_END;
}

static boolean_t (*pdl_trace_claimed_address_og)(malloc_zone_t *zone, void *ptr) = NULL;
static boolean_t pdl_trace_claimed_address(malloc_zone_t *zone, void *ptr) {
    boolean_t ret = pdl_trace_claimed_address_og(zone, ptr);
    pdl_malloc_log("%s %p %d\n", "pdl_trace_claimed_address", ptr);
    return ret;
}

#pragma mark - trace

static void pdl_malloc_zone_add_existent(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = (void *)(uintptr_t)range.address;
    malloc_zone_t *zone = malloc_zone_from_ptr(ptr);
    if (zone == data) {
        size_t size = range.size;
        pdl_malloc_init(ptr, size, false);
    }
    PDL_MALLOC_DEBUG_END;
}

static void pdl_trace_zone(malloc_zone_t *zone) {
    bool protects = (((vm_size_t)zone) & vm_page_mask) == 0;
    if (protects) {
        pdl_malloc_assert(mprotect(zone, sizeof(malloc_zone_t), PROT_READ | PROT_WRITE) == 0);
    }

    pdl_trace_malloc_og = zone->malloc;
    zone->malloc = &pdl_trace_malloc;
    pdl_trace_calloc_og = zone->calloc;
    zone->calloc = &pdl_trace_calloc;
    pdl_trace_valloc_og = zone->valloc;
    zone->valloc = &pdl_trace_valloc;
    pdl_trace_free_og = zone->free;
    zone->free = &pdl_trace_free;
    pdl_trace_realloc_og = zone->realloc;
    zone->realloc = &pdl_trace_realloc;

    pdl_trace_batch_malloc_og = zone->batch_malloc;
    zone->batch_malloc = &pdl_trace_batch_malloc;
    pdl_trace_batch_free_og = zone->batch_free;
    zone->batch_free = &pdl_trace_batch_free;

    pdl_trace_memalign_og = zone->memalign;
    zone->memalign = &pdl_trace_memalign;
    pdl_trace_free_definite_size_og = zone->free_definite_size;
    zone->free_definite_size = &pdl_trace_free_definite_size;

    pdl_trace_claimed_address_og = zone->claimed_address;
    zone->claimed_address = &pdl_trace_claimed_address;

    if (protects) {
        pdl_malloc_assert(mprotect(zone, sizeof(malloc_zone_t), PROT_READ) == 0);
    }
}

#pragma mark - logger

extern void (*__syscall_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

extern void (*malloc_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

static void pdl_syscall_logger(uint32_t type, malloc_zone_t *zone, void *ptr, size_t size, void *result, uint32_t num_hot_frames_to_skip) {
//    pdl_malloc_log("%s %p %p %p %p %p %d\n", "pdl_syscall_logger", type, zone, ptr, size, result, num_hot_frames_to_skip);
}

static void pdl_malloc_logger(uint32_t type, malloc_zone_t *zone, void *ptr, size_t size, void *result, uint32_t num_hot_frames_to_skip) {
//    pdl_malloc_log("%s %p %p %p %p %p %d\n", "pdl_malloc_logger", type, zone, ptr, size, result, num_hot_frames_to_skip);
}

#pragma mark - init

static bool pdl_malloc_zone_initialized = false;

extern malloc_zone_t **malloc_zones;
extern int32_t malloc_num_zones;

extern bool pdl_malloc_enable_trace(pdl_malloc_trace_policy policy) {
    if (pdl_malloc_zone_initialized) {
        return true;
    }

    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, NULL, &zones, &zoneCount);
    if (result) {
        return false;
    }

    _policy = policy;

    pthread_key_create(&pdl_malloc_debug_key, NULL);

    pdl_malloc_map();

#ifdef DEBUG
    __syscall_logger = (typeof(__syscall_logger))&pdl_syscall_logger;
    malloc_logger = (typeof(malloc_logger))&pdl_malloc_logger;
#endif

    switch (policy) {
        case pdl_malloc_trace_policy_live_allocations: {
            _zone = malloc_default_zone();

            pdl_malloc_log("pdl_malloc_zone_enumerate begin\n");
            for (unsigned int i = 0; i < zoneCount; i++) {
                malloc_zone_t *zone = (malloc_zone_t *)zones[i];
                pdl_malloc_zone_enumerate(zone, _zone, &pdl_malloc_zone_add_existent);
            }
            pdl_malloc_log("pdl_malloc_zone_enumerate end\n");

        } break;
        case pdl_malloc_trace_policy_custom_zone: {
            _zone = malloc_create_zone(0, 0);
            malloc_set_zone_name(_zone, "pdl_custom_zone");
        } break;

        default:
            return false;
            break;
    }

    pdl_trace_zone(_zone);

    pdl_malloc_zone_initialized = true;

    pdl_malloc_check_pointer(NULL);

    return true;
}

void pdl_malloc_check_pointer(void *pointer) {
    if (!pointer) {
        return;
    }

    if (!pdl_malloc_zone_initialized) {
        return;
    }

    malloc_zone_t *zone = malloc_zone_from_ptr(pointer);
    if (zone) {
        return;
    }

    pdl_malloc_info_t info = pdl_malloc_map_get(pointer, true);
    if (info) {
        if (info->magic == PDL_MALLOC_INFO_MAGIC && info->bt) {
            if (info->live == false) {
                pdl_backtrace_thread_show(info->bt, true);
            }
        }
    }
}

void pdl_malloc_zone_show_backtrace(void *pointer) {
    if (!pointer) {
        return;
    }

    if (!pdl_malloc_zone_initialized) {
        return;
    }

    malloc_zone_t *zone = malloc_zone_from_ptr(pointer);
    if (!zone) {
        return;
    }

    pdl_malloc_map_lock();
    pdl_malloc_info_t info = pdl_malloc_map_get(pointer, false);
    if (info) {
        if (info->magic == PDL_MALLOC_INFO_MAGIC && info->bt) {
            pdl_backtrace_thread_show(info->bt, true);
        }
    }
    pdl_malloc_map_unlock();
}

void pdl_malloc_zone_hide_backtrace(void *pointer) {
    if (!pointer) {
        return;
    }

    if (!pdl_malloc_zone_initialized) {
        return;
    }

    malloc_zone_t *zone = malloc_zone_from_ptr(pointer);
    if (!zone) {
        return;
    }

    pdl_malloc_map_lock();
    pdl_malloc_info_t info = pdl_malloc_map_get(pointer, false);
    if (info) {
        if (info->magic == PDL_MALLOC_INFO_MAGIC && info->bt) {
            pdl_backtrace_thread_hide(info->bt);
        }
    }
    pdl_malloc_map_unlock();
}
