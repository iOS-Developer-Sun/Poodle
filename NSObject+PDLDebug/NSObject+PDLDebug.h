//
//  NSObject+PDLDebug.h
//  Sun
//
//  Created by Sun on 14-6-26.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLDebug)

@property (readonly) NSString *propertiesDescription;
@property (readonly) NSUInteger objectRetainCount;

@property (class, readonly) NSArray *object_subclasses;
@property (class, readonly) NSArray *object_ivars;
@property (class, readonly) NSArray *object_classMethods;
@property (class, readonly) NSArray *object_instanceMethods;
@property (class, readonly) NSArray *object_protocols;
@property (class, readonly) NSArray *object_properties;

@property (class, readonly) Class metaClass;

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

extern NSUInteger objc_retainCount(id object);

@end
