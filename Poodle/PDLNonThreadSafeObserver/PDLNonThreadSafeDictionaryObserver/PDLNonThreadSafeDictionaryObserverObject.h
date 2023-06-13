//
//  PDLNonThreadSafeDictionaryObserverObject.h
//  Poodle
//
//  Created by Poodle on 2020/1/14.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeDictionaryObserverObject : PDLNonThreadSafeObserverObject

- (void)recordClass:(Class)aClass selectorString:(NSString *)selectorString isSetter:(BOOL)isSetter;

@end

NS_ASSUME_NONNULL_END
