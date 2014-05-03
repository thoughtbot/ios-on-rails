# The User Object

Rather than having a user create an account and log in, we're going to create a user object on the first run of the app and then consistantly sign our requests as this user. The user entity on the database has only one property: device_token. You can think of this device_token as a user ID, since our users are identified by their device rather than an email address or username.

### Creating the User Object

Each user is going to have one property, which is their user ID. In our case, the user's ID will be their device token which we get back from the rails app. When we make a POST request to /users, the backend confirms that we sent the correct app secret, creates a new user account with a new device_token, and returns the account's device_token so we can use it to sign all our requests. Typically, your user entity will have a separate user_id and user_token so you can use one for publically identifying a user and the other for privately signing requests, but we will treat our device_token as a hybrid of the two.

Create a new subclass of NSObject for the user and define a property and two instance methods.

	// HUMUser.h
	
	@interface HUMUser : NSObject
	
	@property (strong, nonatomic) NSNumber *userID;

	- (id)initWithJSON:(NSDictionary *)JSONDictionary;

	@end
	
When we receive a user's JSON back from the database, we could just [[HUMUser alloc] init] and set the user's properties. However, creating a custom init method `initWithJSON:` makes instantiating a `HUMUser` much easier.

	// HUMUser.m

	- (id)initWithJSON:(NSDictionary *)JSONDictionary
	{
    	self = [super init];
    
    	if (!self)
        return nil;
    
    	_userID = JSONDictionary[@"id"];
    	
    	return self;
	}

The custom init method calls super's init method and sets self to the return value. If the object can't be initialized it returns nil, otherwise it just sets the `_userID` and returns self.

### Creating the User Session Object

Create another subclass of NSObject called HUMUserSession. This object will manage our current user's session, which means it will be responsible for keeping track of the user ID that we'll be signing our requests with.

The interface for our user session manager should contain 3 class methods:

	// HUMUserSession.h
	
    @class HUMUser;

    @interface HUMUserSession : NSObject

    + (NSNumber *)userID;
    + (void)setUserID:(NSNumber *)userID;
    + (BOOL)userMatchesCurrentUserSession:(HUMUser *)user;

    @end

The first two class methods are for getting and setting the current user's ID. These methods will access the keychain to keep track of the current user's ID.

Every event that we create will have a user object that it belongs to. So, we need some way of checking if an event's user is the current user. The `currentUserMatchesUser:` method will be used to check if the current user should be able to edit an event.

Let's implement the two class methods for getting and setting the user's session ID.

	// HUMUser.m

    + (NSNumber *)userID
    {
        NSString *userIDString = [SSKeychain passwordForService:@"Humon"
                                                        account:@"currentUserID"];
        return [NSNumber numberWithInteger:userIDString.integerValue];
    }

    + (void)setUserID:(NSNumber *)userID
    {
        NSString *userIDString = [NSString stringWithFormat:@"%@", userID];
        [SSKeychain setPassword:userIDString
                     forService:@"Humon"
                        account:@"currentUserID"];
    }

We'll be using the SSKeychain framework here to save the user ID to the keychain and retrieve it, so be sure to place `#import <SSKeychain/SSKeychain.h>` at the top of `HUMUser.h` or in your prefix file.

Finally, let's implement a method for `userMatchesCurrentUserSession:`. It's a simple check if the current user's ID matches the ID of the `user` object in question.

	// HUMUser.m
	
    + (BOOL)userMatchesCurrentUserSession:(HUMUser *)user
    {
        return [user.userID isEqualToNumber:[HUMUserSession userID]];
    }
