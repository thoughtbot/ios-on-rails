# The Mobile App's Skeleton

The Humon app is going to have 2 view controllers, which we will create empty versions of now.

1. The initial view will contain a large map with pins for events that are near you, events you've created, and events you are tracking. It will also contain a button for adding a new event.

2. The views for creating and viewing an event will be very similar. The entire view will be filled with a table which has space for the address, name, and time of an event.

	Creating and viewing will be handled by distinct view controller classes but each of these will be a subclass of and overarching event view controller class.

