//
//  HUMRailsClient.m
//  Humon
//
//  Created by Diana Zmuda on 11/11/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMRailsClient.h"
#import "HUMUserSession.h"
#import "HUMEvent.h"

static NSString *const HUMAppSecret =
    @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";

@interface HUMRailsClient ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation HUMRailsClient

+ (instancetype)sharedClient
{
    static HUMRailsClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedClient = [[HUMRailsClient alloc] init];
        
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    self = [super init];
    
    if (!self)
        return nil;
    
    NSURLSessionConfiguration *sessionConfiguration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30.0;
    sessionConfiguration.timeoutIntervalForResource = 30.0;
    
    NSDictionary *headers = [HUMUserSession userID] ?
        @{
          @"Accept" : @"application/json",
          @"Content-Type" : @"application/json",
          @"X-DEVICE-TOKEN" : [HUMUserSession userID]
          } :
        @{
          @"Accept" : @"application/json",
          @"Content-Type" : @"application/json",
          @"X-APP-SECRET" : HUMAppSecret
          };
    [sessionConfiguration setHTTPAdditionalHeaders:headers];
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    return self;
}

- (void)createCurrentUserWithCompletionBlock:
    (HUMRailsClientErrorCompletionBlock)block
{
    // Will be taken out later
    NSDictionary *json = @{@"device_token" : [HUMUserSession userID]};
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/users", ROOT_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];

    // Will be taken out later
    [request setHTTPBody:JSONdata];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                             completionHandler:
        ^void (NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *responseDictionary = [NSJSONSerialization
                                                JSONObjectWithData:data
                                                options:kNilOptions
                                                error:nil];
            [HUMUserSession setUserID:responseDictionary[@"device_token"]];
            
            NSURLSessionConfiguration *newConfiguration =
                self.session.configuration;
            [newConfiguration setHTTPAdditionalHeaders:
                @{
                    @"Accept" : @"application/json",
                    @"Content-Type" : @"application/json",
                    @"X-DEVICE-TOKEN" : responseDictionary[@"device_token"]
                }];
            self.session = [NSURLSession sessionWithConfiguration:
                            newConfiguration];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });
        
    }];
    [task resume];
}

- (void)createEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientEventCompletionBlock)block
{
    NSData *JSONdata = [NSJSONSerialization
                        dataWithJSONObject:[event JSONDictionary]
                        options:0
                        error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/events", ROOT_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:JSONdata];
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                            NSError *error) {
        
        HUMEvent *responseEvent = nil;
                                                 
        if (!error) {
            responseEvent = event;
            NSDictionary *responseDictionary =[NSJSONSerialization
                                               JSONObjectWithData:data
                                               options:kNilOptions
                                               error:nil];
            responseEvent.eventID = [NSString stringWithFormat:@"%@", responseDictionary[@"id"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(responseEvent);
        });
        
    }];
    [task resume];
}

@end
