//
//  PDLPudding.m
//  Poodle
//
//  Created by Poodle on 2021/7/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLPudding.h"
#import "JPEngine.h"

/*
 JSPatch 1.1.3

 1 JSPatch.js
 2 alias JPEngine JPExtension JPBoxing
 3 remove lower version code
 4 fix warning
 5 direct members JPEngine JPBoxing
 6 JP strings
 7 const strings
 8 optimize
 9 disable JPExtension

 */

@implementation PDLPudding

+ (id)e:(NSString *)script {
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
        [PDLPudding e:js];
        [[[PDLPudding alloc] init] test];
    });
}

#endif

@end
