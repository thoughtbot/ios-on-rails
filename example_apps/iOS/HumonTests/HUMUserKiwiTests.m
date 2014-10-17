//
//  HUMUserKiwiTests.m
//  Humon
//
//  Created by Diana Zmuda on 12/20/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "Kiwi.h"
#import "HUMUser.h"
#import "HUMUserSession.h"

SPEC_BEGIN(HUMUserSpec)

describe(@"User object", ^{
    
    __block HUMUser *user;
    __block NSNumber *userID = @123;
    
    beforeAll(^{
        user = [[HUMUser alloc] initWithJSON:@{@"id" : userID}];
    });
    
    it(@"should not be nil", ^{
        [[user shouldNot] beNil];
    });
    
    it(@"should have the correct ID", ^{
        [[user.userID should] equal:@"123"];
    });

    it(@"should match ID to current user", ^{
        [HUMUserSession setUserID:userID];
        BOOL isCurrentUser = [user isCurrentUser];
        [[theValue(isCurrentUser) should] equal:theValue(YES)];
    });
    
});

SPEC_END
