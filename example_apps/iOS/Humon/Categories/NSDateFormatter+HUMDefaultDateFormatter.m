//
//  NSDateFormatter+HUMDefaultDateFormatter.m
//  Humon
//
//  Created by Diana Zmuda on 12/2/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "NSDateFormatter+HUMDefaultDateFormatter.h"

@implementation NSDateFormatter (HUMDefaultDateFormatter)

+ (instancetype)hum_RFC3339DateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc]
                                     initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });

    return dateFormatter;
}

@end
