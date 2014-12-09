# Getting Events With NSURLSession

### Declaring the Get Events Method

To make the event GET request, typedef a completion block that will return an array of events or an error once we receive event JSON from the API.

	//HUMRailsClient.h
	
	typedef void(^HUMRailsClientEventsCompletionBlock)(NSArray *events, NSError *error);
	
Then declare a method for fetching events whose parameters are a map region and a completion block of this new type. The `region` will be the visible map region in our HUMMapViewController, since we only want to load events within the region we're viewing. Unlike our other API client methods, we'll return an `NSURLSessionDataTask` from this method so we can cancel the task.

	//HUMRailsClient.h
	
	- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        	withCompletionBlock:(HUMRailsClientEventsCompletionBlock)block;
        	
### Creating the Get Events Request

Now we can implement this method:

	// HUMRailsClient.m
	
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
	                           ROOT_URL, parameters];
	    NSURL *url = [NSURL URLWithString:urlString];
	    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	    [request setHTTPMethod:@"GET"];
	
		return nil;
	}
    
The `parameters` for our GET request contain `lat`, `lon`, and `radius`. The Rails app will use these values to return a list of events that are less than the `radius` (in kilometers) away from the map region's centerpoint.

We want to inscribe our square `mapView` span inside our circular API search area so we receive more events than need to be displayed, rather than too few. We use half the width of the `mapView` (the `latitudeDelta` property) as our radius since the lateral span is the larger value in portrait mode. Multiplying by 111 is simply the conversion from degrees of latitude to kilometers.
    
### Creating the Get Events Task

Now that we've created the request for fetching events in a region, we can create the actual task.

	// HUMRailsClient.m
	
	- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
	        withCompletionBlock:(HUMRailsClientEventsCompletionBlock)block
	{    
	
		...
	                          
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

Since our rails API returns from a successful GET request with either a "No events in area" dictionary or an array of event JSON, our success block has to handle both cases. If we receive an array, we execute the completion block with an array of events. Otherwise, `events` will be `nil`.

In the case of failure, we simply execute our completion block with an error.

