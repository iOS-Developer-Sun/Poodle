//
//  NSObject+PDLWeakifyUnsafeUnretainedProperty.h
//  Poodle
//
//  Created by Sun on 14-6-26.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (PDLWeakifyUnsafeUnretainedProperty)

+ (BOOL)pdl_weakifyProperty:(NSString *)propertyName;
+ (BOOL)pdl_weakifyProperty:(NSString *)propertyName needsSync:(BOOL)needsSync;

@end
