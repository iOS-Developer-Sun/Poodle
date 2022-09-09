//
//  NSObject+PDLImplementationInterceptor.m
//  PoodleTests
//
//  Created by zijian.sun on 9/9/22.
//  Copyright © 2022 Poodle. All rights reserved.
//

#import "PoodleTests.h"
#import "NSObject+PDLMethod.h"

@interface PDLMethodTestClass : NSObject {
    @public NSMutableDictionary *beforeTimes;
}

@property (nonatomic) NSInteger i;
@property (nonatomic) CGRect rect;

@end

@implementation PDLMethodTestClass

@end

@interface PDLMethodTestClass2 : NSObject {
    @public NSMutableDictionary *beforeTimes;
    @public NSMutableDictionary *afterTimes;
}

@property (nonatomic) NSInteger i;
@property (nonatomic) CGRect rect;

@end

@implementation PDLMethodTestClass2

@end

@interface PDLMethodTest : XCTestCase

@end

@implementation PDLMethodTest

static void before(__unsafe_unretained id self, SEL _cmd) {
    NSString *key = @(sel_getName(_cmd));
    PDLMethodTestClass *test = self;
    if (!test->beforeTimes) {
        test->beforeTimes = [NSMutableDictionary dictionary];
    }
    NSNumber *times = test->beforeTimes[key];
    times = @(times.integerValue + 1);
    test->beforeTimes[key] = times;
}

static void after(__unsafe_unretained id self, SEL _cmd) {
    NSString *key = @(sel_getName(_cmd));
    PDLMethodTestClass2 *test = self;
    if (!test->afterTimes) {
        test->afterTimes = [NSMutableDictionary dictionary];
    }
    NSNumber *times = test->afterTimes[key];
    times = @(times.integerValue + 1);
    test->afterTimes[key] = times;
}

- (void)setUp {
    BOOL ret = [PDLMethodTestClass pdl_addInstanceMethodsBeforeAction:(IMP)&before afterAction:NULL];
    XCTAssert(ret);
    ret = [PDLMethodTestClass2 pdl_addInstanceMethodsBeforeAction:(IMP)&before afterAction:(IMP)&after];
    XCTAssert(ret);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    PDLMethodTestClass *test = [[PDLMethodTestClass alloc] init];
    for (NSInteger i = 0; i < 100; i++) {
        test.i = 0;
        test.rect = CGRectZero;
    }
    XCTAssert(test->beforeTimes.count == 2);
    XCTAssert([test->beforeTimes[@"setI:"] integerValue] == 100);
    XCTAssert([test->beforeTimes[@"setRect:"] integerValue] == 100);

    PDLMethodTestClass2 *test2 = [[PDLMethodTestClass2 alloc] init];
    for (NSInteger i = 0; i < 200; i++) {
        test2.i = 0;
        test2.rect = CGRectZero;
    }
    XCTAssert(test2->beforeTimes.count == 2);
    XCTAssert([test2->beforeTimes[@"setI:"] integerValue] == 200);
    XCTAssert([test2->beforeTimes[@"setRect:"] integerValue] == 200);
    XCTAssert([test2->afterTimes[@"setI:"] integerValue] == 200);
    XCTAssert([test2->afterTimes[@"setRect:"] integerValue] == 200);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
