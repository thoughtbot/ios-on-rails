# Finishing Touches

Now that we've created an app that can interact with our API using the POST and GET methods, we can think about implementing more features. 

These features are currently implemented in the sample app, so feel free to reference the code there if you choose to try any of these.

1) Implement unit tests using Kiwi or the built-in XCTest. Tests in both languages are included in the example app for you to reference.

2) Use [Auto Layout](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Introduction/Introduction.html) on all the views in the app so the app can be used in landscape.

3) Use [AFNetworking](https://github.com/AFNetworking/AFNetworking) to handle your API requests. Chapters on using AFNetworking are included in this book's [GitHub repo.](https://github.com/thoughtbot/ios-on-rails)

4) Add a confirmation view controller that pushes onto the nav stack after you POST to users, with a button that lets you share your event to Facebook and Twitter.

5) Add a user object and set it on each Event object. Then you can let the user PATCH an event if they are the owner.

6) Implement a POST to attendences method to let a user indicate they plan to attend an event.

7) Add custom map pin images and pick a tint color for your app.

8) Insert a date picker into the table view, rather than having it pop up from the bottom as the `textView`'s `-inputView`.

9) Prevent the user from attempting to POST an event if they haven't filled out the required fields. Ignore optional fields when you're determining validity.

10) Let the user pick any location, not just their current location. Use geocoding to automatically fill out the address for that location.

11) Use a different date formatter to format all the user-facing dates in a human-readable format.
