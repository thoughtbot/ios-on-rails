@class HUMEvent, HUMEvent;
@import MapKit;

typedef void(^HUMRailsClientErrorCompletionBlock)(NSError *error);
typedef void(^HUMRailsClientEventIDCompletionBlock)(NSString *eventID, NSError *error);
typedef void(^HUMRailsClientEventsCompletionBlock)(NSArray *events, NSError *error);

@interface HUMRailsClient : NSObject

+ (instancetype)sharedClient;
- (void)createCurrentUserWithCompletionBlock:
        (HUMRailsClientErrorCompletionBlock)block;
- (void)createEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block;
- (void)changeEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block;
- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        withCompletionBlock:(HUMRailsClientEventsCompletionBlock)block;
- (void)createAttendanceForEvent:(HUMEvent *)event
        withCompletionBlock:(HUMRailsClientErrorCompletionBlock)block;

@end
