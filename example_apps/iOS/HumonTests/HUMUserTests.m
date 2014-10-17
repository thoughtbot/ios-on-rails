//
//  HUMUserTests.m
//  Humon
//
//  Created by Diana Zmuda on 1/7/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HUMUser.h"
#import "HUMUserSession.h"

@interface HUMUserTests : XCTestCase

@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) HUMUser *user;

@end

@implementation HUMUserTests

- (void)setUp
{
    [super setUp];
    self.userID = @123;
    self.user = [[HUMUser alloc] initWithJSON:@{@"id" : self.userID}];
    [HUMUserSession setUserID:self.userID];
}

- (void)testNotNil
{
    XCTAssertNotNil(self.user, @"User object should not be nil");
}

- (void)testID
{
    XCTAssertEqualObjects(self.user.userID, @"123",
                          @"User ID should equal '123'");
}

- (void)testIsCurrentUser
{
    [HUMUserSession setUserID:self.userID];
    BOOL isCurrentUser = [self.user isCurrentUser];
    XCTAssertTrue(isCurrentUser, @"User ID should match current user ID");
}

@end
