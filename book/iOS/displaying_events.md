# Displaying Events on the Map

### Calling the Get Event Method

When the user runs the app, we want to display events that are near their current location. So, we want to call our GET events method on `viewDidAppear` of the HUMMapViewController. We'll encapsulate this request inside a method called `reloadEventsOnMap`, which we will define in the next section.

If we aren't logged in, we still want to call the `createCurrentUserWithCompletionBlock:` method. Once that request goes through, we can call `reloadEventsOnMap`.

If we are logged in we can go ahead and just call `[self reloadEventsOnMap]`.

	// HUMMapViewController.m

	- (void)viewDidAppear:(BOOL)animated
	{
	    [super viewDidAppear:animated];
	
	    if (![HUMUserSession userIsLoggedIn]) {
	        
	        [SVProgressHUD showWithStatus:
	            NSLocalizedString(@"Loading Events", nil)];
	
	        [[HUMRailsClient sharedClient]
	            createCurrentUserWithCompletionBlock:^(NSError *error) {
	
	            if (error) {
	                [SVProgressHUD showErrorWithStatus:
	                    NSLocalizedString(@"App authentication error", nil)];
	            } else {
	                [SVProgressHUD dismiss];
	                [self reloadEventsOnMap];
	            }
	
	        }];
	        
	    } else {
	        [self reloadEventsOnMap];
	    }
	}
	
We also want to make a new GET request when the user changes the map's region. The delegate method `mapView:regionDidChangeAnimated:` will be called whenever the user pans or zooms the map, so let's call the `reloadEventsOnMap` method there as well.

	// HUMMapViewController.m

    - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
    {
        [self reloadEventsOnMap];
    }

### Cancelling Get Event Tasks

We call our new `reloadEventsOnMap` method from the HUMMapViewController every time the map moves. This way, we'll always display events in the map area that the user is viewing. However, if the user moves the map to a new area before the API call completes, we want to cancel the previous task since it's for a map area that the user is no longer viewing. So, we'll make a `currentEventGetTask` property which will represent the current and only GET events task that we are running.

	// HUMMapViewController.m
	
	@property (strong, nonatomic) NSURLSessionDataTask *currentEventGetTask;
	
Now we can define the `reloadEventsOnMap` method for making the GET API call and updating the map.

	// HUMMapViewController.m

    - (void)reloadEventsOnMap
    {
	    if (![HUMUserSession userIsLoggedIn]) {
	        return;
	    }
        
        [self.currentEventGetTask cancel];
        self.currentEventGetTask = [[HUMRailsClient sharedClient]
                                    fetchEventsInRegion:self.mapView.region
                                    withCompletionBlock:^(NSArray *events, NSError *error) {
                                        
	        if (events) {
	            self.currentEventGetTask = nil;
	            [self updateMapViewAnnotationsWithAnnotations:events];
	        }
            
        }];
    }

Before creating a new task with `fetchEventsInRegion:withCompletionBlock:`, we need to cancel the previous task. That way we'll limit this view controller to one in-process task for events in the current area. Any unfinished tasks for areas that are not being displayed will be cancelled.

Once a task is finished, remove it from the self.currentEventGetTask property since it's not current and doesn't need to be cancelled if we move the map again. 

Finally, we can call `updateMapViewAnnotationsWithAnnotations:` to update the `mapView` with our new events.

### Updating the Map with New Events

Now we'll define the `updateMapViewAnnotationsWithAnnotations:` method that we called in the `reloadEventsOnMap` method.

Each time we get a new array of annotations from the API, we want to remove the old annotations from our `mapView` and add the new ones. However, if an old annotations is the same as a new one, there's no sense in removing it and then placing it back on the map. Removing and adding only the annotations that are necessary reduces the amount of redrawing that's done every time the map pans, leading to a smoother scrolling experience.

This method (from a [thoughtbot blog post](http://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps/) on displaying annotations on MKMapViews) handles removing, adding, and keeping annotations as necessary.
    
    // HUMMapViewController.m

    - (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
    {
        NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
        NSSet *after = [NSSet setWithArray:annotations];
        
        NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
        [toKeep intersectSet:after];
        
        NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
        [toAdd minusSet:toKeep];
        
        NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
        [toRemove minusSet:after];
        
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }
    
Taking advantage of the `intersectSet:` and `minusSet:` methods lets us create a set of annotations `toAdd` and a set `toRemove`. For a deeper explanation of this method, go ahead and read the full article.
    
### Checking Event Equality

The set methods `intersectSet:` and `minusSet:` call the method `isEqual` on each NSObject in the set. So, we need to overwrite this method on HUMEvent.

	// HUMEvent.m

    - (BOOL)isEqual:(id)object
    {
        if (self == object)
            return YES;
        
        if (![self isKindOfClass:[object class]])
            return NO;
        
        HUMEvent *event = (HUMEvent *)object;
        
        BOOL objectsHaveSameID =
            [self.eventID isEqualToNumber:event.eventID];
        BOOL objectsHaveSameUser =
            [self.userID isEqualToString:event.userID];
        
        return objectsHaveSameID && objectsHaveSameUser;
    }

If an `object` and `self` (which is an object of type HUMEvent) are both pointing to the same object, they are definitely equal. If `object` and `self` are not of the same class, then they are definitely not equal.

Two HUMEvent objects are the same if they have the same `eventID` from the server and the same `userID` from the user who created the event. We're basing equality on these properties because these are the only event properties that never change.

Since we overwrote `isEqual:`, we must overwrite `hash` on HUMEvent. This is straight from the documentation, since two objects that are equal must have the same hash.

	// HUMEvent.m

    - (NSUInteger)hash
    {
        if (!self.eventID)
            return [super hash];
        
        NSString *hashString = [NSString stringWithFormat:
                                @"%@%@",
                                self.eventID,
                                self.userID];
        return [hashString hash];
    }

If our event doesn't have an `eventID`, we can just return the normal hash returned by `[super hash]`. If it does, our hash will be based on the two properties that we are basing equality on.

With these two methods implemented on HUMEvent, we can run the application in the simulator and the map will display any events that we have already created.
