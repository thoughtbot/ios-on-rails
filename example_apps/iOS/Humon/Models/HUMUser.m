//
//  HUMUser.m
//  Humon
//
//  Created by Diana Zmuda on 11/14/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMUser.h"
#import "NSObject+HUMNullCheck.h"
#import "HUMUserSession.h"

@implementation HUMUser

- (id)initWithJSON:(NSDictionary *)JSONDictionary
{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    // TODO: This won't be necessary once the API stops returning owners with NULL tokens
    if ([JSONDictionary[@"device_token"] hum_isNotNull]) {
        _userID = JSONDictionary[@"device_token"];
    }
    
    return self;
}

- (BOOL)isCurrentUser
{
    return [self.userID isEqualToString:[HUMUserSession userID]];
}

@end
