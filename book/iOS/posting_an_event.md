# Posting an Event With NSURLSession

Our `HUMRailsClient` is already all set up to use the appropriate headers that we need for POST to events: namely, the token we receive back from POST to users. So we simply need to define a new method for making a POST to events request.

### Declaring a Task for Making Requests

The completion block we'll use for our create event method should return either an event ID or an error. If our request is successful, the API will return the event ID for the event it created. If our request fails, we'll return the error instead.

Typedef this new type of event completion block:

	// HUMRailsClient.h

	typedef void(^HUMRailsClientEventIDCompletionBlock)(NSString *eventID, NSError *error);

and declare the event creation method:

	// HUMRailsClient.h

	- (void)createEvent:(HUMEvent *)event
        	withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block;

### Creating a Task for Making Requests

Define the event creation method as follows:

	// HUMRailsClient.m    
	
	- (void)createEvent:(HUMEvent *)event
	        withCompletionBlock:(HUMRailsClientEventIDCompletionBlock)block
	{
	    NSData *JSONdata = [NSJSONSerialization
	                        dataWithJSONObject:[event JSONDictionary]
	                        options:kNilOptions
	                        error:nil];
	    
	    NSString *urlString = [NSString stringWithFormat:@"%@events", ROOT_URL];
	    NSURL *url = [NSURL URLWithString:urlString];
	    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
	    [request setHTTPMethod:@"POST"];
	    
	    NSURLSessionUploadTask *task = [self.session uploadTaskWithRequest:request
	    fromData:JSONdata
	    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
	    
	    // See the section 'Handle the Response'
	        
	    }];
	    [task resume];
	}
	
This POST /events method is slightly different from the POST /users method we created before.

1. We need to serialize a JSON dictionary of required event information into data so we can set that as the POST request data. This is why we created the method `[event JSONDictionary]` on our event object.

2. We don't need to change the headers at all. When we call `createEvent:withCompletionBlock:`, we have already set the headers to include the current user's ID with `createCurrentUserWithCompletionBlock:`.
    
### Handle the Response

Now that we've serialized the event's JSON dictionary, created a POST request, and created a task to handle that request, we can fill in the completion block. Replace the error log in `task`'s completion block with the following:

	// HUMRailsClient.m
	
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

If the task completes without an error, we can serialize the data we receive into a dictionary and set the event's ID from that response dictionary. 

If the the task completes with an error, `eventID` will remain nil. 

Either way, we want to execute the completion block on the main queue, since the block will be updating the UI. The completion block will return either an updated event or an error, depending on whether the POST was successful.

