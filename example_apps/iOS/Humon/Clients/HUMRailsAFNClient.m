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

        if ([HUMUserSession userID]) {
            [_sharedClient.requestSerializer setValue:[HUMUserSession userID]
                                   forHTTPHeaderField:@"X-DEVICE-TOKEN"];
        } else {
            [_sharedClient.requestSerializer setValue:HUMAFNAppSecret
                                   forHTTPHeaderField:@"X-APP-SECRET"];
        }
        
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
    withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block
{
    [self POST:@"events"
    parameters:[event JSONDictionary]
       success:^(NSURLSessionDataTask *task, id responseObject) {
           
        NSLog(@"%@", responseObject);
        NSString *eventID = [NSString stringWithFormat:@"%@",responseObject[@"id"]];
        block(eventID, nil);
           
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        block(nil, error);
        
    }];
}

- (void)changeEvent:(HUMEvent *)event
withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block
{
    NSString *path = [NSString stringWithFormat:@"events/%@", event.eventID];

    [self PATCH:path
     parameters:[event JSONDictionary]
        success:^(NSURLSessionDataTask *task, id responseObject) {

            NSLog(@"%@", responseObject);
            NSString *eventID = [NSString stringWithFormat:@"%@",responseObject[@"id"]];
            block(eventID, nil);
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           
           block(nil, error);
           
       }];
}

- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block
{
    // region.span.latitudeDelta/2*111 is how we find the aproximate radius  that the screen is displaying in km.
    NSDictionary *parameters = @{
                               @"lat" : @(region.center.latitude),
                               @"lon" : @(region.center.longitude),
                               @"radius" : @(region.span.latitudeDelta/2*111)
                               };
    
    return [self GET:@"events/nearest"
          parameters:parameters
             success:^(NSURLSessionDataTask *task, id responseObject) {
          
            NSArray *events;
            if ([responseObject isKindOfClass:[NSArray class]]) {
                events = [HUMEvent eventsWithJSON:responseObject];
            }
            block(events, nil);
                 
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              
            block(nil, error);
        
    }];
}

- (void)createAttendanceForEvent:(HUMEvent *)event
             withCompletionBlock:(HUMRailsAFNClientErrorCompletionBlock)block
{
    NSDictionary *parameters = @{@"event" :
                                    @{@"id" : event.eventID},
                                 @"user" :
                                    @{@"device_token" : [HUMUserSession userID]}
                                 };
    [self POST:@"attendances"
    parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
        block(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(error);
    }];
}

@end
