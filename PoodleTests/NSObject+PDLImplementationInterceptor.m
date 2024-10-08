//
//  NSObject+PDLImplementationInterceptor.m
//  PoodleTests
//
//  Created by zijian.sun on 9/9/22.
//  Copyright © 2022 Poodle. All rights reserved.
//

#import "PoodleTests.h"
#import "NSObject+PDLImplementationInterceptor.h"

@interface PDLImplementationInterceptor : NSObject

@property (nonatomic) NSInteger i;
@property (nonatomic) CGRect rect;

@end

@implementation PDLImplementationInterceptor

@end

@interface PDLImplementationInterceptorTest : XCTestCase

@end

@implementation PDLImplementationInterceptorTest

static NSInteger i(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    NSInteger ret = ((typeof(&i))_imp)(self, _cmd);
    ret += 10000;
    return ret;
}

static CGRect rect(__unsafe_unretained id self, SEL _cmd) {
    PDLImplementationInterceptorRecover(_cmd);
    CGRect ret = ((typeof(&rect))_imp)(self, _cmd);
    ret.size.width += 10000;
    ret.size.height += 10000;
    return ret;
}

- (void)setUp {
    BOOL ret = [PDLImplementationInterceptor pdl_interceptSelector:@selector(i) withInterceptorImplementation:(IMP)i];
    ret = ret && [PDLImplementationInterceptor pdl_interceptSelector:@selector(rect) withInterceptorImplementation:(IMP)rect];
    XCTAssert(ret);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    PDLImplementationInterceptor *test = [[PDLImplementationInterceptor alloc] init];
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
