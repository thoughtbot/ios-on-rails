# Getting Events With AFNetworking

### Declaring the Get Events Method

To make the event GET request, typedef a completion block that will return an array of events or an error once we receive event JSON from the API.

	//HUMRailsAFNClient.h
	
	typedef void(^HUMRailsAFNClientEventsCompletionBlock)(NSArray *events, NSError *error);
	
Then declare a method for fetching events whose parameters are a map region and a completion block of this new type. The map region will be the visible map region in our HUMMapViewController, since we only want to load events within the region we're viewing. Unlike our other API client methods, we'll return an `NSURLSessionDataTask` from this method so we can cancel the task.

	//HUMRailsAFNClient.h
	
	- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        	withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block;
        	
### Creating the Get Events Request

Now we can implement this method:

	// HUMRailsAFNClient.m
	
	- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
	        withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block
	{
	    // region.span.latitudeDelta/2*111 is how we find the aproximate radius
	    // that the screen is displaying in km.
	    NSDictionary *parameters = @{
	                               @"lat" : @(region.center.latitude),
	                               @"lon" : @(region.center.longitude),
	                               @"radius" : @(region.span.latitudeDelta/2*111)
	                               };
	    
	    return [self GET:@"events/nearests"
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
    
The `parameters` for our GET request contain `lat`, `lon`, and `radius`. The rails app will use these values to return a list of events that are less than the `radius` (in kilometers) away from the map region's centerpoint.

We want to inscribe our square `mapView` span inside of our circular API search area so that we're receiving more events than need to be displayed, rather than too few. We use half the width of the `mapView` (the `latitudeDelta`  property) as our radius since the lateral span is the larger value in portrait. Multiplying by 111 is simply the conversion from latitudinal degrees to kilometers.

Since our rails API returns from a successful GET request with a "No events in area" dictionary or an array of event JSON, our success block has to handle both cases. If we receive an array, we execute the completion block with an array of events, otherwise `events` will be `nil`.

In the case of failure, we simply execute our completion block with an error.

