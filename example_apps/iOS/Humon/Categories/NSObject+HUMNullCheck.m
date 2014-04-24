//
//  NSObject+HUMNullCheck.m
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "NSObject+HUMNullCheck.h"

@implementation NSObject (HUMNullCheck)

- (BOOL)isNotNull
{
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    } else {
        return YES;
    }
}

@end
