## Posting a User With AFNetworking

Now that we've created a method for enqueueing a task manually, lets use the AFNetworking framework to simplify things. We'll create a method on our `HUMRailsAFNClient` to POST to /users.

### Declaring a Task for Making Requests

Before we declare the method for user creation, let's typedef a new name for a completion block type. This time, we'll typedef the block type `(void (^)(NSError *error))` as `HUMRailsAFNClientErrorCompletionBlock`. Place this typedef above the interface in HUMRailsAFNClient.h:

	typedef void(^HUMRailsAFNClientErrorCompletionBlock)(NSError *error);
	
Now we can declare the `createCurrentUserWithCompletionBlock:` method in HUMRailsAFNClient.h.

	- (void)createCurrentUserWithCompletionBlock:
		(HUMRailsAFNClientErrorCompletionBlock)block;

### Creating a Task for Making Requests

When defining the method `createCurrentUserWithCompletionBlock:`, we can use one of the convenient methods that we inherit from AFHTTPSessionManager to create and execute a task.

	// HUMRailsAFNClient.m

    - (void)createCurrentUserWithCompletionBlock:
        (HUMRailsAFNClientErrorCompletionBlock)block
    {
        [self POST:@"users" parameters:@{@"device_token" : @"435353"}
           success:^(NSURLSessionDataTask *task, id responseObject) {
               
            [HUMUserSession setUserID:responseObject[@"device_token"]];
            [self.requestSerializer setValue:responseObject[@"device_token"]
                          forHTTPHeaderField:@"X-DEVICE-TOKEN"];
            block(nil);
               
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               
            block(error);
               
        }];
    }

The method is called `POST:parameters:success:failure:` and takes four arguments.

1. The path that we're POSTing to is `@"users"`, which will be appended to our ROOT_URL that we set when initializing the client.

2. The parameters for this POST request are `nil`, since the HTTPHeaderField contains our HUMAppSecret. We don't need to send any additional data for this specific POST request.

3. A completion block that will execute if the request is successful. If the request is successful we set the current user's ID to the device_token we get back from the API. We also set the device_token in the header field so we can start signing our requests as that user. Finally, we execute the completion block with `nil` as an argument since we have no error.

4. A completion block that executes if there was an error when executing the POST task. This completion block executes the completion block we provided, with the `error` as an argument to indicate that our POST wasn't successful.

### Making the POST Request

We want to make a POST request to create and save a user only once on each device. So, lets conditionally call the `createCurrentUserWithCompletionBlock:` we just created inside of HUMMapViewController's `viewDidAppear:` method.

	- (void)viewDidAppear:(BOOL)animated
	{
    	[super viewDidAppear:animated];

    	if (![HUMUserSession userID]) {
        
        	[SVProgressHUD show];
        
        	[[HUMRailsAFNClient sharedClient] 
        		createCurrentUserWithCompletionBlock:^(NSError *error) {
            
            	[SVProgressHUD dismiss];
            
        	}];
        
    	}
	}

If there's no `currentUserID` in the keychain, then we haven't successfully made a POST request to /users. So, we can call `createCurrentUserWithCompletionBlock:` to make our POST request, save the user ID that returns from the API request, and change the request headers to include this user ID.

We'll also present a heads-up-display to users to indicate that an API call is in progress. SVProgressHUD is a cocoapod that provides a clean and easy to use view for showing loading and percent completion. We simply call the SVProgressHUD class method `show` to display the HUD, and `dismiss` to remove it.

If you run the app and get back a completionBlock with no error, you've officially made a successful POST request and created a user on the database!
