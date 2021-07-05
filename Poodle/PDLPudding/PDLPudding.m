//
//  PDLPudding.m
//  Poodle
//
//  Created by sunzj on 2021/7/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLPudding.h"
#import "JPEngine.h"

// JSPatch 1.1.3

@implementation PDLPudding

+ (JSValue *)evaluateScript:(NSString *)script {
    return [JPEngine evaluateScript:script];
}

#if 0

- (void)test {
    assert(0);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *js = @"defineClass('PDLPudding', {\n"
        @"test: function() {\n"
        @"console.log('PDLPudding test')\n"
        @"}\n"
        @"})";
        [PDLPudding evaluateScript:js];
        [[[PDLPudding alloc] init] test];
    });
}

#endif

@end
