# Posting a User With NSURLSession

Now that we have a `HumonClient`, a `NSURLSession` property on that object, and a `UserSession` object, we can create instances of `NSURLSessionTask` that will actually make our API request. 

### Creating a Request

Define a function in our `HumonClient` that creates a POST request to /users.

	// HumonClient.swift
	
    func postUser() {
        let url = NSURL(string: "users", relativeToURL: baseURL)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
    }

First, we create a `url` using the `baseURL` property we definited before. In the example app, this URL would be "https://humon-staging.herokuapp.com/v1/users".

Then, we create a request with that url. Since the `NSURL` init method returns an optional and the `NSMutableURLRequest` init method requires a non-optional, we have to force unwrap our `url` by appending `!`.

Alternatively, we could silently fail if the `url` is nil or return an error. But if our baseURL somehow becomes nil, we likely want the app to crash because that is a fatal error. So, we are using force unwrapping in this case.

### Creating a Task

Now that we have created an `NSURLRequest`, we need to create a task to execute this request.

	// HumonClient.swift
	
    func postUser() {
        ...

        let task = session.dataTaskWithRequest(request) { (data, response, error) in
        
            if let data = data,
                json = (try? NSJSONSerialization.JSONObjectWithData(data,
                    options: [])) as? [String : AnyObject],
                token = json["auth_token"] as? String {
            }
            
        }

        task.resume()
    }
	
The `dataTaskWithRequest` method takes two arguments: the `request` we want to execute and a closure that will be run when the request is complete. We're using trailing closure syntax here, because it's slightly more elegant than the alternative:

	let task = session.dataTaskWithRequest(request, { 
		... 
	})

Inside of the closure, we have access to three parameters. The `data` parameter contains the JSON response that our server sent back. The `response` parameter is helpful for debugging. The `error` parameter will be used later for error handling.

We use the `data` parameter to declare a conditional if-statement that creates multiple optional bindings. Optional bindings are vital when dealing with optionals because they give us a convenient way of finding out if an optional contains a value.

The first optional binding allows us to use `data` without force unwrapping it. `data` is now a non-optional temporary constant that contains the value of the optional `data`. The second optional binding deserializes our `data` into JSON using the `NSJSONSerialization` method `JSONObjectWithData`. It also optionally downcasts the result of that deserialization to a dictionary `[String : AnyObject]`. The third optional binding checks if our dictionary has a value for the key `auth_token` and optionally downcasts the value to a String.

If any of our optional bindings are nil, the closure following the if-statment will not be executed. Using optional binding allows us to access `data`, `json`, and `token` inside of the conditional without force unwrapping them. We'll fill in this if-statement in the next section.

After creating the `task`, we fire it off by calling the method `resume` on the `task`.

### Changing the Headers

Inside of the conditional, we have access to `data`, `json`, and `token`. We'll use these to create a new `configuration` for our `NSURLSession`:

	// HumonClient.swift
	
	...
	
	let task = session.dataTaskWithRequest(request) { [weak self] (data, response, error) in
	
	    if ... {
	        
	        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
	        configuration.HTTPAdditionalHeaders = [
	            "tb-auth-token": token,
	            "Content-Type": "application/json",
	            "Accept" : "application/json"
	        ]
	
	        self?.session.finishTasksAndInvalidate()
	        self?.session = NSURLSession(configuration: configuration)
	    }
    
    }
    
The new `configuration` is much the same as the previous one we created inside the `init` method of `HumonClient`. The only difference is that this configuration's headers contain a `token` value for the `tb-auth-token` key instead of a `tb-app-secret`.

Since the old session's configuration is read-only, we have to create a new session with the new `configuration`, finish the old session's tasks, and set the property `session` to our new session.

Notice that we have added `[weak self]` to our `dataTaskWithRequest` closure. This is to prevent a retain cycle by using a weak reference to self, and necessitates the `self?.session` syntax we see when setting our `session` to a new session. `self?.session` is an example of optional chaining, where attempting to access the `session` property in the case where `self` is nil will not cause a crash.

### Setting the Headers Conditionally

Now that we have a POST to the users endpoint method and we store the token recieved from this method, we can conditionally set our session's headers depending on whether we have a stored auth token.

Currently, our custom init method sets a `tb-app-secret` in our headers every time it initializes. This is the correct header for a POST request to /users, but we need different headers for all our other requests.

In the custom init method of our `HUMRailsClient`, change the `headers` variable to a ternary.
    
This ternary depends on the class methods `+userIsLoggedIn` and `+userToken` that we defined on `HUMUserSession`, so remember to `#import "HUMUserSession.h"` at the top of the file. It sets the headers to include the saved `+[HUMUserSession userToken]` if we are logged in. 

If we aren't logged in, we need to send the app secret so the backend will accept our POST request to create a new user.

### Responding to the Completion of the Task

If there is no error, we can create a dictionary using the response data from the task. This dictionary will contain an `auth_token` and an `id` for a user. We can save these using the class methods we created on `HUMUserSession`.

Now that we have an `auth_token` that is associated with a user in the database, we will use it to sign our requests. Create a `newConfiguration` that is a copy of the old configuration, place the `auth_token` in the `newConfiguration`'s header, and set `self.session` to a new session that uses the `newConfiguration`.

Regardless of whether or not there's an error, we want to execute the completion block we passed into the method `-createCurrentUserWithCompletionBlock:`. Since we will be updating the UI in this completion block, we have to force the completion block to execute on the main thread using `dispatch_async`. Alternatively, you could use `NSOperationQueue` to execute the block on the main thread, but since we are just sending off a block I chose to use `dispatch_async`.

	// HumonClient.swift
	
    func postUser(completion: () -> Void) {
        ...
        
        let task = session.dataTaskWithRequest(request) { [weak self] (data, response, error) in
            if let data = data,
                json = (try? NSJSONSerialization.JSONObjectWithData(data,
                    options: [])) as? [String : AnyObject],
                token = json["auth_token"] as? String {
				...
            }
            dispatch_async(dispatch_get_main_queue()) { completion() }
        }

        task.resume()
    }
