//
//  PDLNonThreadSafeSwiftObjectObserver.m
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftObjectObserver.h"
#import "PDLNonThreadSafeSwiftObjectObserverObject.h"
#import "pdl_swift.h"

@implementation PDLNonThreadSafeSwiftObjectObserver

static void getter(void **key, void *object, void **meta) {
    void *objectAddress = pdl_swift_validate_object(object);
    id dictionary = (__bridge id)(objectAddress);

    Class aClass = NSClassFromString(@"__SwiftNativeNSDictionaryBase");
    if (![dictionary isKindOfClass:aClass]) {
        return;
    }

    @autoreleasepool {
        [PDLNonThreadSafeSwiftObjectObserverObject registerObject:dictionary];
    }

//    NSLog(@"getter %@", dictionary);
    PDLNonThreadSafeSwiftObjectObserverObject *observer = [PDLNonThreadSafeSwiftObjectObserverObject observerObjectForObject:dictionary];
    [observer record:NO];
}

static void setter(void **value, void **key, void **meta, void *object) {
    void *objectAddress = pdl_swift_validate_object(object);
    id dictionary = (__bridge id)(objectAddress);

    Class aClass = NSClassFromString(@"__SwiftNativeNSDictionaryBase");
    if (![dictionary isKindOfClass:aClass]) {
        return;
    }

    @autoreleasepool {
        [PDLNonThreadSafeSwiftObjectObserverObject registerObject:dictionary];
    }

//    NSLog(@"setter %@", dictionary);
    PDLNonThreadSafeSwiftObjectObserverObject *observer = [PDLNonThreadSafeSwiftObjectObserverObject observerObjectForObject:dictionary];
    [observer record:YES];
}

static void modify(void **value, void **key, void **meta, pdl_swift_dictionary_modify_ret ret, void *object) {
    id dictionary = (__bridge id)(object);
    Class aClass = NSClassFromString(@"__SwiftNativeNSDictionaryBase");
    if (![dictionary isKindOfClass:aClass]) {
        return;
    }

    @autoreleasepool {
        [PDLNonThreadSafeSwiftObjectObserverObject registerObject:dictionary];
    }

//    NSLog(@"modify %@", object);
    PDLNonThreadSafeSwiftObjectObserverObject *observer = [PDLNonThreadSafeSwiftObjectObserverObject observerObjectForObject:dictionary];
    [observer record:YES];
}

+ (void)observeWithFilter:(BOOL(^)(PDLBacktrace *backtrace, NSString **name))filter {
    pdl_swift_registerDictionaryGetterAction(&getter);
    pdl_swift_registerDictionarySetterAction(&setter);
    pdl_swift_registerDictionaryModifyAction(&modify);
}

@end
