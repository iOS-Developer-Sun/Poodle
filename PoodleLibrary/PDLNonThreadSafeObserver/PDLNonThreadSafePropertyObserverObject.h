//
//  PDLNonThreadSafePropertyObserverObject.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafePropertyObserverObject : PDLNonThreadSafeObserverObject

- (void)recordClass:(Class)aClass propertyName:(NSString *)propertyName isSetter:(BOOL)isSetter;

@end

NS_ASSUME_NONNULL_END
