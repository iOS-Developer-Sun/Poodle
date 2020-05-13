//
//  pdl_malloc.m
//  Poodle
//
//  Created by Poodle on 2019/5/15.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_malloc.h"
#include <malloc/malloc.h>

struct pdl_malloc_recorder_context {
    void *address;
    size_t size;
    void *header;
};

static void recorder(task_t task, void *context, unsigned type, vm_range_t *ranges, unsigned rangeCount) {
    struct pdl_malloc_recorder_context *recorder_context = context;
    for (unsigned int i = 0; i < rangeCount; i++) {
        vm_range_t range = ranges[i];
        vm_address_t address = range.address;
        vm_size_t size = range.size;

        vm_address_t addr = (vm_address_t)recorder_context->address;
        if ((addr >= address) && (addr < address + size)) {
            recorder_context->header = (void *)address;
            recorder_context->size = size;
        }
    }
}

static kern_return_t reader(__unused task_t remote_task, vm_address_t remote_address, __unused vm_size_t size, void **local_memory) {
    *local_memory = (void *)remote_address;
    return KERN_SUCCESS;
}

bool pdl_malloc_check(void *address, size_t *size, void **header) {
    vm_address_t *zones = NULL;
    unsigned int zoneCount = 0;
    kern_return_t result = malloc_get_all_zones(TASK_NULL, NULL, &zones, &zoneCount);
    if (result != KERN_SUCCESS) {
        return false;
    }

    size_t malloc_size = 0;
    void *malloc_header = NULL;
    for (unsigned int i = 0; i < zoneCount; i++) {
        malloc_zone_t *zone = (malloc_zone_t *)zones[i];
        if (zone->size) {
            malloc_size = zone->size(zone, address);
            if (malloc_size > 0) {
                malloc_header = address;
                break;
            }
        }

        if (zone->introspect && zone->introspect->enumerator) {
            struct pdl_malloc_recorder_context context = {address, 0, NULL};
            zone->introspect->enumerator(TASK_NULL, &context, MALLOC_PTR_IN_USE_RANGE_TYPE, (vm_address_t)zone, reader, recorder);
            if (context.size > 0) {
                malloc_size = context.size;
                malloc_header = context.header;
                break;
            }
        }
    }

    if (size) {
        *size = malloc_size;
    }
    if (header) {
        *header = malloc_header;
    }

    return true;
}

#if 0

static NSString *_pdl_file_path_string = nil;
static const char *_pdl_file_path = NULL;
static FILE *_pdl_file = NULL;
static void pdl_malloc_log(const char *format, ...) {
#if 0
    va_list args;
    va_start(args, format);
    vfprintf(_pdl_file, format, args);
    va_end(args);
    fflush(_pdl_file);
#endif
}

#define pdl_malloc_log malloc_printf

#define PDL_MALLOC_INFO_MAGIC 0x50444c00

struct pdl_malloc_info {
    unsigned long magic;
    unsigned long size;
};

static malloc_zone_t *_pdl_zone = NULL;
static pthread_key_t _pdl_malloc_key = 0;

static void *(*pdl_dz_malloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_dz_malloc(malloc_zone_t *zone, size_t size) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        void *ptr = pdl_dz_malloc_og(_pdl_zone, size);
//
//        return ptr;
//    }

    void *lr = __builtin_return_address(0);
    void *fp = __builtin_frame_address(0);
    int count = pdl_frame_stack(lr, fp, NULL, 128);
    size_t alignment = sizeof(void *);
    size_t info_size = sizeof(struct pdl_malloc_info);
    size_t extra = alignment * count + info_size;
    size_t aligned = (size + (alignment - 1)) & ~(alignment - 1);
    size_t total = aligned + extra;
//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);
    void *ptr = pdl_dz_malloc_og(zone, aligned + extra);
    pdl_malloc_log("%s %p %d(%d)\n", "malloc", ptr, size, total);
    if (ptr) {
        int count_logged = pdl_frame_stack(lr, fp, ptr + aligned, 128);
        assert(count == count_logged);
        struct pdl_malloc_info *info = ptr + total - info_size;
        info->magic = PDL_MALLOC_INFO_MAGIC;
        info->size = extra;
    }
//    pthread_setspecific(_pdl_malloc_key, NULL);

    return ptr;
}

static void *(*pdl_dz_calloc_og)(malloc_zone_t *zone, size_t num_items, size_t size) = NULL;
static void *pdl_dz_calloc(malloc_zone_t *zone, size_t num_items, size_t size) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        void *ptr = pdl_dz_calloc_og(zone, num_items, size);
//
//        return ptr;
//    }

//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);
    void *ptr = pdl_dz_calloc_og(zone, num_items, size);
    pdl_malloc_log("%s %p %d %d\n", "calloc", ptr, num_items, size);
//    pthread_setspecific(_pdl_malloc_key, NULL);

    return ptr;
}

static void *(*pdl_dz_valloc_og)(malloc_zone_t *zone, size_t size) = NULL;
static void *pdl_dz_valloc(malloc_zone_t *zone, size_t size) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        void *ptr = pdl_dz_valloc_og(_pdl_zone, size);
//
//        return ptr;
//    }

//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);
    void *ptr = pdl_dz_valloc_og(zone, size);
    pdl_malloc_log("%s %p %d\n", "valloc", ptr, size);
//    pthread_setspecific(_pdl_malloc_key, NULL);

    return ptr;
}

static void (*pdl_dz_free_og)(malloc_zone_t *zone, void *ptr) = NULL;
static void pdl_dz_free(malloc_zone_t *zone, void *ptr) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        pdl_dz_free_og(_pdl_zone, ptr);
//    }

//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);

    size_t info_size = sizeof(struct pdl_malloc_info);
    size_t total = malloc_size(ptr);
    struct pdl_malloc_info *info = ptr + total - info_size;
    if (info->magic == PDL_MALLOC_INFO_MAGIC) {
#ifdef DEBUG
        assert(info->size);
#endif
        info->size = 0;
    }

//    size_t extra = ((unsigned long *)(ptr + total))[-1];
//    assert(extra);
    ((unsigned long *)(ptr + total))[-1] = 0;

    pdl_dz_free_og(zone, ptr);
    pdl_malloc_log("%s %p\n", "free", ptr);
//    pthread_setspecific(_pdl_malloc_key, NULL);
}

static void *(*pdl_dz_realloc_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void *pdl_dz_realloc(malloc_zone_t *zone, void *ptr, size_t size) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        void *p = pdl_dz_realloc_og(_pdl_zone, ptr, size);
//
//        return p;
//    }

//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);
    void *p = pdl_dz_realloc_og(zone, ptr, size);
    pdl_malloc_log("%s %p %d %p\n", "realloc", ptr, size, p);
//    pthread_setspecific(_pdl_malloc_key, NULL);

    return p;
}

static void (*pdl_dz_free_definite_size_og)(malloc_zone_t *zone, void *ptr, size_t size) = NULL;
static void pdl_dz_free_definite_size(malloc_zone_t *zone, void *ptr, size_t size) {
//    void *spec = pthread_getspecific(_pdl_malloc_key);
//    if (spec) {
//        pdl_dz_free_definite_size_og(_pdl_zone, ptr, size);
//    }

//    pthread_setspecific(_pdl_malloc_key, &_pdl_malloc_key);

    size_t info_size = sizeof(struct pdl_malloc_info);
    size_t total = malloc_size(ptr);
    struct pdl_malloc_info *info = ptr + total - info_size;
    if (info->magic == PDL_MALLOC_INFO_MAGIC) {
#ifdef DEBUG
        assert(info->size);
#endif
        info->size = 0;
    }

    pdl_dz_free_definite_size_og(zone, ptr, size);
    pdl_malloc_log("%s %p %d\n", "free_definite_size", ptr, size);
//    pthread_setspecific(_pdl_malloc_key, NULL);
}

#import <Foundation/Foundation.h>
#import <sys/mman.h>

//__attribute__((constructor))
bool pdl_malloc_enable(void) {
    pthread_key_create(&_pdl_malloc_key, NULL);
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"m.log"];
    _pdl_file_path_string = path;
    _pdl_file_path = path.UTF8String;
    _pdl_file = fopen(_pdl_file_path, "a+");

    malloc_zone_t *zone = malloc_create_zone(0, 0);
    _pdl_zone = zone;

    malloc_zone_t *dz = malloc_default_zone();
    if (!dz) {
        return false;
    }
    pdl_dz_malloc_og = dz->malloc;
    dz->malloc = pdl_dz_malloc;
    pdl_dz_calloc_og = dz->calloc;
    dz->calloc = pdl_dz_calloc;
    pdl_dz_valloc_og = dz->valloc;
    dz->valloc = pdl_dz_valloc;
    pdl_dz_free_og = dz->free;
    dz->free = pdl_dz_free;
    pdl_dz_realloc_og = dz->realloc;
    dz->realloc = pdl_dz_realloc;
    pdl_dz_free_definite_size_og = dz->free_definite_size;
    dz->free_definite_size = pdl_dz_free_definite_size;

    return true;
}

#endif
