# A Rails API Client With NSURLSession

### Creating a Singleton Client Object

Create a subclass of `NSObject` called `HUMRailsClient`. All of our API requests will be handled by one instance of the `HUMRailsClient`, so we're going to create a singleton of `HUMRailsClient`. 

What we will create and refer to as a singleton isn't a dictionary-definition singleton, since we aren't completely limiting the instantiation of HUMRailsClient to only one object. We are, however, limiting the instantiation of HUMRailsClient to only one object if we always use our sharedClient. Essentially, our sharedClient is a singleton if we use it consistently but it is not if we errantly decide to instantiate another instance of HUMRailsClient using `[[HUMRailsClient alloc] init]`.

Declare a class method that will return our singleton by adding `+ (instancetype)sharedClient;` to your `HUMRailsClient.h` file. We use `instancetype` as our return type to indicate that this class method will return an instance of `HUMRailsClient`. The + indicates that `sharedClient` is a class method to be called directly on the `HUMRailsClient` class. Prepending your class method with "shared" indicates to other developers that the method returns a singleton.

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

First, we declare a static variable of type `HUMRailsClient`. Since it's a static variable, `_sharedClient` will last for the life of the program.

Then, we use Grand Central Dispatch to execute a block of code once and only once. If you are using Xcode and begin typing `dispatch_once`, you can even use autocomplete to find and insert the entire `dispatch_once` code snippet. `dispatch_once` takes a reference to a static variable of type `dispatch_once_t` and a block of code to execute. `dispatch_once_t` is a long variable type that indicates whether the block of code has already been executed. On the first call of `dispatch_once`, the `onceToken` is set and the block executed, but on every subsequent call the block is not executed because the onceToken has already been set.

Inside the block we instantiate a `HUMRailsClient` and set it as the value of the static variable `_sharedClient`. Once that is done, we simply need to return our singleton `_sharedClient`.

### Creating a Session for Handling Requests

iOS 7 introduced the `NSURLSession` class, which is an object that handles groups of HTTP requests. Each API request we make in a NSURLSession is encapsulated in a `NSURLSessionTask`, which executes the request asynchronously and notifies you of completion by executing a block or by calling a method on its delegate.

There are three different types of `NSURLSession` objects, including one that allows your app to continue downloading data even if the app is in the background. The type of a session is determined by its `sessionConfiguration`, but for simple API requests we only need to use the default session type.

Declare a session property of the default `NSURLSession` class on your `HUMRailsClient`. We will also need a static app secret string and static root url string to communicate with our Rails app. Add these above your `@implementation` inside `HUMRailsClient.m`.

	// HUMRailsClient.m
	
	static NSString *const HUMAppSecret =
	    @"yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret";
	static NSString *const HUMRootURL = @"https://humon-staging.herokuapp.com/v1/";
	
	@interface HUMRailsClient ()
	
	@property (strong, nonatomic) NSURLSession *session;
	
	@end

We will use the `HUMAppSecret` to sign POST requests to /users so the backend can validate that the request is coming from our mobile app. The session object will handle all of our API requests.

We want our `HUMRailsClient` to always have a session object, so we will overwrite the `HUMRailsClient`'s `-init` method to set the client's `session` property.

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
    
So, our `HUMRailsClient`'s custom `-init` method will look like:

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
        
This custom `-init` method first creates a `sessionConfiguration`. We could just use the default `NSURLSessionConfiguration` that is returned from `NSURLSessionConfiguration`'s class method `defaultSessionConfiguration` to create our `NSURLSession`. However, we also want to change our timeout properties to 30 seconds and add some HTTP headers.

Next, we use that `sessionConfiguration` to create an `NSURLSession`, and set that session as the `_session` property on our singleton.

### Setting the Session Headers

Setting the session headers on the `sessionConfiguration` is particularly important. The custom session headers include our app secret, which is needed for POSTing to the users endpoint. The headers also indicate that our content type is JSON.

	// HUMRailsClient.m
	
	- (instancetype)init
	{
	    ...
	    
	    NSDictionary *headers = @{
	          @"Accept" : @"application/json",
	          @"Content-Type" : @"application/json",
	          @"tb-app-secret" : HUMAppSecret
	          };
	    [sessionConfiguration setHTTPAdditionalHeaders:headers];
	    
	    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
	    
	    return self;
	}

Other requests (such as POSTing to the events endpoint) will require the session headers to contain a user's auth token. Later, we will conditionally set the HTTP additional headers based on whether we have a user's auth token stored.
