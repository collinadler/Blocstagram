//
//  BLCComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Collin Adler on 11/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCComposeCommentView.h"

@interface BLCComposeCommentViewTests : XCTestCase

@end

@implementation BLCComposeCommentViewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatSetTextYesWorks {
    NSString *testString = @"Test String";
    
    BLCComposeCommentView *testCommentView = [[BLCComposeCommentView alloc] init];
    testCommentView.text = testString;
    
    XCTAssertTrue(testCommentView.isWritingComment == YES);
}

- (void)testThatSetTextNoWorks {
//    NSString *testString = @"Test String";
    
    BLCComposeCommentView *testCommentView = [[BLCComposeCommentView alloc] init];
    
    XCTAssertTrue(testCommentView.isWritingComment == NO);
}

@end
