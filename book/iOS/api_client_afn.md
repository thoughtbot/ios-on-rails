# A Rails API Client With AFNetworking

Now that we've created our own networking client, let's see how we could do this using the AFNetworking framework. We'll create another client that is a subclass of AFNetworking's session manager instead of NSObject.

### Creating a Singleton Client Object

Create a subclass of AFHTTPSessionManager called HUMRailsAFNClient. Declare a class method that will return a shared client singleton as we did in our other client by adding `+ (instancetype)sharedClient;` to your HUMRailsAFNClient.h file. The implementation of this method looks similar as well:

	// HUMRailsAFNClient.m
	
    + (instancetype)sharedClient
    {
        static HUMRailsAFNClient *_sharedClient = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            // Create a client
            NSURL *baseURL = [NSURL URLWithString:ROOT_URL];
            _sharedClient = [[HUMRailsAFNClient alloc] initWithBaseURL:baseURL];

			// Set the client header fields
            if ([HUMUserSession userID])
                [_sharedClient.requestSerializer setValue:[HUMUserSession userID]
                                       forHTTPHeaderField:@"X-DEVICE-TOKEN"];
            else
                [_sharedClient.requestSerializer setValue:HUMAppSecret
                                       forHTTPHeaderField:@"X-APP-SECRET"];
            
        });
        
        return _sharedClient;
    }

With AFNetworking, we don't have to manually set up the session configuration and session with our own custom init method. We simply initialize the client using `initWithBaseURL:`, which means that our paths later will be relative to this ROOT_URL.

### Setting the Session Headers

As before, we need to set the user's ID in the header if we have already created a user for this device. If not, we set the app secret so that we can make a POST to /users to create a user with the app secret.
