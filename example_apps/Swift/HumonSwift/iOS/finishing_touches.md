# Finishing Touches

Now that we've created an app that can interact with our API using the POST and GET methods 
we can think about implementing more features. 

These features are currently implemented in the sample app 
so feel free to reference the code there if you choose to try any of these.

1. Implement unit tests using Kiwi or the built-in XCTest. Tests in both languages are included in the example app for you to reference.

2. Use [Auto Layout](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/index.html) on all the views in the app so the app can be used in landscape.

3. Add a confirmation view controller that pushes onto the nav stack after you POST to users, with a button that lets you share your event to Facebook and Twitter.

4. Add a `user` property to the Event class. Then you can conditionally let the user PATCH an event if they are the owner.

5. Implement a POST to attendences method to let a user indicate they plan to attend an event.

6. Add custom map pin images and pick a tint color for your app.

7. Insert a date picker into the table view, rather than having it pop up from the bottom as the `textView`'s `-inputView`.

8. Prevent the user from attempting to POST an event if they haven't filled out the required fields. Ignore optional fields when you're determining validity.

9. Let the user pick any location, not just their current location. Use geocoding to automatically fill out the address for that location.

10. Use a different date formatter to format all the user-facing dates in a human-readable format.
