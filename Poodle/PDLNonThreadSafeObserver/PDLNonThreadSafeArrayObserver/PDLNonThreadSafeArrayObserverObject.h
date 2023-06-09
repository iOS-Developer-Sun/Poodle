//
//  PDLNonThreadSafeArrayObserverObject.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"
#import "NSObject+PDLImplementationInterceptor.h"

@interface  PDLNonThreadSafeArrayObserverObject : PDLNonThreadSafeObserverObject

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter;

@end
