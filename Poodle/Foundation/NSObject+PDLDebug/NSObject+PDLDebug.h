//
//  NSObject+PDLDebug.h
//  Poodle
//
//  Created by Poodle on 14-6-26.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLDebug)

@property (readonly) NSString *propertiesDescription;

@property (class, readonly) NSArray *object_subclasses;
@property (class, readonly) NSArray *object_ivars;
@property (class, readonly) NSArray *object_classMethods;
@property (class, readonly) NSArray *object_instanceMethods;
@property (class, readonly) NSArray *object_protocols;
@property (class, readonly) NSArray *object_properties;

@property (class, readonly) Class metaClass;

- (instancetype)objectRetain;
- (oneway void)objectRelease;
- (instancetype)objectAutorelease;
- (NSUInteger)objectRetainCount;

- (instancetype)objectAutoreleaseRetained;

extern NSArray *object_subclasses(Class aClass);
extern NSArray *object_ivars(Class aClass);
extern NSArray *object_classMethods(Class aClass);
extern NSArray *object_instanceMethods(Class aClass);
extern NSArray *object_protocols(Class aClass);
extern NSArray *object_properties(Class aClass);

extern NSArray *protocol_adoptingProtocols(Protocol *protocol);
extern NSArray *protocol_adoptedProtocols(Protocol *protocol);
extern NSArray *protocol_properties(Protocol *protocol);
extern NSArray *protocol_methods(Protocol *protocol);

extern id objectRetain(id object);
extern void objectRelease(id object);
extern id objectAutorelease(id object);
extern NSUInteger objectRetainCount(id object);

extern id objectAutoreleaseRetained(id object);

@end
