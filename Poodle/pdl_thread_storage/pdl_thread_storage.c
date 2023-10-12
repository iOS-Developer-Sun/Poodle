//
//  pdl_thread_storage.c
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#include "pdl_thread_storage.h"
#include <stdbool.h>
#include <pthread.h>
#include "pdl_spinlock.h"
#include "pdl_dictionary.h"

#define PDL_PTHREAD_KEY_INVALID -1

static pthread_key_t pdl_pthread_key = PDL_PTHREAD_KEY_INVALID;

static pdl_dictionary_t *pdl_registration = NULL;
static pdl_spinlock pdl_registration_lock = PDL_SPINLOCK_INIT;

static void pdl_thread_storage_destroy(void *arg) {
    pdl_dictionary_t storage = (typeof(storage))arg;
    void **keys = NULL;
    unsigned int count = 0;
    pdl_dictionary_get_all_keys(storage, &keys, &count);
    for (unsigned int i = 0; i < count; i++) {
        void *key = keys[i];
        void **value = pdl_dictionary_get(storage, key);
        if (value) {
            pdl_spinlock_lock(&pdl_registration_lock);
            void **destructor = pdl_dictionary_get(pdl_registration, key);
            if (destructor) {
                destructor = *destructor;
            }
            pdl_spinlock_unlock(&pdl_registration_lock);
            if (destructor) {
                ((void(*)(void *))destructor)(*value);
            }
        }
    }
    pdl_dictionary_destroy_keys(storage, keys);
    pdl_dictionary_destroy(storage);
}

static pdl_dictionary_t pdl_get_storage(void) {
    pdl_dictionary_t *storage = pthread_getspecific(pdl_pthread_key);
    if (!storage) {
        storage = pdl_dictionary_create(NULL);
        pthread_setspecific(pdl_pthread_key, storage);
    }
    return storage;
}

static void pdl_thread_storage_enable(void) {
    static bool init = false;
    if (init) {
        return;
    }

    static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    if (!init) {
        pthread_key_create(&pdl_pthread_key, &pdl_thread_storage_destroy);
        pdl_registration = pdl_dictionary_create(NULL);
        init = true;
    }
    pthread_mutex_unlock(&mutex);
}

bool pdl_thread_storage_enabled(void) {
    return pdl_pthread_key != PDL_PTHREAD_KEY_INVALID;
}

void pdl_thread_storage_register(void *key, void(*destructor)(void *)) {
    pdl_thread_storage_enable();
    pdl_spinlock_lock(&pdl_registration_lock);
    pdl_dictionary_set(pdl_registration, key, (void **)&destructor);
    pdl_spinlock_unlock(&pdl_registration_lock);
}

void **pdl_thread_storage_get(void *key) {
    pdl_dictionary_t storage = pdl_get_storage();
    return pdl_dictionary_get(storage, key);
}

void *pdl_thread_storage_set(void *key, void **value) {
    pdl_dictionary_t storage = pdl_get_storage();
    return pdl_dictionary_set(storage, key, value);
}
