//
//  HUMEventTests.m
//  Humon
//
//  Created by Diana Zmuda on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HUMEvent.h"
#import "HUMJSONFileManager.h"

@interface HUMEventTests : XCTestCase

@property (copy, nonatomic) NSDictionary *JSON;
@property (strong, nonatomic) HUMEvent *event;

@end

@implementation HUMEventTests

- (void)setUp
{
    [super setUp];

    self.JSON = [HUMJSONFileManager singleEventJSON];
    self.event = [[HUMEvent alloc] initWithJSON:self.JSON];
}

- (void)testInitialization
{
    XCTAssertNotNil(self.event, @"Should initialize event with JSON");
}

- (void)testMultipleEventInitialization
{
    NSArray *JSONarray = [HUMJSONFileManager multipleEventsJSON];
    NSArray *eventArray = [HUMEvent eventsWithJSON:JSONarray];
    XCTAssertEqual(eventArray.count, JSONarray.count,
                   @"Should initialize multiple events with JSON");
}

- (void)testJSONGeneration
{
    NSMutableDictionary *desiredJSON = [self.JSON mutableCopy];
    [desiredJSON removeObjectForKey:@"owner"];
    BOOL jsonIsTheSame = [[self.event JSONDictionary]
                          isEqualToDictionary:desiredJSON];
    XCTAssertTrue(jsonIsTheSame, @"Event should return valid JSON");
}

- (void)testHumanReadableString
{
    NSString *readableString = @"Picnic at Dolores Park, 9/15/13, 5:00 PM";
    XCTAssertEqualObjects(self.event.humanReadableString, readableString,
                          @"Event should initialize with JSON");
}

- (void)testEquality
{
    HUMEvent *sameEvent = [[HUMEvent alloc] initWithJSON:self.JSON];
    XCTAssertEqualObjects(self.event, sameEvent,
                          @"Events should be equal with the same ID and user");
}

@end
