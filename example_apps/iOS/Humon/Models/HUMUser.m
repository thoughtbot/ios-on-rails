//
//  HUMUser.m
//  Humon
//
//  Created by Diana Zmuda on 11/14/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMUser.h"

@implementation HUMUser

- (id)initWithJSON:(NSDictionary *)JSONDictionary
{
    self = [super init];
    
    if (!self)
        return nil;
    
    _userID = JSONDictionary[@"id"];
    
    return self;
}

@end
