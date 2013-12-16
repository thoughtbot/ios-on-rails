## The Mobile App's Skeleton

The Humon app is going to have 3 distinct view controller types, which we will create empty versions of now.

1. The initial view will contain a large map with pins for events that are near you, events you've created, and events you are tracking. It will also contain a button for adding a new event.

2. The views for creating, viewing, and editing an event will be very similar. The entire view will be filled with a table which allows the user to change the address, name, and time of an event or to simply view these properties.

	Creating, viewing, and editing will be handled by distinct view controller classes but each of these will use the same classes of table view cells.

3. The last view will display after the user creates an event to confirm that it has been posted using our API. A button will allow users to post the event to social media sites using a standard activity view controller.

