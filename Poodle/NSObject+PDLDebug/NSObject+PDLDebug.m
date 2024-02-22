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

+ (NSArray *)pdl_subclasses {
    return pdl_class_subclasses(self);
}

+ (NSArray *)pdl_directSubclasses {
    return pdl_class_directSubclasses(self);
}

+ (NSArray *)pdl_ivars {
    return pdl_class_ivars(self);
}

+ (NSArray *)pdl_classMethods {
    return pdl_class_classMethods(self);
}

+ (NSArray *)pdl_instanceMethods {
    return pdl_class_instanceMethods(self);
}

+ (NSArray *)pdl_protocols {
    return pdl_class_protocols(self);
}

+ (NSArray *)pdl_properties {
    return pdl_class_properties(self);
}

+ (NSArray *)pdl_description {
    return @[
        @{@"superclass" : [self superclass] ? NSStringFromClass([self superclass]) : @"nil"},
        @{@"subclasses" : [self pdl_subclasses]},
        @{@"ivars" : [self pdl_ivars]},
        @{@"properties" : [self pdl_properties]},
        @{@"classMethods" : [self pdl_classMethods]},
        @{@"instanceMethods" : [self pdl_instanceMethods]},
        @{@"protocols" : [self pdl_protocols]},
    ];
}

+ (Class)pdl_metaClass {
    Class metaClass = object_getClass(self);
    return metaClass;
}

NSDictionary *pdl_propertiesDescriptionForClass(id self, Class aClass) {
    NSMutableDictionary *propertiesDescriptionDictionary = [NSMutableDictionary dictionary];
    NSString *debugDescription = [NSString stringWithFormat:@"<%@>: %p", NSStringFromClass(object_getClass(self)), self];
    propertiesDescriptionDictionary[@"."] = debugDescription;
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertiesCount);
    NSArray *keys = @[
        @"description",
        @"debugDescription",

        @"_ivarDescription",
        @"_shortMethodDescription",
        @"_methodDescription",
        @"_copyDescription",
#if !TARGET_IPHONE_SIMULATOR
        @"_briefDescription",
        @"_rawBriefDescription",
#endif
        @"pdl_propertiesDescription",
        @"pdl_fullPropertiesDescription",
    ];

    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = @(property_getName(property));
        if ([keys containsObject:key]) {
            continue;
        }
        id value = nil;
        @try {
            value = [self valueForKeyPath:key];
        } @catch (NSException *exception) {
            propertiesDescriptionDictionary[key] = @"UNDEFINED";
        } @finally {
            ;
        }
        propertiesDescriptionDictionary[key] = value;
    }
    free(properties);
    return [propertiesDescriptionDictionary copy];
}

- (NSString *)pdl_propertiesDescriptionForClass:(Class)aClass {
    NSDictionary *dictionary = pdl_propertiesDescriptionForClass(self, aClass);
    return dictionary.description;
}

- (NSString *)pdl_propertiesDescription {
    return [self pdl_propertiesDescriptionForClass:self.class];
}

- (NSString *)pdl_fullPropertiesDescription {
    Class aClass = self.class;
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    while (aClass) {
        NSDictionary *dictionary = pdl_propertiesDescriptionForClass(self, aClass);
        [ret addEntriesFromDictionary:dictionary];
        aClass = [aClass superclass];
    };
    return [ret copy];
}

- (NSString *)pdl_debugDescription:(NSInteger)indentationLevel {
    NSMutableString *ret = [NSMutableString string];
    NSMutableString *indentation = [NSMutableString string];
    for (NSInteger i = 0; i < indentationLevel; i++) {
        [indentation appendString:@"\t"];
    }
    [ret appendString:indentation];
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)self;
        NSUInteger count = dictionary.count;
        [ret appendFormat:@"`%@<%p(%zd)>(%lu)`", [self class], self, [self pdl_retainCount], count];
        [ret appendFormat:@"\n%@{", indentation];
        for (id key in [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
            id value = dictionary[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]
                || [value isKindOfClass:[NSSet class]]
                || [value isKindOfClass:[NSOrderedSet class]]) {
                [ret appendFormat:@"\n%@ :\n%@,", [key pdl_debugDescription:indentationLevel + 1], [value pdl_debugDescription:indentationLevel + 1]];
            } else {
                [ret appendFormat:@"\n%@ : %@,", [key pdl_debugDescription:indentationLevel + 1], [value pdl_debugDescription:0]];
            }
        }
        [ret appendFormat:@"\n%@}", indentation];
    } else if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)self;
        NSUInteger count = array.count;
        [ret appendFormat:@"`%@<%p(%zd)>(%lu)`", [self class], self, [self pdl_retainCount], count];
        [ret appendFormat:@"\n%@[", indentation];
        for (NSInteger i = 0; i < count; i++) {
            id object = array[i];
            [ret appendFormat:@"\n%@,", [object pdl_debugDescription:indentationLevel + 1]];
        }
        [ret appendFormat:@"\n%@]", indentation];
    } else if ([self isKindOfClass:[NSSet class]] || [self isKindOfClass:[NSOrderedSet class]]) {
        NSSet *set = (NSSet *)self;
        NSUInteger count = set.count;
        [ret appendFormat:@"`%@<%p(%zd)>(%lu)`", [self class], self, [self pdl_retainCount], count];
        [ret appendFormat:@"\n%@[", indentation];
        for (id object in set) {
            [ret appendFormat:@"\n%@,", [object pdl_debugDescription:indentationLevel + 1]];
        }
        [ret appendFormat:@"\n%@]", indentation];
    } else {
        [ret appendFormat:@"`%@<%p(%zd)>`%@", [self class], self, [self pdl_retainCount], self];
    }
    return ret;
}

- (NSString *)pdl_debugDescription {
    return [self pdl_debugDescription:0];
}

#pragma mark -

NSArray *pdl_class_subclasses(Class aClass) {
    NSMutableArray *subclasses = [NSMutableArray array];
    unsigned int outCount = 0;
    Class *classList = objc_copyClassList(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Class eachClass = classList[i];
        Class superclass = class_getSuperclass(eachClass);
        while (superclass) {
            if (superclass == aClass) {
                [subclasses addObject:@(class_getName(eachClass))];
                break;;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    free(classList);
    return [subclasses copy];
}

NSArray *pdl_class_directSubclasses(Class aClass) {
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
    return [subclasses copy];
}

NSArray *pdl_class_ivars(Class aClass) {
    NSMutableArray *ivars = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        [ivars addObject:@{@"name" : @(ivar_getName(ivar)), @"type" : @(ivar_getTypeEncoding(ivar)), @"offset" : @(ivar_getOffset(ivar))}];
    }
    free(ivarList);
    return [ivars copy];
}

NSArray *pdl_class_classMethods(Class aClass) {
    NSMutableArray *classMethods = [NSMutableArray array];
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(object_getClass(aClass), &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        [classMethods addObject:@{
            @"name" : @(sel_getName(method_getName(method))),
            @"type" : @(method_getTypeEncoding(method)),
            @"imp" : [NSString stringWithFormat:@"%p", method_getImplementation(method)],
        }];
    }
    free(methodList);
    return [classMethods copy];
}

NSArray *pdl_class_instanceMethods(Class aClass) {
    NSMutableArray *classMethods = [NSMutableArray array];
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        [classMethods addObject:@{
            @"name" : @(sel_getName(method_getName(method))),
            @"type" : @(method_getTypeEncoding(method)),
            @"imp" : [NSString stringWithFormat:@"%p", method_getImplementation(method)],
        }];
    }
    free(methodList);
    return [classMethods copy];
}

NSArray *pdl_class_protocols(Class aClass) {
    NSMutableArray *protocols = [NSMutableArray array];
    unsigned int count = 0;
    Protocol *__unsafe_unretained *protocolList = class_copyProtocolList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocolList[i];
        [protocols addObject:@{@"name" : @(protocol_getName(protocol))}];
    }
    free(protocolList);
    return [protocols copy];
}

NSArray *pdl_class_properties(Class aClass) {
    NSMutableArray *properties = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        [properties addObject:@{@"name" : @(property_getName(property)), @"attributes" : @(property_getAttributes(property))}];
    }
    free(propertyList);
    return [properties copy];
}

NSArray *pdl_protocol_adoptingProtocols(Protocol *protocol) {
    NSMutableArray *adoptingProtocols = [NSMutableArray array];
    unsigned int count = 0;
    Protocol * __unsafe_unretained _Nonnull *protocolList = protocol_copyProtocolList(protocol, &count);
    for (unsigned int i = 0; i < count; i++) {
        Protocol *protocol = protocolList[i];
        [adoptingProtocols addObject:@(protocol_getName(protocol))];
    }
    free(protocolList);
    return [adoptingProtocols copy];
}

NSArray *pdl_protocol_adoptedProtocols(Protocol *protocol) {
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

NSArray *pdl_protocol_properties(Protocol *protocol) {
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
    return [properties copy];
}

NSArray *pdl_protocol_methods(Protocol *protocol) {
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
    return [methods copy];
}

@end

#pragma clang diagnostic pop
