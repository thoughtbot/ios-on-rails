//
//  HUMRailsAFNClient.m
//  Humon
//
//  Created by Diana Zmuda on 11/12/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMRailsAFNClient.h"
#import "HUMUserSession.h"
#import "HUMEvent.h"

static NSString *const HUMAFNAppSecret = @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";

@implementation HUMRailsAFNClient

+ (instancetype)sharedClient
{
    static HUMRailsAFNClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *baseURL = [NSURL URLWithString:ROOT_URL];
        _sharedClient = [[HUMRailsAFNClient alloc] initWithBaseURL:baseURL];

        if ([HUMUserSession userID])
            [_sharedClient.requestSerializer setValue:[HUMUserSession userID]
                                   forHTTPHeaderField:@"X-DEVICE-TOKEN"];
        else
            [_sharedClient.requestSerializer setValue:HUMAFNAppSecret
                                   forHTTPHeaderField:@"X-APP-SECRET"];
        
    });
    
    return _sharedClient;
}

- (void)createCurrentUserWithCompletionBlock:
    (HUMRailsAFNClientErrorCompletionBlock)block
{
    [self POST:@"users" parameters:@{@"device_token" : [HUMUserSession userID]}
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
        [HUMUserSession setUserID:responseObject[@"device_token"]];
        [self.requestSerializer setValue:responseObject[@"device_token"]
                      forHTTPHeaderField:@"X-DEVICE-TOKEN"];
        block(nil);
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           
        block(error);
           
    }];
}

- (void)createEvent:(HUMEvent *)event
    withCompletionBlock:(HUMRailsAFNClientEventCompletionBlock)block
{
    [self POST:@"events"
    parameters:[event JSONDictionary]
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
        NSLog(@"%@", responseObject);
        event.eventID = [NSString stringWithFormat:@"%@", responseObject[@"id"]];
        block(event);
           
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        block(nil);
        
    }];
}

- (void)changeEvent:(HUMEvent *)event
withCompletionBlock:(HUMRailsAFNClientEventCompletionBlock)block
{
    [self PATCH:@"events"
    parameters:[event JSONDictionary]
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
           NSLog(@"%@", responseObject);
           block(event);
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           
           block(nil);
           
       }];
}

- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block
{
    NSDictionary *parameters = @{
                               @"lat" : @(region.center.latitude),
                               @"lon" : @(region.center.longitude),
                               @"radius" : @(region.span.latitudeDelta/2*111)
                               };
    
    return [self GET:@"events/nearest"
          parameters:parameters
             success:^(NSURLSessionDataTask *task, id responseObject) {
          
            NSArray *events;
            if ([responseObject isKindOfClass:[NSArray class]])
                events = [HUMEvent eventsWithJSON:responseObject];
            block(events);
                 
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
            block(nil);
        
    }];
}

- (void)createAttendanceForEvent:(HUMEvent *)event withCompletionBlock:(HUMRailsAFNClientErrorCompletionBlock)block
{
    [self POST:@"attendances" parameters:@{@"event" : @{@"id" : @5}, @"user" : @{@"device_token" : [HUMUserSession userID]}} success:^(NSURLSessionDataTask *task, id responseObject) {
        block(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(error);
    }];
}

@end
