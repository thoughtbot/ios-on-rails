#import "Kiwi.h"
#import "HUMUserSession.h"
#import "HUMUser.h"

SPEC_BEGIN(HUMUserSessionSpec)

describe(@"User session object", ^{

    __block NSNumber *userID = @123;
    __block NSString *userToken = @"fakeUserToken";
    
    it(@"should set the user ID", ^{
        [HUMUserSession setUserID:userID];
        NSString *currentUserID = [HUMUserSession userID];
        [[currentUserID should] equal:@"123"];
    });

    it(@"should remove the user ID", ^{
        [HUMUserSession setUserID:nil];
        NSString *currentUserID = [HUMUserSession userID];
        [[currentUserID should] beNil];
    });

    it(@"should set the user token", ^{
        [HUMUserSession setUserToken:userToken];
        NSString *currentUserToken = [HUMUserSession userToken];
        [[currentUserToken should] equal:userToken];
    });

    it(@"should remove the user token", ^{
        [HUMUserSession setUserID:nil];
        NSString *currentUserToken = [HUMUserSession userID];
        [[currentUserToken should] beNil];
    });

    it(@"should determine if the user is logged in", ^{
        [HUMUserSession setUserID:userID];
        [HUMUserSession setUserToken:userToken];
        BOOL userLoggedIn = [HUMUserSession userIsLoggedIn];
        [[theValue(userLoggedIn) should] equal:theValue(YES)];
    });

    it(@"should determine if the user is logged out", ^{
        [HUMUserSession setUserID:nil];
        [HUMUserSession setUserToken:nil];
        BOOL userLoggedIn = [HUMUserSession userIsLoggedIn];
        [[theValue(userLoggedIn) should] equal:theValue(NO)];
    });

});

SPEC_END
