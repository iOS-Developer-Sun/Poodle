//
//  pdl_pac.m
//  PoodleTests
//
//  Created by zijian.sun on 9/9/22.
//  Copyright © 2022 Poodle. All rights reserved.
//

#import "PoodleTests.h"
#import "pdl_pac.h"

@interface pdl_pac : XCTestCase

@end

@implementation pdl_pac

- (void)setUp {
    ;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    for (NSInteger i = 0; i < 100; i++) {
        void *p = (void *)(unsigned long)arc4random();

        void *a = pdl_ptrauth_sign_unauthenticated_function(p, &p);
        void *a1 = pdl_ptrauth_strip_function(a);
        void *a2 = pdl_ptrauth_auth_function(a, &p);
        XCTAssert(p != a);
        XCTAssert(p == a1);
        XCTAssert(p == a2);

        void *b = pdl_ptrauth_sign_unauthenticated_data(p, &p);
        void *b1 = pdl_ptrauth_strip_data(b);
        void *b2 = pdl_ptrauth_auth_data(b, &p);
        XCTAssert(p != b);
        XCTAssert(p == b1);
        XCTAssert(p == b2);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
