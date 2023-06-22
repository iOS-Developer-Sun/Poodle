//
//  PDLNonThreadSafeSwiftVariableObserver.h
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLNonThreadSafeSwiftVariableObserverVariable.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^PDLNonThreadSafeSwiftVariableObserver_VariableFilter)(NSString *variableName);
typedef BOOL(^PDLNonThreadSafeSwiftVariableObserver_ClassFilter)(NSString *className);
typedef _Nullable PDLNonThreadSafeSwiftVariableObserver_VariableFilter(^_Nullable PDLNonThreadSafeSwiftVariableObserver_ClassVariableFilter)(NSString *className);

@interface PDLNonThreadSafeSwiftVariableObserver : NSObject

+ (void)observeWithClassFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassFilter _Nullable)classFilter
           classVariableFilter:(PDLNonThreadSafeSwiftVariableObserver_ClassVariableFilter _Nullable)classVariableFilter;

@end

NS_ASSUME_NONNULL_END
