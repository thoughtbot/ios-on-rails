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

@implementation HUMUserSession

+ (NSString *)userID
{
    NSString *userID = [SSKeychain passwordForService:@"Humon"
                                              account:@"currentUserID"];

    if (!userID) {
        userID = [[NSUUID UUID] UUIDString];
        [self setUserID:userID];
    }

    return userID;
}

+ (void)setUserID:(NSString *)userID
{
    if (!userID) {
        return;
    }

    [SSKeychain setPassword:userID
                 forService:@"Humon"
                    account:@"currentUserID"];
}

+ (BOOL)userMatchesCurrentUserSession:(HUMUser *)user
{
    return [user.userID isEqualToString:[HUMUserSession userID]];
}

@end
