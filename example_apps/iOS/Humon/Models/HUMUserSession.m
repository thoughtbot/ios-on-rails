//
//  HUMUserSession.m
//  Humon
//
//  Created by Diana Zmuda on 12/4/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMUserSession.h"
#import <SSKeychain/SSKeychain.h>
#import "HUMUser.h"
#import "NSObject+HUMNullCheck.h"

static NSString *const HUMService = @"Humon";
static NSString *const HUMUserID = @"currentUserID";
static NSString *const HUMUserToken = @"currentUserToken";


@implementation HUMUserSession

+ (NSString *)userID
{
    NSString *userID = [SSKeychain passwordForService:HUMService
                                              account:HUMUserID];

    return userID;
}

+ (NSString *)userToken
{
    NSString *userToken = [SSKeychain passwordForService:HUMService
                                                 account:HUMUserToken];

    return userToken;
}

+ (void)setUserID:(NSNumber *)userID
{
    if (!userID || ![userID hum_isNotNull]) {
        [SSKeychain deletePasswordForService:HUMService account:HUMUserID];
        return;
    }

    NSString *IDstring = [NSString stringWithFormat:@"%@", userID];
    NSError *error;
    [SSKeychain setPassword:IDstring
                 forService:HUMService
                    account:HUMUserID
                      error:&error];
    if (error) {
        NSLog(@"USER ID SAVE ERROR: %@", error);
    }
}

+ (void)setUserToken:(NSString *)userToken
{
    if (!userToken || ![userToken hum_isNotNull]) {
        [SSKeychain deletePasswordForService:HUMService account:HUMUserToken];
        return;
    }

    NSError *error;
    [SSKeychain setPassword:userToken
                 forService:HUMService
                    account:HUMUserToken
                      error:&error];
    if (error) {
        NSLog(@"USER TOKEN SAVE ERROR: %@", error);
    }
}

+ (BOOL)userIsLoggedIn
{
    BOOL hasUserID = [self userID] ? YES : NO;
    BOOL hasUserToken = [self userToken] ? YES : NO;
    return hasUserID && hasUserToken;
}

@end
