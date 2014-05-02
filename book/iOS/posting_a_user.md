# Posting a User With NSURLSession

Now that we have a singleton `HUMRailsClient` object and a configured session property on that object, we can create NSURLSessionTasks that will actually make our API request. 

### Declaring a Task for Making Requests

Declare a method in our HUMRailsClient.h that creates a POST request to /users.

	- (void)createCurrentUserWithCompletionBlock:
		(void (^)(NSError *error))block;

The type of our parameter for this method is a block, which we declare here with `(void (^)(NSError *error))`. Declaring a block as our parameter type is similar to how we declare other parameter types like `(NSString *)`, where the word following the type is the name of the parameter. This block has a return type of `void` and an argument of type `NSError` so we can check if the POST completed with an error.

It makes sense to typedef a new name for our completion block so that we can refer to it more easily, especially if we plan on using this block type again. Typedef-ing allows us to define a new name for an existing type, which in this case will be the new name `HUMRailsClientErrorCompletionBlock` for the block type `(void (^)(NSError *error))`. Place this typedef above the interface in HUMRailsClient.h:

	typedef void(^HUMRailsClientErrorCompletionBlock)(NSError *error);
	
The block that we typedef is the same as the block we previously declared, so now we can declare the method `createCurrentUserWithCompletionBlock:` as so:

	- (void)createCurrentUserWithCompletionBlock:
		(HUMRailsClientErrorCompletionBlock)block;

The [Apple developer library](https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/Blocks/Articles/bxDeclaringCreating.html#//apple_ref/doc/uid/TP40007502-CH4-SW1) has an in-depth section on declaring blocks in Objective C, for those interested.

### Creating a Task for Making Requests

Now that we have declared `createCurrentUserWithCompletionBlock:` and typedef-ed its completion block, we can define the method.

	// HUMRailsClient.m
	
	- (void)createCurrentUserWithCompletionBlock:
		(HUMRailsClientCompletionBlock)block
	{
    	// Create a request for the POST to /users
    	NSString *urlString = [NSString stringWithFormat:@"%@/users", ROOT_URL];
    	NSURL *url = [NSURL URLWithString:urlString];
    	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    	[request setHTTPMethod:@"POST"];
    	
    	// Create a task to encapsulate your request and a completion block
    	NSURLSessionTask *task = [self.session dataTaskWithRequest:request
                                             	completionHandler:
        	^void (NSData *data, NSURLResponse *response, NSError *error) {
        
        	// Log the error on completion
        	NSLog(@"Request completed with error: %@", error);
        
    	}];
    	
    	[task resume];
	}
	
First, we instantiate a `url` for our request, which in this case is our ROOT_URL (which we set up with a user-defined macro) with /users appended to it. Then we can instantiate a `request` using this URL and set the request method to POST.

Now that we have a `request`, we can create a task for our `self.session` that will execute the request. The method `dataTaskWithRequest:completionHandler:` takes two arguments, the `request` that we created before, and a block that will be run when the request is complete.

The block we pass into the method must be of a type defined by `dataTaskWithRequest:completionHandler:`, so we pass in a block of the appropriate type as an argument with the syntax:

	^void (NSData *data, NSURLResponse *response, NSError *error) { 
		// code to execute
	}

Where the block's return type is `void` and that the block's parameters are `data`, `response`, and `error`. We don't have to explicitly declare the void return type, since it can be inferred, which means we could instead use the syntax:

	^(NSData *data, NSURLResponse *response, NSError *error) { 
		// code to execute
	}

Finally, we fire off the task by calling the method resume on the task object you just created. 

### Responding to the Completion of the Task

Once the task has completed, the block we just defined will be invoked with the relevant `data`, `response`, and `error` as arguments. Replace the error log in the completion block with the following:

        if (!error) {
        	// Set the user session user ID
            NSDictionary *responseDictionary = [NSJSONSerialization
                                                JSONObjectWithData:data
                                                options:kNilOptions
                                                error:nil];
            [HUMUserSession setUserID:responseDictionary[@"device_token"]];
            
            // Create a new contiguration with the user ID
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
        
        // Execute the block regardless of the error
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });


If there is no error, we can create a dictionary using the response data from the task. This dictionary will contain a device_token that the rails app created to identify the user of this device. Now that we have a device_token from the rails app, we can save it using the `setUserID:` class method on HUMUserSession.

Since we have a new device_token that we want to start sending in we need to create a `newConfiguration` that is a copy of the old configuration, place the device_token in the `newConfiguration`'s header, and set `self.session` to a new session that uses the `newConfiguration`.

Regardless of whether or not there's an error, we want to execute the completion block we passed into the method `createCurrentUserWithCompletionBlock:`. Since we will be updating the UI in this completion block, we have to force the completion block to execute on the main thread using `dispatch_async`. Alternatively, you could use NSOperationQueue to execute the block on the main thread, but since we are just sending off a block I chose to use `dispatch_async`.
