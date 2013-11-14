## The Initial App Skeleton

### Defining the User Flow

The Humon app is going to have 5 different custom view controllers, which we will create empty versions of now.

![Map View for viewing events](images/ios_app_skeleton_1.jpg)

The initial view will contain a large map with pins for events that are near you, events you've created, and events you are tracking. It will also contain a button for adding a new event.

![Table View for event details](images/ios_app_skeleton_2.jpg)

The views for creating, viewing, and editing an event will be very similar. The entire view will be filled with a table which allows the user to change the address, name, and time of an event or to simply view these properties.

Creating, viewing, and editing will be handled by distinct view controller classes but each of these will use the same classes of table view cells.

![Image View for confirming event creation](images/ios_app_skeleton_3.jpg)

The last view will display after the user creates an event to confirm that it has been posted using our API. A button will allow users to post the event to social media sites using a standard activity view controller.

### Creating the Map View Controller

#### Add the MapKit Framework

![Adding the MapKit.framework](images/ios_app_skeleton_4.png)

First, since we're going to be using a map view, we'll need to add the `MapKit.framework` to our Humon target.

![Adding MapKit to the prefix file](images/ios_app_skeleton_5.png)

Now we can import MapKit in the Humon-Prefix file so we can access the map framework throughout the project.

#### Create the New View Controller

![Creating a new view controller](images/ios_app_skeleton_6.png)

Create a new view controller subclass called HUMMapViewController by selecting file>new>file. This will create a header (.h) and implementation (.m) file.

#### Create the MapView

Inside your implementation file (HUMMapViewController.m) create a new property called mapView. Alternatively, you can place this property in the header file, but keeping properties private in the implementation file is preferable if possible.

	@interface HUMMapViewController ()
	
	@property (strong, nonatomic) MKMapView *mapView;
	
	@end

Now we want to fill the entirety of the HUMMapViewController's view with a mapView. Inside of your viewDidLoad method, instantiate a map view and add it as a subview.

	@implementation HUMMapViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		
	    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
	    [self.view addSubview:self.mapView];
	}
	
	@end

#### Create the Add Button

Add a new property below the mapView property (inside the interface section of your implementation file) which is of type UIButton.

	@property (strong, nonatomic) MKMapView *mapView;
	@property (strong, nonatomic) UIButton *addButton;

Instantiate self.addButton and add it as a subview of the HUMMapViewController's view inside the viewDidLoad method.

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		
		self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
		[self.view addSubview:self.mapView];
	    
    	CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    	self.addButton = [[UIButton alloc] initWithFrame:buttonFrame];
        self.addButton.backgroundColor = [UIColor whiteColor];
		[self.addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:self.addButton];
		
    }
    
The `addTarget:action:ForControlEvents:` method sets the add button up to call the `addButtonPressed` method when the button is tapped. For now, just add a method called addButtonPressed below the viewDidLoad method that logs a confirmation.

	- (void)addButtonPressed
	{
    	NSLog(@"You pressed the add button!");
	}

### Creating the Add an Event View Controller

#### Subclassing UITableViewController

Create a new subclass of UITableViewController called HUMAddEventViewController. UITableViewController is a subclass of UIViewController that has a tableView property and conforms to the UITableViewDataSource and UITableViewDelegate protocols. This means that we have to implement the `tableView:numberOfRowsInSection:` and `tableView:cellForRowAtIndexPath:` so the tableView will know how many cells to display and what these cells will look like.

	@implementation HUMAddEventViewController
	
	- (void)viewDidLoad
	{
    	[super viewDidLoad];
    
    	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HUMAddEventCellIdentifier];
	}

	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
    	return 6;
	}

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
    	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HUMAddEventCellIdentifier forIndexPath:indexPath];
    	return cell;
	}

	@end

Instead of instantiating a new cell every time `tableView:cellForRowAtIndexPath:` is called, we use `dequeueReusableCellWithIdentifier:forIndexPath:` so that we can reuse cells that have already been instantiated. If we want to dequeue reusable cells, we have to register a class that the tableView will either create or reuse an instance of when we  call `dequeueReusableCellWithIdentifier:forIndexPath:`.

Using a static string as the cell identifier inside of `tableView:cellForRowAtIndexPath:` is suggested, since the string is constant and should only have to be instantiated once. If you place `static NSString *const HUMAddEventCellIdentifier = @"HUMAddEventCellIdentifier";` inside your HUMAddEventViewController implementation file, you can use refer to this string throughout the file. Later, we will pull out this static constant string into a custom subclass of UITableViewCell.

#### Linking the Add Button to the HUMAddEventViewController

Now that we have created a HUMAddEventViewController we can create and show the add view from the HUMMapViewController. Go back to the HUMMapViewController's implementation file and add `#import "HUMAddEventViewController.h"` below the `#import "HUMMapViewController.h"` to import the header file we created in the previous section. Now we can replace the `addButtonPressed` method and present a HUMAddEventViewController.

	- (void)addButtonPressed
	{
    	HUMAddEventViewController *addEventViewController = [[HUMAddEventViewController alloc] init];
    	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addEventViewController];
    	[self presentViewController:navigationController animated:YES completion:nil];
	}

When we press the Add button on top of the map view, we can either push a new HUMAddEventViewController onto the navigation stack or we can present a new HUMAddEventViewController modally. Pushing onto the navigation stack gives us the "Back" functionality for dismissing views, but in our case we actually want to present modally and use a custom "Cancel" dismissal.

Presenting modally from the HUMMapViewControlle means that the HUMAddEventViewController will animate sliding up from the bottom and will not have a navigation bar by default. We'll place the HUMAddEventViewController inside a navigation controller before presenting it, so that it will have a navigation bar.

#### Adding a Cancel Button

Inside the HUMAddEventViewController, add a left aligned bar button item to the navigation bar. This bar button item will call the method `cancelButtonPressed` which calls a method on the view controller that presented the HUMAddEventViewController (which in this case is the HUMMapViewController) to dismiss.

	- (void)viewDidLoad
	{
    	[super viewDidLoad];
    
    	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
	}

	- (void)cancelButtonPressed
	{
    	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}

### Creating the Confirmation View Controller

Create a subclass of UIViewController and call it HUMConfirmationViewController. The view for this view controller will contain a share button and an edit button, in case the user wants to change the event they just created.

#### Adding a Cancel Button

Add a cancel button as you did in the Add an Event View Controller section. We want the user to be able to cancel directly out of this screen, and not be able to go back to the event they just posted. If the user wants to change the details on an event they just created, they can explicitly follow the edit button.

To disable the back button, we just add `self.navigationItem.hidesBackButton = YES;` right below where we added the left bar button item in `viewDidLoad`.

#### Adding a Share Button

Lets add a share button so that users can share their events with their friends. We're going to use some of the default social share functions that are included in the UIActivityViewController.

First, create a button in view did load like we did in the map view.

    CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    self.shareButton = [[UIButton alloc] initWithFrame:buttonFrame];
    self.shareButton.backgroundColor = [UIColor blueColor];
    [self.shareButton addTarget:self action:@selector(presentActivityViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
Since the button is going to call the method `presentActivityViewController` when tapped, we have to implement that method inside of HUMConfirmationViewController.

	- (void)presentActivityViewController
	{
    	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Event info"] applicationActivities:nil];
    	[activityViewController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint]];
    	[self presentViewController:activityViewController animated:YES completion:nil];
	}

Inside of the method, we create and present a UIActivityViewController. The activityViewController contains activities that allow users to save pictures to their camera roll, or post links to twitter, etc. When we intialize this view controller, we have to include an array of activity items that we want to save or post or share. The activity items you include can be strings, images, or even custom objects. In our case, we're going to want to include a dummy string that will later contain our event info.

We also set the activityViewController's excludedActivityTypes so that the activity view that pops up will not allow the user to copy the event text or print it. There are quite a few activity types that Apple provides by default in the UIActivityViewController and you can exclude them by including them in the array of excluded types. Keep in mind that some options won't always be available, like "Save to Camera Roll" which is only available if one of the activity items is a UIImage. 

