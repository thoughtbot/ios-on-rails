# A Rails API Client With NSURLSession

Before we go about making our first API request, we need to decide how we are going to make our networking calls. As mentioned in the Cocoapods chapter, the AFNetworking framework is a clean and reliable solution to making networking requests. We will show examples of using AFNetworking to make your API requests as well as examples of making requests using the built in `NSURLSession`, which all networking libraries are built on top of. AFNetworking brings a lot more to the table than just wrapping up your network requests; but, like a programming planeteer, the choice is yours.

### Creating a Singleton Client Object

Create a subclass of NSObject called HUMRailsClient. All of our API requests will be handled by one instance of the HUMRailsClient, so we're going to create a singleton of HUMRailsClient called sharedClient. 

What we will create and refer to as a singleton isn't a dictionary-definition singleton, since we aren't completely limiting the instantiation of HUMRailsClient to only one object. We are, however, limiting the instantiation of HUMRailsClient to only one object if we always use our sharedClient. Essentially, our sharedClient is a singleton if we use it consistantly but is not if we errantly decide to instantiate another instance of HUMRailsClient using `[[HUMRailsClient alloc] init]`.

Declare a class method that will return our singleton by adding `+ (instancetype)sharedClient;` to your HUMRailsClient.h file. We use instancetype as our return type to indicate that this class method will return an instance of HUMRailsClient. The + indicates that sharedClient is a class method to be called directly on the HUMRailsClient class. Prepending your class method with "shared" indicates to other developers that the method returns a singleton.

Now let's implement this method:
	
	// HUMRailsClient.m
	
	+ (instancetype)sharedClient
	{
    	static HUMRailsClient *_sharedClient = nil;
    	
    	static dispatch_once_t onceToken;
    	dispatch_once(&onceToken, ^{
    	
    		// Code to be run only once
        	_sharedClient = [[HUMRailsClient alloc] init];
        	
    	});
    
    	return _sharedClient;
	}

First, we declare a static variable of type HUMRailsClient. Since it's a static variable, _sharedClient will last for the life of the program.

Then, we use Grand Central Dispatch to execute a block of code once and only once. If you are using XCode and begin typing dispatch_once, you can even use autocomplete to find and insert the entire dispatch_once code snippet. dispatch_once takes a reference to a static variable of type dispatch_once_t and a block of code to execute. dispatch_once_t is a long variable type that indicates whether or not the block of code has been executed already. On the first call of dispatch_once, the onceToken is set and the block executed, but on every subsequent call the block is not executed because the onceToken has already been set.

Inside the block we instantiate a HUMRailsClient and set it as the value of the static variable _sharedClient. Once that is done, we simply need to return our singleton _sharedClient.

### Creating a Session for Handling Requests

iOS7 introduced the `NSURLSession` class, which is an object that handles groups of HTTP requests. Each API request we make in a NSURLSession is encapsulated in a `NSURLSessionTask`, which executes the request asynchronously and notifies you of completion by executing a block or by calling a method on its delegate.

There are three different types of NSURLSessions, including one that allows your app to continue downloading data even if your app is in the background. The type of a session is determined by its `sessionConfiguration`, but for simple API requests we only need to use the default session type.

Declare a session property and a static app secret string above your @implementation inside of `HUMRailsClient.m`.

	// HUMRailsClient.m
	
	static NSString *const HUMAppSecret =
	    @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";
	
	@interface HUMRailsClient ()
	
	@property (strong, nonatomic) NSURLSession *session;
	
	@end

We will use the `HUMAppSecret` to sign POST requests to /users so that the backend can validate that the request is coming from our mobile app. The session object will handle all of our API requests.

We want our HUMRailsClient to always have a session object, so we will overwrite the HUMRailsClient's `init` method to set the client's `session` property.

Custom init methods all have the same general format:

	- (instancetype)init
	{
	    self = [super init];
	    if (!self) { 
	    	return nil; 
	    }
	    // Do custom init stuff.
	    return self;
    }
    
So, our HUMRailsClient's custom `init` method will look like:

	// HUMRailsClient.m
	
	- (instancetype)init
	{
	    self = [super init];
	    
	    if (!self) {
	        return nil;
	    }
	    
	    NSURLSessionConfiguration *sessionConfiguration =
	        [NSURLSessionConfiguration defaultSessionConfiguration];
	    sessionConfiguration.timeoutIntervalForRequest = 30.0;
	    sessionConfiguration.timeoutIntervalForResource = 30.0;
	    
	    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
	    
	    return self;
	}
        
This custom init method first creates a `sessionConfiguration`. We could just use the default NSURLSessionConfiguration that is returned from NSURLSessionConfiguration's class method `defaultSessionConfiguration` to create our NSURLSession. However, we also want to change our timeout properties to 30 seconds and add some HTTP headers.

Next, we use that `sessionConfiguration` to create an NSURLSession, and set that session as the `_session` property on our singleton.

### Setting the Session Headers

Setting the session headers on the `sessionConfiguration` is particularly important, since sending the app secret and a token is necessary for user creation, and a token is necessary for all other requests. 

	// HUMRailsClient.m
	
	- (instancetype)init
	{
	    ...
	    
	    NSDictionary *headers = @{
	          @"Accept" : @"application/json",
	          @"Content-Type" : @"application/json",
	          @"tb-device-token" : [[NSUUID UUID] UUIDString],
	          @"tb-app-secret" : HUMAppSecret
	          };
	    [sessionConfiguration setHTTPAdditionalHeaders:headers];
	    
	    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
	    
	    return self;
	}

Our custom session headers indicate that our content type is JSON and set the token and app secret. These are the headers that we need for a POST to the users endpoint. For requests other than that we will only need the token.

Currently, we are using a client generated device ID as our token, but our plan is to eventually replace that with an auth token generated by the backend.
