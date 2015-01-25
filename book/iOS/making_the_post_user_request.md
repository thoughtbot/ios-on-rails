# Making the POST User Request

We want to make a POST request to create and save a user only once on each device. So, let's conditionally call the `createCurrentUserWithCompletionBlock:` we just created inside HUMMapViewController's `viewDidAppear:` method. Remember to `#import "HUMRailsClient.h"` or `#import "HUMRailsAFNClient.h"`, whichever one you choose to use.

	// HUMMapViewController.m

	- (void)viewDidAppear:(BOOL)animated
	{
    	[super viewDidAppear:animated];

    	if (![HUMUserSession userIsLoggedIn]) {
        
        	[SVProgressHUD show];
        
        	// We could also make this request using our AFN client.
        	// [[HUMRailsAFNClient sharedClient]
        	[[HUMRailsClient sharedClient] 
        		createCurrentUserWithCompletionBlock:^(NSError *error) {
            
	            if (error) {
	                [SVProgressHUD showErrorWithStatus:
	                    NSLocalizedString(@"App authentication error", nil)];
	            } else {
	                [SVProgressHUD dismiss];
	            }
            
        	}];
        
    	}
	}

If `[HUMUserSession userIsLoggedIn]` returns `NO`, then we haven't successfully made a POST request to /users. So we can call `createCurrentUserWithCompletionBlock:` to make our POST request. This saves the user ID that returns from the API request and also changes the request headers to include this user ID.

We'll also present a heads-up-display to users to indicate that an API call is in progress. SVProgressHUD is a Cocoapod that provides a clean and easy-to-use view for showing loading and percent completion. We simply call the SVProgressHUD class method `show` to display the HUD, and `dismiss` to remove it. Remember to `#import <SVProgressHUD/SVProgressHUD.h>` since we're using it in this file.

If you run the app and get back a completionBlock with no error, you've officially made a successful POST request and created a user on the database!
