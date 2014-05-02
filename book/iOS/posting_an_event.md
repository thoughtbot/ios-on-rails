# Posting an Event With NSURLSession

We have already defined a `sharedClient` of our `HUMRailsClient` to use for making POST /users requests. So, we simply need to define a new method for making POST /events requests.

### Declaring a Task for Making Requests

Once we complete a request to POST an event, we want to return the event that we just posted. The /events POST request will return an event ID from the rails API, so we'll set this ID on the event object before returning it.

Typedef this new type of event completion block:

	// HUMRailsClient.h

	typedef void(^HUMRailsClientEventCompletionBlock)(HUMEvent *event);

and declare the event creation method:

	// HUMRailsClient.h

	- (void)createEvent:(HUMEvent *)event
        	withCompletionBlock:(HUMRailsClientEventCompletionBlock)block;

### Creating a Task for Making Requests

This POST /events method is slightly different from the POST /users method we created before.

1. We need to serialize a JSON dictionary of event information into data so we can `setHTTPBody:` on the request.

2. We don't need to change the headers at all. When we call `createEvent:withCompletionBlock:`, we have already set the headers to include the current user's ID with `createCurrentUserWithCompletionBlock:`.

Define the event creation method as follows:

	// HUMRailsClient.m    
	
	- (void)createEvent:(HUMEvent *)event 
    		withCompletionBlock:(HUMRailsClientEventCompletionBlock)block
    {
    	// Serialize the event's JSON dictionary into data
        NSData *JSONdata = [NSJSONSerialization
                            dataWithJSONObject:[event JSONDictionary]
                            options:0
                            error:nil];
        
        // Create the event POST request
        NSString *urlString = [NSString stringWithFormat:@"%@/events", ROOT_URL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:JSONdata];
        
        // Create and start a task
        NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data,
                                                            NSURLResponse *response,
                                                                NSError *error) {
            // Log the error on completion
        	NSLog(@"Post event error: %@", error);
                
        }];
        
        [task resume];
    }  }

Now that we've serialized the event's JSON dictionary, created a POST request, and created a task to handle that request, we can fill in the completion block. Replace the error log in `task`'s completion block with the following:

	// HUMRailsClient.m
	
    HUMEvent *responseEvent = nil;
                                             
    if (!error) {
        responseEvent = event;
        NSDictionary *responseDictionary =[NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:kNilOptions
                                           error:nil];
        responseEvent.eventID = responseDictionary[@"id"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        block(responseEvent);
    });

If the task completes without an error, we can serialize the data we receive into a dictionary and set the event's ID from that response dictionary. If the the task completes with an error, `responseEvent` will remain nil. Either way, we want to execute the block on the main queue, since the block will be updating the UI. The completion block will return either an updated event or nil depending on whether or not the POST was successful.

