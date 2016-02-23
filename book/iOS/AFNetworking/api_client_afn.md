# A Rails API Client With AFNetworking

Now that we've created our own networking client, let's see how we could do this using the AFNetworking framework. We'll create another client that is a subclass of AFNetworking's session manager instead of NSObject.

### Declare the App Secret

As we did in our other client, declare a static string constant above your implementation that is the same app secret that your backend uses.

	// HUMRailsAFNClient.m

	static NSString *const HUMAppSecret =
	    @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";

### Creating a Singleton Client Object

Create a subclass of `AFHTTPSessionManager` called `HUMRailsAFNClient`. Declare a class method that will return a shared client singleton as we did in our other client by adding `+ (instancetype)sharedClient;` to your `HUMRailsAFNClient.h` file. The implementation of this method looks similar as well:

	// HUMRailsAFNClient.m
	
    + (instancetype)sharedClient
    {
        static HUMRailsAFNClient *_sharedClient = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            NSURL *baseURL = [NSURL URLWithString:ROOT_URL];
            _sharedClient = [[HUMRailsAFNClient alloc] initWithBaseURL:baseURL];
            
            [_sharedClient.requestSerializer setValue:HUMAFNAppSecret
                                   forHTTPHeaderField:@"tb-app-secret"];
    
    	});
        
        return _sharedClient;
    }

With AFNetworking, we don't have to manually set up the session configuration and session with our own custom init method. We simply initialize the client using `-initWithBaseURL:`, which means our paths later will be relative to this `ROOT_URL`.

As before, we need to set custom header fields to include the app secret. The app secret is necessary for a POST to users request, and will be replaced by the user's auth token for subsequent request.
