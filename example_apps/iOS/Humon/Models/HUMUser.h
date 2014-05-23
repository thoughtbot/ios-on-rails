//
//  HUMUser.h
//  Humon
//
//  Created by Diana Zmuda on 11/14/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

@interface HUMUser : NSObject

@property (copy, nonatomic) NSString *userID;

- (id)initWithJSON:(NSDictionary *)JSONDictionary;
- (BOOL)isCurrentUser;

@end
