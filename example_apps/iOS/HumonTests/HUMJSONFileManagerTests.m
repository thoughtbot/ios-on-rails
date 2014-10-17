//
//  HUMJSONFileManagerTests.m
//  Humon
//
//  Created by Diana Zmuda on 6/11/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HUMJSONFileManager.h"

@interface HUMJSONFileManagerTests : XCTestCase

@end

@implementation HUMJSONFileManagerTests

- (void)testSingleEventDictionary
{
    NSDictionary *event = [HUMJSONFileManager singleEventJSON];
    XCTAssertEqual(event.count, 8,
                   @"Should initialize single event JSON from file");
}

- (void)testMultipleEventArray
{
    NSArray *events = [HUMJSONFileManager multipleEventsJSON];
    XCTAssertEqual(events.count, 2,
                   @"Should initialize multiple events JSON from file");
}

@end
