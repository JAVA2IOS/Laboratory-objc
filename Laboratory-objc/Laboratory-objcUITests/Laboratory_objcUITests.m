//
//  Laboratory_objcUITests.m
//  Laboratory-objcUITests
//
//  Created by qeeniao35 on 2019/1/22.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Laboratory_objcUITests : XCTestCase

@end

@implementation Laboratory_objcUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
