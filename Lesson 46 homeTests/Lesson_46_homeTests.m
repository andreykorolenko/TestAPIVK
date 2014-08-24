//
//  Lesson_46_homeTests.m
//  Lesson 46 homeTests
//
//  Created by Андрей on 24.07.14.
//  Copyright (c) 2014 Andrey Korolenko. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Lesson_46_homeTests : XCTestCase

@end

@implementation Lesson_46_homeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
