//
//  PDLBacktrace.m
//  PoodleTests
//
//  Created by zijian.sun on 9/9/22.
//  Copyright © 2022 Poodle. All rights reserved.
//

#import "PoodleTests.h"
#import "PDLBacktrace.h"

@interface PDLBacktraceTest : XCTestCase

@end

@implementation PDLBacktraceTest

- (void)setUp {
    ;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    PDLBacktrace *backtrace = [[PDLBacktrace alloc] init];
    [backtrace record];
    [backtrace show];
    [backtrace hide];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
