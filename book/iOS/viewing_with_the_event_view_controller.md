# Viewing Individual Events

### Showing a Callout for an Event

Since we want to place event objects as pins on a `MKMapView`, we need to make sure our `HUMEvent` class conforms to the `<MKAnnotation>` protocol. We already declared the required property, `coordinate`, which corresponds to where the pin is placed. Now we can set the text in the pin's callout view.

Check the `HUMEvent` `@interface` to confirm that it conforms to this protocol.

	// HUMEvent.h
	
	@import MapKit;
	
	@interface HUMEvent : NSObject <MKAnnotation>
	
Since we already declared a `coordinate` property, we just need to add the `title` and `subtitle`.

	// HUMEvent.h

	// Properties used for placing the event on a map
	@property (copy, nonatomic) NSString *title;
	@property (copy, nonatomic) NSString *subtitle;
	@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
	
We want the title and subtitle in an event's callout view to display the event's name and address, so overwrite the getter methods for `-title` and `-subtitle`.

	// HUMEvent.m

	- (NSString *)title
	{
    	return self.name;
	}

	- (NSString *)subtitle
	{
    	return self.address;
	}

Now, once we place our event objects on our `mapView`, they'll display their event information when we tap on the annotation.

### Pushing an Event View Controller

In addition, we want to present a read-only `HUMEventViewController` when we tap on a annotation. When we hit the back button, we'll still see the annotation callout reminding us which event we tapped.

Presenting the `HUMEventViewController` means responding to the mapView delegate method `-mapView:didSelectAnnotationView:`. As long as the annotation is a `HUMEvent` object, we want to push a new view controller with that object.

	// HUMMapViewController.m

	- (void)mapView:(MKMapView *)mapView
	    didSelectAnnotationView:(MKAnnotationView *)view
	{
	    if ([view.annotation isKindOfClass:[HUMEvent class]]) {
	        HUMEvent *event = view.annotation;
	        [self.navigationController pushViewController:
	        	[[HUMEventViewController alloc] initWithEvent:event]
											          animated:YES];
	
	    }
	}

### Removing the Submit Button when Viewing

In order to prevent users from interacting with the "Submit" button on the `HUMEventViewController`, we simply need to change the method that determines the number of rows in the table view. If our view controller is meant to be editable, return the number of cells that includes the "Submit" button. Otherwise, return one less than that.

	// HUMEventViewController.m

	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	    if (self.editable) {
	        return HUMEventCellCount;
	    } else {
	        return HUMEventCellCount - 1;
	    }
	}

Now you should be able to tap on an annotation and see the appropriate read-only view.
