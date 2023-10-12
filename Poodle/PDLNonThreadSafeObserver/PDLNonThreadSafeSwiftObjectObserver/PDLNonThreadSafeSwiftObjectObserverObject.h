//
//  PDLNonThreadSafeSwiftObjectObserverObject.h
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeSwiftObjectObserverObject : PDLNonThreadSafeObserverObject

- (void)record:(BOOL)isSetter;

@end

NS_ASSUME_NONNULL_END
