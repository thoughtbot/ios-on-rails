# Posting an Event With AFNetworking

Now let's POST an event using AFNetworking.

### Declaring a Task for Making Requests

The completion block we'll use for our create event method should return an event ID and an error. If our request is successful, the API will return the event ID for the event it created. If our request fails, we'll return the error instead.

Typedef this new type of event completion block:

	// HUMRailsAFNClient.h

	typedef void(^HUMRailsAFNClientEventIDCompletionBlock)(NSString *eventID, NSError *error);

and declare the event creation method:

	// HUMRailsAFNClient.h

	- (void)createEvent:(HUMEvent *)event
        	withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block;

### Creating a Task for Making Requests

With AFNetworking, making a POST request with a dictionary of parameters is quite easy. We call the `POST:parameters:success:failure` method and provide the `@"events"` path, the event's JSON dictionary, and a success and failure block. 

Don't forget to `#import "HUMEvent.h"` since we need to use the method `JSONDictionary` we previously defined.

	// HUMRailsClient.m
	
	- (void)createEvent:(HUMEvent *)event
	    withCompletionBlock:(HUMRailsAFNClientEventIDCompletionBlock)block
	{
	    [self POST:@"events"
	    parameters:[event JSONDictionary]
	       success:^(NSURLSessionDataTask *task, id responseObject) {
	           
	        NSString *eventID = [NSString stringWithFormat:@"%@",
	                             responseObject[@"id"]];
	        block(eventID, nil);
	           
	    } failure:^(NSURLSessionDataTask *task, NSError *error) {
	        
	        block(nil, error);
	        
	    }];
	}

In the case of success, we want to return the `eventID` that we receive back from the API. If there's a failure, we execute the completion block with the `error` we receive. We don't have to worry about forcing the completion block to the main thread since the success and failure blocks are fired off on the main thread.

