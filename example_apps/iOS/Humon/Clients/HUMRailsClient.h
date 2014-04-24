//
//  HUMRailsClient.h
//  Humon
//
//  Created by Diana Zmuda on 11/11/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

@class HUMEvent, HUMEvent;

typedef void(^HUMRailsClientErrorCompletionBlock)(NSError *error);
typedef void(^HUMRailsClientEventCompletionBlock)(HUMEvent *event);

@interface HUMRailsClient : NSObject

+ (instancetype)sharedClient;
- (void)createCurrentUserWithCompletionBlock:
        (HUMRailsClientErrorCompletionBlock)block;
- (void)createEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientEventCompletionBlock)block;

@end
