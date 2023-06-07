//
//  PDLNonThreadSafeSwiftVariableObserverObject.m
//  Poodle
//
//  Created by Poodle on 2023/6/5.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLNonThreadSafeSwiftVariableObserverObject.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import "PDLNonThreadSafeSwiftVariableObserverVariable.h"
#import "NSObject+PDLDebug.h"
#import "NSObject+PDLPrivate.h"
#import "PDLNonThreadSafeObserver.h"
#import "PDLCrash.h"

@interface PDLNonThreadSafeSwiftVariableObserverObject ()

@property (strong, readonly) NSMutableDictionary *variables;

@end

@implementation PDLNonThreadSafeSwiftVariableObserverObject

- (instancetype)initWithObject:(id)object {
    self = [super initWithObject:object];
    if (self) {
        NSMutableDictionary *variables = [NSMutableDictionary dictionary];
        [PDLNonThreadSafeObserver setIgnored:YES forObject:variables];
        _variables = variables;
    }
    return self;
}

- (NSString *)description {
    NSString *description = [super description];
    return [NSString stringWithFormat:@"%@\n%@", description, self.variables];
}

#pragma mark - class.variable

- (PDLNonThreadSafeSwiftVariableObserverVariable *)variableWithClass:(Class)aClass variableName:(NSString *)variableName {
    NSString *classString = NSStringFromClass(aClass);
    classString = [PDLCrash demangle:classString] ?: classString;
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", classString, variableName];
    @synchronized (self) { // one object to multiple class.variable
        PDLNonThreadSafeSwiftVariableObserverVariable *variable = _variables[identifier];
        if (!variable) {
            variable = [[PDLNonThreadSafeSwiftVariableObserverVariable alloc] initWithObserver:self identifier:identifier];
            _variables[identifier] = variable;
        }
        return variable;
    }
}

- (void)recordClass:(Class)aClass variableName:(NSString *)variableName isSetter:(BOOL)isSetter {
    PDLNonThreadSafeSwiftVariableObserverVariable *variable = [self variableWithClass:aClass variableName:variableName];
    [variable recordIsSetter:isSetter isInitializing:self.isInitializing];
}

@end
