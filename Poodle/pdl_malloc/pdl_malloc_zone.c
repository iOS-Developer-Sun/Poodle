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
#import "pdl_backtrace.h"
#import "pdl_dictionary.h"

#pragma mark - debug

pthread_key_t pdl_malloc_debug_key = 0;

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

#pragma mark - zone

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

static pthread_mutex_t * pdl_malloc_map_lock(void) {
    static pthread_mutex_t _lock = PTHREAD_MUTEX_INITIALIZER;
    return &_lock;
}

static void *pdl_malloc_map_get(void *key) {
    pthread_mutex_t *lock = pdl_malloc_map_lock();
    pthread_mutex_lock(lock);
    void *value = NULL;
    void **object = pdl_dictionary_objectForKey(pdl_malloc_map(), key);
    if (object) {
        value = *object;
    }
    pthread_mutex_unlock(lock);
    return value;
}

static void pdl_malloc_map_set(void *key, void *value) {
    pthread_mutex_t *lock = pdl_malloc_map_lock();
    pthread_mutex_lock(lock);
    pdl_dictionary_setObjectForKey(pdl_malloc_map(), value, key);
    pthread_mutex_unlock(lock);
}

#pragma mark - trace

#define PDL_MALLOC_INFO_MAGIC 0x4c4450

typedef struct pdl_malloc_info {
    unsigned long magic;
    unsigned long size;
    pdl_backtrace_t bt;
    bool free;
} pdl_malloc_info, *pdl_malloc_info_t;

static void pdl_malloc_init(void *ptr, size_t size, bool records) {
    if (!ptr) {
        return;
    }

    pdl_malloc_info_t info = pdl_malloc_map_get(ptr);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);

        if (!records) {
            return;
        }

        if (info->free == false) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_malloc_error("error %p\n", ptr);
            pdl_malloc_assert(info->free);
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
    info->free = false;
    pdl_malloc_log("%s %p %d %d\n", "pdl_malloc_init", ptr, size, false);
}

static void pdl_malloc_destroy(void *ptr, size_t size) {
    if (!ptr) {
        return;
    }

    pdl_malloc_info_t info = (pdl_malloc_info_t)pdl_malloc_map_get(ptr);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);
        if (info->free) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_malloc_error("error %p\n", ptr);
            pdl_malloc_assert(0);
        }
        info->free = true;
        pdl_malloc_assert(info->size <= size);
//        memset(ptr, 0x55, info->size);
        pdl_malloc_log("%s %p %d %d\n", "pdl_malloc_destroy", ptr, size, true);
    } else {
        pdl_malloc_error("error %p\n", ptr);
        pdl_malloc_assert(0);
    }
}

static void pdl_malloc_track(void *ptr) {
    pdl_malloc_info_t info = pdl_malloc_map_get(ptr);
    if (info) {
        pdl_malloc_assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        pdl_malloc_assert(info->bt);
        pdl_backtrace_thread_show(info->bt, true);
    }
}

#pragma mark - malloc

static void pdl_dz_init_existent(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = (void *)(uintptr_t)range.address;
    size_t size = range.size;
    pdl_malloc_init(ptr, size, false);
    malloc_zone_t *zone = malloc_zone_from_ptr(ptr);
    pdl_malloc_assert(zone == malloc_default_zone());
    PDL_MALLOC_DEBUG_END;
}

static void pdl_malloc_zone_existent(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    void *ptr = (void *)(uintptr_t)range.address;
    size_t size = range.size;
    if (malloc_zone_from_ptr(ptr) != data) {
        if (malloc_zone_from_ptr(ptr) == malloc_default_zone()) {
            pdl_malloc_init(ptr, size, false);
        }
    }
}

static void *(*pdl_dz_malloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_dz_malloc(malloc_zone_t *zone, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_malloc_og(zone, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_dz_calloc_og)(malloc_zone_t *zone, size_t num_items, size_t size) = NULL;
static void *pdl_dz_calloc(malloc_zone_t *zone, size_t num_items, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_calloc_og(zone, num_items, size);
    pdl_malloc_init(ptr, num_items * size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_dz_valloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_dz_valloc(malloc_zone_t *zone, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_valloc_og(zone, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_dz_free_og)(malloc_zone_t *zone, void *ptr) = NULL;
static void pdl_dz_free(malloc_zone_t *zone, void *ptr) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t size = malloc_size(ptr);
    if (ptr && size == 0) {
        pdl_malloc_track(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, size);
    pdl_dz_free_og(zone, ptr);
    PDL_MALLOC_DEBUG_END;
}

static void *(*pdl_dz_realloc_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void *pdl_dz_realloc(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_track(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, _size);
    void *p = pdl_dz_realloc_og(zone, ptr, size);
    pdl_malloc_init(p, size, true);
    PDL_MALLOC_DEBUG_END;
    return p;
}

static unsigned int (*pdl_dz_batch_malloc_og)(malloc_zone_t *zone, size_t size, void **results, unsigned num_requested) = NULL;
static unsigned int pdl_dz_batch_malloc(malloc_zone_t *zone, size_t size, void **results, unsigned num_requested) {
    return pdl_dz_batch_malloc_og(zone, size, results, num_requested);
}

static void (*pdl_dz_batch_free_og)(malloc_zone_t *zone, void **to_be_freed, unsigned num_to_be_freed) = NULL;
static void pdl_dz_batch_free(malloc_zone_t *zone, void **to_be_freed, unsigned num_to_be_freed) {
    pdl_dz_batch_free_og(zone, to_be_freed, num_to_be_freed);
}

static void *(*(pdl_dz_memalign_og))(malloc_zone_t *zone, size_t alignment, size_t size) = NULL;
static void *pdl_dz_memalign(malloc_zone_t *zone, size_t alignment, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_memalign_og(zone, alignment, size);
    pdl_malloc_init(ptr, size, true);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_dz_free_definite_size_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void pdl_dz_free_definite_size(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_track(ptr);
        pdl_malloc_assert(0);
    }

    pdl_malloc_destroy(ptr, _size);
    pdl_dz_free_definite_size_og(zone, ptr, size);
    PDL_MALLOC_DEBUG_END;
}

static boolean_t (*pdl_dz_claimed_address_og)(malloc_zone_t *zone, void *ptr) = NULL;
static boolean_t pdl_dz_claimed_address(malloc_zone_t *zone, void *ptr) {
    boolean_t ret = pdl_dz_claimed_address_og(zone, ptr);
    pdl_malloc_log("%s %p %d\n", "pdl_dz_claimed_address", ptr);
    return ret;
}

#pragma mark - logger

extern void (*__syscall_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

extern void (*malloc_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

static void pdl_syscall_logger(uint32_t type, malloc_zone_t *zone, void *ptr, size_t size, void *result, uint32_t num_hot_frames_to_skip) {
//        pdl_malloc_log("%s %p %p %p %p %p %d\n", "pdl_syscall_logger", type, zone, ptr, size, result, num_hot_frames_to_skip);
}

static void pdl_malloc_logger(uint32_t type, malloc_zone_t *zone, void *ptr, size_t size, void *result, uint32_t num_hot_frames_to_skip) {
    if (PDL_MALLOC_DEBUG_IS_DEBUGGING) {
        return;
    }
    if (zone == malloc_default_zone()) {
        return;
    }

    pdl_malloc_log("%s %p %p %p %p %p %d\n", "pdl_malloc_logger", type, zone, ptr, size, result, num_hot_frames_to_skip);
}

#pragma mark - init

static bool pdl_malloc_zone_initialized = false;

bool pdl_malloc_trace(void) {
    if (pdl_malloc_zone_initialized) {
        return true;
    }

    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, NULL, &zones, &zoneCount);
    if (result) {
        return false;
    }

    pthread_key_create(&pdl_malloc_debug_key, NULL);

    pdl_malloc_map();

    __syscall_logger = (typeof(__syscall_logger))&pdl_syscall_logger;
    malloc_logger = (typeof(malloc_logger))&pdl_malloc_logger;

    malloc_zone_t *dz = malloc_default_zone();

    pdl_malloc_log("pdl_malloc_zone_enumerate begin\n");
    pdl_malloc_zone_enumerate(dz, NULL, &pdl_dz_init_existent);
    pdl_malloc_log("pdl_malloc_zone_enumerate end\n");

    for (unsigned int i = 0; i < zoneCount; i++) {
        malloc_zone_t *zone = (malloc_zone_t *)zones[i];
        if (zone == dz) {
            continue;
        }
        if (zone == pdl_malloc_zone()) {
            continue;
        }
        pdl_malloc_zone_enumerate(zone, zone, &pdl_malloc_zone_existent);
    }

    pdl_dz_malloc_og = dz->malloc;
    dz->malloc = &pdl_dz_malloc;
    pdl_dz_calloc_og = dz->calloc;
    dz->calloc = &pdl_dz_calloc;
    pdl_dz_valloc_og = dz->valloc;
    dz->valloc = &pdl_dz_valloc;
    pdl_dz_free_og = dz->free;
    dz->free = &pdl_dz_free;
    pdl_dz_realloc_og = dz->realloc;
    dz->realloc = &pdl_dz_realloc;

    pdl_dz_batch_malloc_og = dz->batch_malloc;
    dz->batch_malloc = &pdl_dz_batch_malloc;
    pdl_dz_batch_free_og = dz->batch_free;
    dz->batch_free = &pdl_dz_batch_free;

    pdl_dz_memalign_og = dz->memalign;
    dz->memalign = &pdl_dz_memalign;
    pdl_dz_free_definite_size_og = dz->free_definite_size;
    dz->free_definite_size = &pdl_dz_free_definite_size;

    pdl_dz_claimed_address_og = dz->claimed_address;
    dz->claimed_address = &pdl_dz_claimed_address;

    pdl_malloc_zone_initialized = true;
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

    pdl_malloc_info_t info = pdl_malloc_map_get(pointer);
    if (info) {
        if (info->magic == PDL_MALLOC_INFO_MAGIC && info->bt) {
            if (info->free) {
                pdl_backtrace_thread_show(info->bt, true);
            }
        }
    }
}
