#import "HUMEvent.h"
#import "HUMRailsClient.h"
#import "HUMUserSession.h"

static NSString *const HUMAppSecret =
    @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";
static NSString *const HUMRootURL = @"https://humon-staging.herokuapp.com/v1/";

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
    
    if (!self) {
        return nil;
    }
    
    NSURLSessionConfiguration *sessionConfiguration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30.0;
    sessionConfiguration.timeoutIntervalForResource = 30.0;

    NSDictionary *headers = [HUMUserSession userIsLoggedIn] ?
        @{
          @"Accept" : @"application/json",
          @"Content-Type" : @"application/json",
          @"tb-auth-token" : [HUMUserSession userToken]
          } :
        @{
          @"Accept" : @"application/json",
          @"Content-Type" : @"application/json",
          @"tb-app-secret" : HUMAppSecret
          };
    [sessionConfiguration setHTTPAdditionalHeaders:headers];
    
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    return self;
}

- (void)createCurrentUserWithCompletionBlock:
    (HUMRailsClientErrorCompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"%@users", HUMRootURL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                             completionHandler:
        ^void (NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *responseDictionary = [NSJSONSerialization
                                                JSONObjectWithData:data
                                                options:kNilOptions
                                                error:nil];
            [HUMUserSession setUserToken:responseDictionary[@"auth_token"]];
            [HUMUserSession setUserID:responseDictionary[@"id"]];

            NSURLSessionConfiguration *newConfiguration =
                self.session.configuration;
            [newConfiguration setHTTPAdditionalHeaders:
                @{
                    @"Accept" : @"application/json",
                    @"Content-Type" : @"application/json",
                    @"tb-auth-token" : responseDictionary[@"auth_token"]
                }];
            
            [self.session finishTasksAndInvalidate];
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
        withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block
{
    NSData *JSONdata = [NSJSONSerialization
                        dataWithJSONObject:[event JSONDictionary]
                        options:kNilOptions
                        error:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@events", HUMRootURL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    //[request setHTTPBody:JSONdata];
    
    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:request
    fromData:JSONdata
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSString *eventID;
                                                 
        if (!error) {
            NSDictionary *responseDictionary =[NSJSONSerialization
                                               JSONObjectWithData:data
                                               options:kNilOptions
                                               error:nil];
            eventID = [NSString stringWithFormat:@"%@",
                                     responseDictionary[@"id"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(eventID, error);
        });
        
    }];
    [task resume];
}

- (void)changeEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block
{
    NSData *JSONdata = [NSJSONSerialization
                        dataWithJSONObject:[event JSONDictionary]
                        options:kNilOptions
                        error:nil];

    NSString *urlString = [NSString stringWithFormat:@"%@events/%@",
                           HUMRootURL, event.eventID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    //[request setHTTPBody:JSONdata];

    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:request
    fromData:JSONdata
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSString *eventID;

        if (!error) {
            NSDictionary *responseDictionary =[NSJSONSerialization
                                            JSONObjectWithData:data
                                            options:kNilOptions
                                            error:nil];
            eventID = [NSString stringWithFormat:@"%@",
                                  responseDictionary[@"id"]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            block(eventID, error);
        });

    }];
    [task resume];
}

- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        withCompletionBlock:(HUMRailsClientEventsCompletionBlock)block
{
    // region.span.latitudeDelta/2*111 is how we find the aproximate radius
    // that the screen is displaying in km.
    NSString *parameters = [NSString stringWithFormat:
                            @"?lat=%@&lon=%@&radius=%@",
                            @(region.center.latitude),
                            @(region.center.longitude),
                            @(region.span.latitudeDelta/2*111)];

    NSString *urlString = [NSString stringWithFormat:@"%@events/nearests%@",
                           HUMRootURL, parameters];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSArray *events;

        if (!error) {
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                            error:nil];

            if ([responseJSON isKindOfClass:[NSArray class]]) {
                events = [HUMEvent eventsWithJSON:responseJSON];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            block(events, error);
        });
        
    }];
    [task resume];

    return task;
}

- (void)createAttendanceForEvent:(HUMEvent *)event
             withCompletionBlock:(HUMRailsClientErrorCompletionBlock)block
{
    NSDictionary *json = @{@"event" : @{@"id" : event.eventID}};
    NSData *JSONdata = [NSJSONSerialization dataWithJSONObject:json
                                                       options:0
                                                         error:nil];

    NSString *urlString = [NSString stringWithFormat:@"%@attendances",
                           HUMRootURL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:JSONdata];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                 completionHandler:^(NSData *data,
                                                     NSURLResponse *response,
                                                     NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });
    }];
    [task resume];
}

@end
