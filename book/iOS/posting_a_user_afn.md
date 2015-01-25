# Posting a User With AFNetworking

Now that we've created a method for enqueueing a task manually, let's use the AFNetworking framework to simplify things. We'll create a method on our `HUMRailsAFNClient` to POST to /users.

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
               
	        [HUMUserSession setUserID:responseObject[@"id"]];
	        [HUMUserSession setUserToken:responseObject[@"device_token"]];
	        [self.requestSerializer setValue:responseObject[@"device_token"]
	                         forHTTPHeaderField:@"tb-device-token"];
            block(nil);
               
           } failure:^(NSURLSessionDataTask *task, NSError *error) {
               
            block(error);
               
        }];
    }

The method is called `POST:parameters:success:failure:` and takes four arguments.

1. The path that we're POSTing to is `@"users"`, which will be appended to our ROOT_URL that we set when initializing the client.

2. The parameters for this POST request are `nil`, since the HTTPHeaderField contains our HUMAppSecret. We don't need to send any additional data for this specific POST request.

3. A completion block that will execute if the request is successful. If the request is successful we set the current user's ID and token to what we got back in the `responseObject`. We also set the device_token in the header field so we can start signing our requests as that user. Finally, we execute the completion block with `nil` as an argument since we have no error.

4. A completion block that executes if there was an error when executing the POST task. This completion block executes the completion block we provided, with the `error` as an argument to indicate that our POST wasn't successful.

### Setting the Headers Conditionally

Now that we have a POST to users method and persist the token we recieve from this method, we can conditionally set our session's headers depending on whether we have that token yet.

Currently, our singleton sets a new `tb-device-token` and the `tb-app-secret` in the session's headers every time it initializes. These are the correct headers for POST to users, but we need different headers for all other reqeusts.

In the `sharedClient` method of our `HUMRailsClient`, change the `dispatch_once` block to contain:

	// HUMRailsAFNClient.m
	
    NSURL *baseURL = [NSURL URLWithString:ROOT_URL];
    _sharedClient = [[HUMRailsAFNClient alloc] initWithBaseURL:baseURL];

    if ([HUMUserSession userIsLoggedIn]) {
        [_sharedClient.requestSerializer setValue:[HUMUserSession userToken]
                               forHTTPHeaderField:@"tb-device-token"];
    } else {
        [_sharedClient.requestSerializer setValue:HUMAFNAppSecret
                               forHTTPHeaderField:@"tb-app-secret"];
        [_sharedClient.requestSerializer setValue:[[NSUUID UUID] UUIDString]
                               forHTTPHeaderField:@"tb-device-token"];
    }
          
This if statement depends on the class methods `userIsLoggedIn` and `userToken` that we defined on `HUMUserSession`, so remember to `#import "HUMUserSession.h"` at the top of the file. It sets the headers to include the saved `[HUMUserSession userToken]` if we are logged in. If we aren't logged in, it setsthe app secret random device token.
