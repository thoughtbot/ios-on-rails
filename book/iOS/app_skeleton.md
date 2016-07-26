# The Mobile App's Skeleton

The Humon app is going to have two view controllers:

1. The initial view will be a large map view with pins for events that are near you. It will also contain a button for creating a new event.

2. The views for creating and viewing an event will be very similar. The view will be a table with cells for the address, name, and time of an event. The only difference is that the text fields for creating an event will be editable.

We can either create our view controllers programatically or use Storyboards. 
For the purposes of this book, we will be creating all our view controllers programatically. 
Storyboards are incredibly useful tools for visually laying out an app's view controllers, 
but learning about Interface Builder is out of scope for this book. 
Apple provides a good introduction to Interface Builder and 
[Storyboards](https://developer.apple.com/library/ios/recipes/xcode_help-IB_storyboard/_index.html)
 in their Developer Library.

To use programatically created view controllers instead of the Storyboard 
provided by Xcode:

1. Delete the Main.storyboard file in the file navigator. Choose "Move to Trash" rather than just "Remove Reference".

2. Select the Humon project in the file navigator. Select the Humon target and under the "Info" tab, delete the "Main storyboard file base name". This will remove the reference to the Storyboard you deleted.

![Delete the Storyboard from the Info Plist](images/ios_new_xcode_project_3.png)
