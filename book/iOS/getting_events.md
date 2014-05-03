# Getting Events from the API

When the user runs the app, we want to display events that are near their current location. So, let's create a GET task that will return event objects that we can place on the `mapView`.

### Making the Event Object a Map View Annotation

Since we now want to place event objects as pins on a MKMapView, we need to make our HUMEvent class conform to the `<MKAnnotation>` protocol. This protocol has three properties (coordinate, title, subtitle) that correspond to where the pin is placed and the text in the pin's callout view.

Change the HUMEvent `@interface` to declare that the class conforms to this protocol like so:

	// HUMEvent.h

	@interface HUMEvent : NSObject <MKAnnotation>
	
Since we have already declared a `coordinate` property, we just need to add the `title` and `subtitle`.

	// HUMEvent.h

	// Properties used for placing the event on a map
	@property (copy, nonatomic) NSString *title;
	@property (copy, nonatomic) NSString *subtitle;
	@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
	
We want the title and subtitle in an event's callout view to display the event name and address, so overwrite the getter methods for title and subtitle:

	// HUMEvent.m

	- (NSString *)title
	{
    	return self.name;
	}

	- (NSString *)subtitle
	{
    	return self.address;
	}

Now, our event objects can be placed directly on our `mapView`.

### Making the Get Event Task

To make the event GET request, typedef a completion block that will return an array of events once we receive event JSON from the API.

	//HUMRailsAFNClient.h
	
	typedef void(^HUMRailsAFNClientEventsCompletionBlock)(NSArray *events);
	
Then declare a method for fetching events whose parameters are a map region and a completion block of this new type. The map region will be the visible map region in our HUMMapViewController, since we only want to load events within the region we're viewing. Unlike our other API client methods, we'll return an `NSURLSessionDataTask` from this method so we can cancel the task.

	//HUMRailsAFNClient.h
	
	- (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
        	withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block;

Now we can implement this method:

	// HUMRailsAFNClient.m
	
    - (NSURLSessionDataTask *)fetchEventsInRegion:(MKCoordinateRegion)region
            withCompletionBlock:(HUMRailsAFNClientEventsCompletionBlock)block
    {
        NSDictionary *parameters = @{
                                   @"lat" : @(region.center.latitude),
                                   @"lon" : @(region.center.longitude),
                                   @"radius" : @(region.span.latitudeDelta/2*111)
                                   };
        
        return [self GET:@"events/nearest"
              parameters:parameters
                 success:^(NSURLSessionDataTask *task, id responseObject) {
              
                NSArray *events;
                if ([responseObject isKindOfClass:[NSArray class]])
                    events = [HUMEvent eventsWithJSON:responseObject];
                block(events);
                     
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  
                block(nil);
            
        }];
    }
    
The `parameters` for our GET request contain `lat`, `lon`, and `radius`. The rails app will use these values to return a list of events that are less than the `radius` (in kilometers) away from the map region's centerpoint.

We want to inscribe our square `mapView` span inside of our circular API search area so that we're receiving more events than need to be displayed, rather than too few. We use half the width of the `mapView` (the `latitudeDelta`  property) as our radius since the lateral span is the larger value in portrait. Multiplying by 111 is simply the conversion from latitudinal degrees to kilometers.

Since our rails API returns from a successful GET request with a "No events in area" dictionary or an array of event JSON, our success block has to handle both cases. If we receive an array, we execute the completion block with an array of events, otherwise `events` will be `nil`.

In our failure block, we simply execute our completion block with a `nil` argument.

### Calling the Get Event Method

We'll call our new `fetchEventsInRegion:withCompletionBlock:` method from the HUMMapViewController every time the map moves. This way, we'll make an API call for and display events in the map area that the user is viewing. However, if the user moves the map to a new area before the API call completes, we want to cancel the previous task since it's for a map area that the user is no longer viewing. So, we'll make a `currentEventGetTask` property which will represent the current and only GET /events task that we are running.

	// HUMMapViewController.m
	
	@property (strong, nonatomic) NSURLSessionDataTask *currentEventGetTask;
	
Now we can define a method for making the GET API call and updating the map.

	// HUMMapViewController.m

    - (void)reloadEventsOnMap
    {
        if (![HUMUserSession userID])
            return;
        
        [self.currentEventGetTask cancel];
        self.currentEventGetTask = [[HUMRailsAFNClient sharedClient]
                                    fetchEventsInRegion:self.mapView.region
                                    withCompletionBlock:^(NSArray *events) {
                                        
            self.currentEventGetTask = nil;
            [self updateMapViewAnnotationsWithAnnotations:events];
            
        }];
    }

We can only fire off API calls if we've already created a user, since we need to sign our GET requests with a user's `[HUMUserSession userID]`.

Before creating a new task with `fetchEventsInRegion:withCompletionBlock:`, we need to cancel the previous task. That way we'll limit this view controller to one in-process task for events in the current area. Any unfinished tasks for areas that are not being displayed will be cancelled.

Once a GET /events task is finished, remove it from the self.currentEventGetTask property since it's not current and doesn't need to be cancelled if we move the map again. 

Finally, we can call `updateMapViewAnnotationsWithAnnotations:` (which we'll define later) to update the `mapView` with our new events.

Let's call this `reloadEventsOnMap` method on the first appearance of the map view controller:

	// HUMMapViewController.m

    - (void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];

        if (![HUMUser currentUserID]) {
            
            [SVProgressHUD show];
            
            [[HUMRailsAFNClient sharedClient]
                createCurrentUserWithCompletionBlock:^(NSError *error) {
                
                if (error)
                    [SVProgressHUD showErrorWithStatus:@"App authentication error"];
                else {
                    [SVProgressHUD dismiss];
                    [self reloadEventsOnMap];
                }
                
            }];
        }
        
        else
            [self reloadEventsOnMap];
    }

As we were doing before before, we'll make a check to see if the user has already POSTed a user to the database. If they haven't, we'll call the `createCurrentUserWithCompletionBlock` method to create a user and call `reloadEventsOnMap` if user creation was successful. If the user already exists, we can simply call `reloadEventsOnMap` to make an /events GET request. 

We also want to make a new GET request when the user changes the map's region. The delegate method `mapView:regionDidChangeAnimated:` will be called whenever the user pans or zooms the map, so let's call the `reloadEventsOnMap` method there as well.

	// HUMMapViewController.m

    - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
    {
        [self reloadEventsOnMap];
    }

### Updating the Map with New Events

Now we'll define the `updateMapViewAnnotationsWithAnnotations:` method that we called in the `reloadEventsOnMap` method.

Each time we get a new array of annotations from the API, we want to remove the old annotations from our `mapView` and add the new ones. However, if an old annotations is the same as a new one, there's no sense in removing it and then placing it back on the map. Removing and adding only the annotations that are necessary reduces the amount of redrawing that's done every time the map pans, leading to a smoother scrolling experience.

This method (from a recent [thoughtbot article](http://robots.thoughtbot.com/how-to-handle-large-amounts-of-data-on-maps/) on displaying annotations on MKMapViews) handles removing, adding, and keeping annotations as necessary.
    
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
    
Taking advantage of the `intersectSet:` and `minusSet:` methods lets us create a set of annotations `toAdd` and a set `toRemove`. For a deeper explanation of this method, please read the full article.
    
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
            [self.user.userID isEqualToString:event.user.userID];
        
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
                                self.user.userID];
        return [hashString hash];
    }

If our event doesn't have an `eventID`, we can just return the normal hash returned by `[super hash]`. If it does, our hash will be based on the two properties that we are basing equality on.

With these two methods implemented on HUMEvent, we can run the application in the simulator and the map will display any events that we have already created.
