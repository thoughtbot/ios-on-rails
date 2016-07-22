# A Rails API Client With NSURLSession

### Creating a Client Class

Create a new file and declare a new class called `HumonClient`. All of our API requests will be handled by an instance of this class.

Our client class will need three different properties: a session, a base URL and an app secret.

	// HumonClient.swift
	
	import Foundation
	
	class HumonClient {
	
    	var session: NSURLSession
    	let baseURL = NSURL(string: "https://humon-staging.herokuapp.com/v1/")
    	let appSecret = "yourOwnUniqueAppSecretThatYouShouldRandomlyGenerateAndKeepSecret"
    
    }

You should see an error informing you that the `HumonClient` class has no initializers. Let's fix that.

### Creating a Session for Handling Requests

Our client's initializer needs to set a value for the `session` property because the `session` property doesn't have a default value.

So, declare and implement an init method that creates a session object.
	
	// HumonClient.swift
	
    init() {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        configuration.HTTPAdditionalHeaders = [
        	"tb-app-secret": "yourOwnAppSecret",
        	"Content-Type": "application/json",
        	"Accept" : "application/json"
        ]
        session = NSURLSession(configuration: configuration)
    }
    
First, we create a `configuration` that is ephemeral, meaning it doesn't persist cookies and caching. Then we set some custom additional headers, including the `tb-app-secret`. Later, we will switch between headers depending on what keys we need, but for now we are using the headers required for a POST to the /users endpoint.

Finally, we create a `session` of class `NSURLSession`.

The `NSURLSession` class handle groups of requests, called `NSURLRequests`. Each request we make is encapsulated in a `NSURLSessionTask`. The task executes the request asynchronously and notifies you of completion by executing a block or calling a method on its delegate.

There are three different types of `NSURLSession` objects, including one that allows your app to continue downloading data even if the app is in the background. The type of a session is determined by its `sessionConfiguration`, but for simple API requests we only need to use the default session type.

