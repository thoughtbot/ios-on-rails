//
//  HUMRailsAFNClient.h
//  Humon
//
//  Created by Diana Zmuda on 11/12/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "AFHTTPSessionManager.h"
@class HUMEvent;
@import MapKit;

typedef void(^HUMRailsAFNClientErrorCompletionBlock)(NSError *error);
typedef void(^HUMRailsAFNClientEventIDCompletionBlock)(NSString *eventID, NSError *error);
typedef void(^HUMRailsAFNClientEventsCompletionBlock)(NSArray *events, NSError *error);

@interface HUMRailsAFNClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
- (void)createCurrentUserWithCompletionBlock:
        (HUMRailsAFNClientErrorCompletionBlock)block;
- (void)createEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block;
- (void)changeEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block;
- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block;
- (void)createAttendanceForEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsAFNClientErrorCompletionBlock)block;

@end
