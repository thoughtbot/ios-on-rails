# The User Object

Our app doesn't require username/password login. Instead, we will create a user object on the app's first run and then consistantly sign our requests as this user. This behavior is useful for apps that don't require login, or have some sort of guest mode.

The user entity on the database has two relevant properties: `auth_token` and `id`. We will use the auth token to sign our user's requests, and we will use the ID to compare users.

### Creating the User Session Object

When we make a POST request to /users, the backend confirms that we sent the correct app secret, creates a new user with an `auth_token`, and returns the account's ID and token. 

Create a subclass of `NSObject` called `HUMUserSession`. This object will manage the current user's session. That means it will be responsible for keeping track of one user ID and one `auth_token` that we'll be signing our requests with.

The interface for our user session manager should contain 5 class methods:

	// HUMUserSession.h
	
    @class HUMUser;

    @interface HUMUserSession : NSObject

	+ (NSString *)userID;
	+ (NSString *)userToken;
	+ (void)setUserID:(NSNumber *)userID;
	+ (void)setUserToken:(NSString *)userToken;
	+ (BOOL)userIsLoggedIn;

    @end

The first four class methods are for getting and setting the current user's ID and token. These methods will access the keychain to keep track of this information. We want to use the keychain whenever we are storing sensitive information, like the user's token.

Since we're using SSKeychain, we'll want to create a few static strings above our `@implementation`. Don't forget to `#import <SSKeychain/SSKeychain.h>` at the top of the file as well.

	// HUMUserSession.m

	static NSString *const HUMService = @"Humon";
	static NSString *const HUMUserID = @"currentUserID";
	static NSString *const HUMUserToken = @"currentUserToken";

Now we can use these strings as keys when querying the keychain for our `userID` and `userToken`.

	// HUMUserSession.m

	+ (NSString *)userID
	{
	    NSString *userID = [SSKeychain passwordForService:HUMService
	                                              account:HUMUserID];
	
	    return userID;
	}
	
	+ (NSString *)userToken
	{
	    NSString *userToken = [SSKeychain passwordForService:HUMService
	                                                 account:HUMUserToken];
	
	    return userToken;
	}

Next we'll want to implement the methods we defined for setting our ID and token.

	// HUMUserSession.m
	
	+ (void)setUserID:(NSNumber *)userID
	{
	    if (!userID) {
	        [SSKeychain deletePasswordForService:HUMService account:HUMUserID];
	        return;
	    }
	
	    NSString *IDString = [NSString stringWithFormat:@"%@", userID];
	    [SSKeychain setPassword:IDString
	                 forService:HUMService
	                    account:HUMUserID
	                      error:nil];
	}
	
	+ (void)setUserToken:(NSString *)userToken
	{
	    if (!userToken) {
	        [SSKeychain deletePasswordForService:HUMService account:HUMUserToken];
	        return;
	    }
	
	    [SSKeychain setPassword:userToken
	                 forService:HUMService
	                    account:HUMUserToken
	                      error:nil];
	}

You'll notice that we created an `IDString` with `[NSString stringWithFormat:@"%@", userID]`. This is because our `userID` returned from the API is a number, while we need a string `IDString` password to store in the keychain.

Finally, we need to implement the method that we will use in our client singleton to determine if we currently have a valid user session. It's easiest to think of this as whether the user is logged in.

	// HUMUserSession.m

	+ (BOOL)userIsLoggedIn
	{
	    BOOL hasUserID = [self userID] ? YES : NO;
	    BOOL hasUserToken = [self userToken] ? YES : NO;
	    return hasUserID && hasUserToken;
	}
	
Now we can use this `userIsLoggedIn` method to determine if we need to make a POST to users, and to determine what headers we need in our API client.
