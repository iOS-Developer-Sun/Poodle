//
//  NSObject+PDLDebug.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

@interface NSObject (PDLDebug)

@property (class, readonly) NSArray *pdl_subclasses;
@property (class, readonly) NSArray *pdl_directSubclasses;
@property (class, readonly) NSArray *pdl_ivars;
@property (class, readonly) NSArray *pdl_classMethods;
@property (class, readonly) NSArray *pdl_instanceMethods;
@property (class, readonly) NSArray *pdl_protocols;
@property (class, readonly) NSArray *pdl_properties;

@property (class, readonly) NSArray *pdl_description;

@property (class, readonly) Class pdl_metaClass;

@property (readonly) NSString *pdl_propertiesDescription;
@property (readonly) NSString *pdl_fullPropertiesDescription;

- (NSString *)pdl_propertiesDescriptionForClass:(Class)aClass;

- (instancetype)pdl_retain;
- (oneway void)pdl_release;
- (instancetype)pdl_autorelease;
- (NSUInteger)pdl_retainCount;

- (instancetype)pdl_autoreleaseRetained;

extern NSArray *pdl_class_subclasses(Class aClass);
extern NSArray *pdl_class_directSubclasses(Class aClass);
extern NSArray *pdl_class_ivars(Class aClass);
extern NSArray *pdl_class_classMethods(Class aClass);
extern NSArray *pdl_class_instanceMethods(Class aClass);
extern NSArray *pdl_class_protocols(Class aClass);
extern NSArray *pdl_class_properties(Class aClass);

extern NSArray *pdl_protocol_adoptingProtocols(Protocol *protocol);
extern NSArray *pdl_protocol_adoptedProtocols(Protocol *protocol);
extern NSArray *pdl_protocol_properties(Protocol *protocol);
extern NSArray *pdl_protocol_methods(Protocol *protocol);

extern id pdl_objectRetain(id object);
extern void pdl_objectRelease(id object);
extern id pdl_objectAutorelease(id object);
extern NSUInteger pdl_objectRetainCount(id object);

extern id pdl_objectAutoreleaseRetained(id object);

@end

#ifdef __cplusplus
}
#endif
