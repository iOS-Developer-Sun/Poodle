//
//  NSObject+PDLDebug.m
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "NSObject+PDLDebug.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NSObject (PDLDebug)

- (NSString *)propertiesDescription {
    NSMutableDictionary *propertiesDescriptionDictionary = [NSMutableDictionary dictionary];
    NSString *debugDescription = [NSString stringWithFormat:@"<%@>: %p", NSStringFromClass(self.class), self];
    propertiesDescriptionDictionary[@"__Object"] = debugDescription;
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertiesCount);
    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = @(property_getName(property));
        if ([key isEqualToString:@"description"] || [key isEqualToString:@"debugDescription"] || [key isEqualToString:@"propertiesDescription"]) {
            continue;
        }
        id value = [self valueForKey:key];
        propertiesDescriptionDictionary[key] = value ?: @"nil";
    }
    free(properties);

    return propertiesDescriptionDictionary.description;
}

+ (NSArray *)object_subclasses {
    return object_subclasses(self);
}

+ (NSArray *)object_ivars {
    return object_ivars(self);
}

+ (NSArray *)object_classMethods {
    return object_classMethods(self);
}

+ (NSArray *)object_instanceMethods {
    return object_instanceMethods(self);
}

+ (NSArray *)object_protocols {
    return object_protocols(self);
}

+ (NSArray *)object_properties {
    return object_properties(self);
}

+ (Class)metaClass {
    Class metaClass = object_getClass(self);
    return metaClass;
}

NSArray *object_subclasses(Class aClass) {
    NSMutableArray *subclasses = [NSMutableArray array];
    unsigned int outCount = 0;
    Class *classList = objc_copyClassList(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Class eachClass = classList[i];
        if (class_getSuperclass(eachClass) == aClass) {
            [subclasses addObject:@(class_getName(eachClass))];
        }
    }
    free(classList);
    return subclasses.copy;
}

NSArray *object_ivars(Class aClass) {
    NSMutableArray *ivars = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        [ivars addObject:@{@"name" : @(ivar_getName(ivar)), @"type" : @(ivar_getTypeEncoding(ivar)), @"offset" : @(ivar_getOffset(ivar))}];
    }
    free(ivarList);
    return ivars.copy;
}

NSArray *object_classMethods(Class aClass) {
    NSMutableArray *classMethods = [NSMutableArray array];
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(object_getClass(aClass), &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        [classMethods addObject:@{@"name" : @(sel_getName(method_getName(method))), @"type" : @(method_getTypeEncoding(method))}];
    }
    free(methodList);
    return classMethods.copy;
}

NSArray *object_instanceMethods(Class aClass) {
    NSMutableArray *classMethods = [NSMutableArray array];
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        [classMethods addObject:@{@"name" : @(sel_getName(method_getName(method))), @"type" : @(method_getTypeEncoding(method))}];
    }
    free(methodList);
    return classMethods.copy;
}

NSArray *object_protocols(Class aClass) {
    NSMutableArray *protocols = [NSMutableArray array];
    unsigned int count = 0;
    Protocol *__unsafe_unretained *protocolList = class_copyProtocolList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocolList[i];
        [protocols addObject:@{@"name" : @(protocol_getName(protocol))}];
    }
    free(protocolList);
    return protocols.copy;
}

NSArray *object_properties(Class aClass) {
    NSMutableArray *properties = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        [properties addObject:@{@"name" : @(property_getName(property)), @"attributes" : @(property_getAttributes(property))}];
    }
    free(propertyList);
    return properties.copy;
}

NSArray *protocol_adoptingProtocols(Protocol *protocol) {
    NSMutableArray *adoptingProtocols = [NSMutableArray array];
    unsigned int count = 0;
    Protocol * __unsafe_unretained _Nonnull *protocolList = protocol_copyProtocolList(protocol, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocolList[i];
        [adoptingProtocols addObject:@(protocol_getName(protocol))];
    }
    free(protocolList);
    return adoptingProtocols.copy;
}

NSArray *protocol_adoptedProtocols(Protocol *protocol) {
    NSMutableArray *adoptedProtocols = [NSMutableArray array];
    unsigned int count = 0;
    Protocol * __unsafe_unretained *protocolList = objc_copyProtocolList(&count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *adoptedProtocol = protocolList[i];
        if (protocol_isEqual(protocol, adoptedProtocol)) {
            continue;
        }
        if (!protocol_conformsToProtocol(adoptedProtocol, protocol)) {
            continue;
        }
        unsigned int adoptingCount = 0;
        Protocol * __unsafe_unretained _Nonnull *adoptingProtocolList = protocol_copyProtocolList(adoptedProtocol, &adoptingCount);
        for (unsigned int j = 0; j < adoptingCount; j++) {
            Protocol *adoptingProtocol = adoptingProtocolList[j];
            if (protocol_isEqual(protocol, adoptingProtocol)) {
                [adoptedProtocols addObject:@(protocol_getName(adoptedProtocol))];
                break;
            }
        }
        free(adoptingProtocolList);
    }
    free(protocolList);
    return adoptedProtocols;
}

NSArray *protocol_properties(Protocol *protocol) {
    NSMutableArray *properties = [NSMutableArray array];
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10) {
        NSArray *types = @[@{@"isRequiredMethod" : @(YES), @"isInstanceMethod" : @(NO)},
                           @{@"isRequiredMethod" : @(YES), @"isInstanceMethod" : @(YES)},
                           @{@"isRequiredMethod" : @(NO), @"isInstanceMethod" : @(NO)},
                           @{@"isRequiredMethod" : @(NO), @"isInstanceMethod" : @(YES)}];
        for (NSDictionary *type in types) {
            BOOL isRequiredMethod = [type[@"isRequiredMethod"] boolValue];
            BOOL isInstanceMethod = [type[@"isInstanceMethod"] boolValue];
            unsigned int count = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
            objc_property_t *propertyList = protocol_copyPropertyList2(protocol, &count, isRequiredMethod, isInstanceMethod);
#pragma clang diagnostic pop
            for (unsigned int i = 0; i < count; i++) {
                objc_property_t property = propertyList[i];
                [properties addObject:@{@"name" : @(property_getName(property)), @"attributes" : @(property_getAttributes(property)), @"isRequiredMethod" : @(isRequiredMethod), @"isInstanceMethod" : @(isInstanceMethod)}];
            }
            free(propertyList);
        }
    } else {
        unsigned int count = 0;
        objc_property_t *propertyList = protocol_copyPropertyList(protocol, &count);
        for (unsigned int i = 0; i < count; i++) {
            objc_property_t property = propertyList[i];
            [properties addObject:@{@"name" : @(property_getName(property)), @"attributes" : @(property_getAttributes(property))}];
        }
        free(propertyList);
    }
    return properties.copy;
}

NSArray *protocol_methods(Protocol *protocol) {
    NSMutableArray *methods = [NSMutableArray array];
    NSArray *types = @[@{@"isRequiredMethod" : @(YES), @"isInstanceMethod" : @(NO)},
                       @{@"isRequiredMethod" : @(YES), @"isInstanceMethod" : @(YES)},
                       @{@"isRequiredMethod" : @(NO), @"isInstanceMethod" : @(NO)},
                       @{@"isRequiredMethod" : @(NO), @"isInstanceMethod" : @(YES)}];
    for (NSDictionary *type in types) {
        BOOL isRequiredMethod = [type[@"isRequiredMethod"] boolValue];
        BOOL isInstanceMethod = [type[@"isInstanceMethod"] boolValue];
        unsigned int count = 0;
        struct objc_method_description *methodList = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &count);
        for (unsigned int i = 0; i < count; i++) {
            struct objc_method_description *method = methodList + i;
            [methods addObject:@{@"name" : @(sel_getName(method->name)), @"type" : @(method->types), @"isRequiredMethod" : @(isRequiredMethod), @"isInstanceMethod" : @(isInstanceMethod)}];
        }
        free(methodList);
    }
    return methods.copy;
}

@end

#pragma clang diagnostic pop
