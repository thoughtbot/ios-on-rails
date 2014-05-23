//
//  HUMUserSession.h
//  Humon
//
//  Created by Diana Zmuda on 12/4/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

@class HUMUser;

@interface HUMUserSession : NSObject

+ (NSString *)userID;
+ (void)setUserID:(NSString *)userID;

@end
