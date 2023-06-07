//
//  PDLNonThreadSafeSwiftVariableObserverObject.h
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeObserverObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLNonThreadSafeSwiftVariableObserverObject : PDLNonThreadSafeObserverObject

- (void)recordClass:(Class)aClass variableName:(NSString *)variableName isSetter:(BOOL)isSetter;

@end

NS_ASSUME_NONNULL_END
