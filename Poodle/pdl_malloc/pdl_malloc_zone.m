//
//  pdl_malloc_zone.m
//  Poodle
//
//  Created by Poodle on 2020/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "pdl_malloc_zone.h"
#import "pdl_backtrace.h"
#import <pthread/pthread.h>

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

static FILE *_pdl_file = NULL;
static void pdl_malloc_file_log(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(_pdl_file, format, args);
    va_end(args);
    fflush(_pdl_file);
}

#if 1
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
#if 0
    va_list args;
    va_start(args, format);
    vfprintf(_pdl_file, format, args);
    va_end(args);
    fflush(_pdl_file);
#endif
}
#endif

#pragma mark - pdl_zone

malloc_zone_t *pdl_malloc_zone(void) {
    static malloc_zone_t *_pdl_zone = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        malloc_zone_t *zone = malloc_create_zone(0, 0);
        malloc_set_zone_name(zone, "pdl_zone");
//        malloc_zone_register(zone);
        _pdl_zone = zone;
    });
    return _pdl_zone;
}

static void *pdl_malloc_zone_malloc(size_t size) {
    void *ptr = malloc_zone_malloc(pdl_malloc_zone(), size);
    return ptr;
}

static void *pdl_malloc_zone_realloc(void *ptr, size_t size) {
    return malloc_zone_realloc(pdl_malloc_zone(), ptr, size);
}

static void pdl_malloc_zone_free(void *ptr) {
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

void *pdlAllocatorAllocateCallBack(CFIndex allocSize, CFOptionFlags hint, void *info) {
    return pdl_malloc_zone_malloc(allocSize);
}

void *pdlAllocatorReallocateCallBack(void *ptr, CFIndex newsize, CFOptionFlags hint, void *info) {
    return pdl_malloc_zone_realloc(ptr, newsize);
}

void pdlCFAllocatorDeallocateCallBack(void *ptr, void *info) {
    pdl_malloc_zone_free(ptr);
}

static CFMutableDictionaryRef pdl_malloc_map(void) {
    static CFMutableDictionaryRef _dictionary = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFAllocatorContext context = {
            0, // version
            NULL, // info
            NULL, // retain
            NULL, // release
            NULL, // copyDescription
            &pdlAllocatorAllocateCallBack, // allocate
            &pdlAllocatorReallocateCallBack, // reallocate
            *pdlCFAllocatorDeallocateCallBack, // deallocate
            NULL, // preferredSize
        };
        CFAllocatorRef allocator = CFAllocatorCreate(CFAllocatorGetDefault(), &context);
        _dictionary = CFDictionaryCreateMutable(allocator, 0, NULL, NULL);
    });
    return _dictionary;
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

    CFMutableDictionaryRef map = pdl_malloc_map();
    pdl_malloc_info_t info = (pdl_malloc_info_t)CFDictionaryGetValue(map, ptr);
    if (info) {
        assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        assert(info->bt);

        if (!records) {
            return;
        }

        if (info->free == false) {
            pdl_backtrace_thread_show(info->bt, true);
            pdl_malloc_log("error %p\n", ptr);
            assert(info->free);
        }
        pdl_backtrace_destroy(info->bt);
    } else {
        info = pdl_malloc_zone_malloc(sizeof(pdl_malloc_info));
        info->magic = PDL_MALLOC_INFO_MAGIC;
        CFDictionarySetValue(map, ptr, info);
    }

    info->size = size;
    info->bt = pdl_backtrace_create_with_malloc_pointers(&pdl_malloc_zone_malloc, &pdl_malloc_zone_free);
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

    CFMutableDictionaryRef map = pdl_malloc_map();
    pdl_malloc_info_t info = (pdl_malloc_info_t)CFDictionaryGetValue(map, ptr);
    if (info) {
        assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        assert(info->bt);
        if (info->free) {
            pdl_backtrace_thread_show(info->bt, true);
            assert(info->free == false);
        }
        info->free = true;
//        memset(ptr, 0x55, info->size);
        pdl_malloc_log("%s %p %d %d\n", "pdl_malloc_destroy", ptr, size, true);
    } else {
        pdl_malloc_log("warning %p\n", ptr);
        pdl_malloc_log("%s %p %d !\n", "pdl_malloc_destroy", ptr, size);
    }
}

static void pdl_malloc_track(void *ptr) {
    CFMutableDictionaryRef map = pdl_malloc_map();
    pdl_malloc_info_t info = (pdl_malloc_info_t)CFDictionaryGetValue(map, ptr);
    if (info) {
        assert(info->magic == PDL_MALLOC_INFO_MAGIC);
        assert(info->bt);
        pdl_backtrace_thread_show(info->bt, true);
    }
}

#pragma mark - malloc

static void pdl_dz_init_existent(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = (void *)(uintptr_t)range.address;
    size_t size = range.size;
    pdl_malloc_log("%s %p %d %d %d %d\n", "pdl_dz_init_existent", ptr, size, type, count, index);
    pdl_malloc_init(ptr, size, false);
    assert(malloc_zone_from_ptr(ptr) == malloc_default_zone());
    PDL_MALLOC_DEBUG_END;
}

static void pdl_malloc_zone_existent(void *data, vm_range_t range, unsigned int type, unsigned int count, unsigned int index, bool *stops) {
    void *ptr = (void *)(uintptr_t)range.address;
    size_t size = range.size;
    pdl_malloc_log("%s %p %d %d %d %d\n", "pdl_malloc_zone_existent", ptr, size, type, count, index);
    if (malloc_zone_from_ptr(ptr) != data) {
        pdl_malloc_log("warning %p\n", ptr);
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
    pdl_malloc_log("%s %p %d\n", "malloc", ptr, size);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_dz_calloc_og)(malloc_zone_t *zone, size_t num_items, size_t size) = NULL;
static void *pdl_dz_calloc(malloc_zone_t *zone, size_t num_items, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_calloc_og(zone, num_items, size);
    pdl_malloc_init(ptr, num_items * size, true);
    pdl_malloc_log("%s %p %d %d\n", "calloc", ptr, num_items, size);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void *(*pdl_dz_valloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_dz_valloc(malloc_zone_t *zone, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    void *ptr = pdl_dz_valloc_og(zone, size);
    pdl_malloc_init(ptr, size, true);
    pdl_malloc_log("%s %p %d\n", "valloc", ptr, size);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_dz_free_og)(malloc_zone_t *zone, void *ptr) = NULL;
static void pdl_dz_free(malloc_zone_t *zone, void *ptr) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t size = malloc_size(ptr);
    if (ptr && size == 0) {
        pdl_malloc_track(ptr);
        assert(0);
    }

    pdl_malloc_destroy(ptr, size);
    pdl_malloc_log("%s %p\n", "free", ptr);
    pdl_dz_free_og(zone, ptr);
    PDL_MALLOC_DEBUG_END;
}

static void *(*pdl_dz_realloc_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void *pdl_dz_realloc(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_track(ptr);
        assert(0);
    }

    pdl_malloc_destroy(ptr, _size);
    void *p = pdl_dz_realloc_og(zone, ptr, size);
    pdl_malloc_init(p, size, true);
    pdl_malloc_log("%s %p %d %p\n", "realloc", ptr, size, p);
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
    pdl_malloc_log("%s %p %d\n", "memalign", ptr, size);
    PDL_MALLOC_DEBUG_END;
    return ptr;
}

static void (*pdl_dz_free_definite_size_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void pdl_dz_free_definite_size(malloc_zone_t *zone, void *ptr, size_t size) {
    PDL_MALLOC_DEBUG_BEGIN;
    size_t _size = malloc_size(ptr);
    if (ptr && _size == 0) {
        pdl_malloc_track(ptr);
        assert(0);
    }

    pdl_malloc_destroy(ptr, size);
    pdl_malloc_log("%s %p %d\n", "free_definite_size", ptr, size);
    pdl_dz_free_definite_size_og(zone, ptr, size);
    PDL_MALLOC_DEBUG_END;
}

static boolean_t (*pdl_dz_claimed_address_og)(malloc_zone_t *zone, void *ptr) = NULL;
static boolean_t pdl_dz_claimed_address(malloc_zone_t *zone, void *ptr) {
    boolean_t ret = pdl_dz_claimed_address_og(zone, ptr);
    pdl_malloc_log("%s %p %d\n", "claimed_address", ptr);
    return ret;
}

#pragma mark - logger

extern void (*__syscall_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

extern void (*malloc_logger)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

static void pdl_syscall_logger(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip) {
//    pdl_malloc_log("%s %d %p %p %p %p %d\n", "pdl_syscall_logger", type, arg1, arg2, arg3, result, num_hot_frames_to_skip);
}

static void pdl_malloc_logger(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip) {
    if (PDL_MALLOC_DEBUG_IS_DEBUGGING) {
        return;
    }
    pdl_malloc_log("%s %d %p %p %p %p %d\n", "pdl_malloc_logger", type, arg1, arg2, arg3, result, num_hot_frames_to_skip);
}

#pragma mark - init

__attribute__((constructor))
void pdl_malloc_trace(void) {
//    malloc_zone_t _zone = {0};
//    malloc_zone_register(&_zone);
//    malloc_zone_t *default_zone = malloc_default_zone();
//    malloc_zone_unregister(default_zone);
//    malloc_zone_register(default_zone);

//    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"m.log"];
//    _pdl_file = fopen(path.UTF8String, "a+");
//    _pdl_file = freopen(path.UTF8String, "a+", stdout);

    pthread_key_create(&pdl_malloc_debug_key, NULL);

    pdl_malloc_map();

    __syscall_logger = &pdl_syscall_logger;
    malloc_logger = &pdl_malloc_logger;

    malloc_zone_t *dz = malloc_default_zone();

    pdl_malloc_log("pdl_malloc_zone_enumerate begin\n");
    pdl_malloc_zone_enumerate(dz, NULL, &pdl_dz_init_existent);
    pdl_malloc_log("pdl_malloc_zone_enumerate end\n");

    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, NULL, &zones, &zoneCount);
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
}

#if 0

void __usercall UseJeMallocMethod(unsigned __int8 *a1@<X8>)
{
    unsigned int v1; // off
    __int128 v2; // q1
    malloc_zone_t *v3; // x0
    unsigned int count; // [xsp+4h] [xbp-1Ch]
    vm_address_t *addresses; // [xsp+8h] [xbp-18h]

    v1 = __ldar(a1);
    if ( !((unsigned __int8)a1 & 1) )
    {
        pthread_mutex_lock((pthread_mutex_t *)&replaceSystemMallocLock);
        if ( !(sMallocWasReplaced & 1) )
        {
            __stlr(0, (unsigned __int8 *)&sMallocWasReplaced);
            unk_1001C8F48 = 0u;
            unk_1001C8F58 = 0u;
            unk_1001C8F28 = 0u;
            unk_1001C8F38 = 0u;
            UseJeMallocMethod(void)::sanitizer_zone_introspection = `anonymous namespace'::mi_enumerator;
            unk_1001C8EF0 = `anonymous namespace'::mi_good_size;
            unk_1001C8EF8 = `anonymous namespace'::mi_check;
            unk_1001C8F00 = `anonymous namespace'::mi_print;
            qword_1001C8F08 = (__int64)`anonymous namespace'::mi_log;
            *(_QWORD *)&v2 = `anonymous namespace'::mi_force_lock;
            *((_QWORD *)&v2 + 1) = `anonymous namespace'::mi_force_unlock;
            *(_OWORD *)algn_1001C8F10 = v2;
            qword_1001C8F20 = (__int64)`anonymous namespace'::mi_statistics;
            *(_OWORD *)&qword_1001C8FC8 = 0u;
            internal_sanitizer_zone = 0u;
            dword_1001C8FD0 = 6;
            unk_1001C8FA8 = `anonymous namespace'::mz_destroy;
            unk_1001C8FB0 = "NiuTcMalloc";
            unk_1001C8F78 = `anonymous namespace'::mz_size;
            unk_1001C8F80 = `anonymous namespace'::mz_malloc;
            unk_1001C8F88 = `anonymous namespace'::mz_calloc;
            unk_1001C8F90 = `anonymous namespace'::mz_valloc;
            unk_1001C8F98 = `anonymous namespace'::mz_free;
            unk_1001C8FA0 = `anonymous namespace'::mz_realloc;
            unk_1001C8FB8 = niu_default_zone_batch_malloc;
            unk_1001C8FC0 = niu_default_zone_batch_free;
            xmmword_1001C8FE8 = 0u;
            unk_1001C8FD8 = `anonymous namespace'::mz_memalign;
            unk_1001C8FE0 = niu_zone_free_definite_size;
            qword_1001C8FC8 = (__int64)&UseJeMallocMethod(void)::sanitizer_zone_introspection;
            if ( &_malloc_default_purgeable_zone )
                malloc_default_purgeable_zone();
            malloc_zone_register((malloc_zone_t *)&internal_sanitizer_zone);
            addresses = 0LL;
            count = 0;
            if ( malloc_get_all_zones(0, 0LL, &addresses, &count) )
            {
                count = 0;
            }
            else if ( count )
            {
                v3 = (malloc_zone_t *)*addresses;
                goto LABEL_10;
            }
            v3 = malloc_default_zone();
        LABEL_10:
            default_zone = (__int64)v3;
            malloc_zone_unregister(v3);
            malloc_zone_register((malloc_zone_t *)default_zone);
            pthread_mutex_unlock((pthread_mutex_t *)&replaceSystemMallocLock);
            return;
        }
    }
}

#endif
