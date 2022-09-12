//
//  NSObject+NSObject+PDLSelectorProxy.m
//  PoodleTests
//
//  Created by zijian.sun on 9/9/22.
//  Copyright © 2022 Poodle. All rights reserved.
//

#import "PoodleTests.h"
#import "NSObject+PDLSelectorProxy.h"

@interface PDLSelectorProxy : NSObject

@property (nonatomic) NSInteger i;
@property (nonatomic) CGRect rect;

@end

@implementation PDLSelectorProxy

@end

@interface PDLSelectorProxyTest : XCTestCase

@end

@implementation PDLSelectorProxyTest

static NSInteger i(__unsafe_unretained id self, SEL _cmd) {
    IMP _imp = [self pdl_selectorProxyImplementationForSelector:_cmd];
    NSInteger ret = ((typeof(&i))_imp)(self, _cmd);
    ret += 10000;
    return ret;
}

static CGRect rect(__unsafe_unretained id self, SEL _cmd) {
    IMP _imp = [self pdl_selectorProxyImplementationForSelector:_cmd];
    CGRect ret = ((typeof(&rect))_imp)(self, _cmd);
    ret.size.width += 10000;
    ret.size.height += 10000;
    return ret;
}

- (void)setUp {
    [NSObject pdl_enableSelectorProxy];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    PDLSelectorProxy *test = [[PDLSelectorProxy alloc] init];
    BOOL ret = [test pdl_setSelectorProxyForSelector:@selector(i) withImplementation:(IMP)&i];
    ret = ret && [test pdl_setSelectorProxyForSelector:@selector(rect) withImplementation:(IMP)&rect];
    XCTAssert(ret);

    test.i = 0;
    test.rect = CGRectZero;
    NSInteger i = test.i;
    CGRect rect = test.rect;
    XCTAssert(i == 10000);
    XCTAssert(rect.size.width == 10000);
    XCTAssert(rect.size.height == 10000);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
