## The Initial App Skeleton

### Defining the User Flow

The Humon app is going to have 3 distinct view controller types, which we will create empty versions of now.

1. The initial view will contain a large map with pins for events that are near you, events you've created, and events you are tracking. It will also contain a button for adding a new event.

2. The views for creating, viewing, and editing an event will be very similar. The entire view will be filled with a table which allows the user to change the address, name, and time of an event or to simply view these properties.

	Creating, viewing, and editing will be handled by distinct view controller classes but each of these will use the same classes of table view cells.

3. The last view will display after the user creates an event to confirm that it has been posted using our API. A button will allow users to post the event to social media sites using a standard activity view controller.

### Creating the Map View Controller

![Map View for viewing events](images/ios_app_skeleton_1.png)

#### Add the MapKit Framework

![Adding the MapKit.framework](images/ios_app_skeleton_4.png)

First, since we're going to be using a map view, we'll need to add the `MapKit.framework` to our Humon target.

![Adding MapKit to the prefix file](images/ios_app_skeleton_5.png)

Now we can import MapKit in the Humon-Prefix file so we can access the map framework throughout the project.

#### Create the New View Controller

![Creating a new view controller](images/ios_app_skeleton_6.png)

Create a new view controller subclass called HUMMapViewController by selecting file>new>file. This will create a header (.h) and implementation (.m) file.

#### Create the MapView

Inside your implementation file, create a new property called mapView. Alternatively, you can place this property in the header file, but keeping properties private by placing them in the "hidden" interface located in the implementation file is preferable if possible. 

Also, declare that the HUMMapViewController conforms to the MKMapViewDelegate protocol by adding `<MKMapViewDelegate>`. This allows the HUMMapViewController to respond to delegate messages that the `mapView` sends.

	// HUMMapViewController.m
	
	@interface HUMMapViewController () <MKMapViewDelegate>
	
	@property (strong, nonatomic) MKMapView *mapView;
	
	@end

Now we want to fill the entirety of the HUMMapViewController's view with a mapView. Inside of your viewDidLoad method, instantiate a map view and add it as a subview of the main view. 

Remember to set HUMMapView as the delegate of `self.mapview` so it can respond to delegate messages like `mapView:regionDidChangeAnimated:`.

	// HUMMapViewController.m
	
	@implementation HUMMapViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		
        self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        [self.view addSubview:self.mapView];
	}
	
	@end

#### Create the Add Button

Add a new property below the mapView property which is of type UIButton.

	// HUMMapViewController.m
	
	@property (strong, nonatomic) MKMapView *mapView;
	@property (strong, nonatomic) UIButton *addButton;

Instantiate `self.addButton` and add it as a subview of the HUMMapViewController's view inside the viewDidLoad method.

	// HUMMapViewController.m
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		
		// Create and add a mapView as a subview of the main view
        self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        [self.view addSubview:self.mapView];
        
		// Create a frame and label for the "Add" button
        CGRect buttonFrame = CGRectMake(0,
                                        self.view.bounds.size.height - 2*44,
                                        self.view.bounds.size.width,
                                        44);
        NSString *buttonText = NSLocalizedString(@"Add Event", nil);
        
        // Create and add the "Add" button as a subview
        self.addButton = [[UIButton alloc] initWithFrame:buttonFrame];
        self.addButton.backgroundColor = [UIColor grayColor];
        self.addButton.alpha = 0.8;
        [self.addButton setTitle:buttonText
                        forState:UIControlStateNormal];
        [self.addButton addTarget:self
                           action:@selector(addButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.addButton];
		
    }
    
For more information on why we used an NSLocalizedString here instead of a `@"plain old string literal"`, please visit the [Apple developer library.](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/10000051i-CH6) The short explanation is that we use localized strings for all text that will be displayed to a user. That way we can easily translate our app from English to other languages.

The `addTarget:action:ForControlEvents:` method sets the add button up to call the `addButtonPressed` method when the button is tapped. For now, just add a method called addButtonPressed below the viewDidLoad method that logs a confirmation.

	// HUMMapViewController.m
	
	- (void)addButtonPressed
	{
    	NSLog(@"You pressed the add button!");
	}
	
Go ahead and run your project. If everything is set up correctly, you should see a full screen mapView and a grey button for adding events.

### Creating the Add an Event View Controller

![Table View for event details](images/ios_app_skeleton_2.png)

#### Subclassing UITableViewController

Create a new subclass of UITableViewController called HUMAddEventViewController. UITableViewController is a subclass of UIViewController that has a tableView property and conforms to the `<UITableViewDataSource>` and `<UITableViewDelegate>` protocols. This means that we have to implement the `tableView:numberOfRowsInSection:` and `tableView:cellForRowAtIndexPath:` so the tableView will know how many cells to display and what these cells will look like. If we don't implement these required protocol methods, the compiler will throw an error.

	// HUMAddEventViewController.m
	
	- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section
	{
    	return 6;
	}

    - (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        UITableViewCell *cell = [tableView
                        dequeueReusableCellWithIdentifier:HUMAddEventCellIdentifier
                                             forIndexPath:indexPath];
        if (indexPath.row == 5)
            cell.textLabel.text = NSLocalizedString(@"Done", nil);
        
        return cell;
    }

The method `tableView:cellForRowAtIndexPath:` returns a cell for every row in the tableview. Instead of instantiating and returning a new cell every time, we use `dequeueReusableCellWithIdentifier:forIndexPath:` so that we can reuse cells that have already been instantiated. The identifier argument allows you to recycle different types of cells, in case you wanted to have a `@"GreenCellIdentifier"` and a `@"BlueCellIdentifier"`.

Using a static string as the identifier is suggested, since the string is constant and should only have to be instantiated once. If you place `static NSString *const HUMAddEventCellIdentifier = @"HUMAddEventCellIdentifier";` inside your HUMAddEventViewController implementation file, you can use refer to this `@"HUMAddEventCellIdentifier"` string as `HUMAddEventCellIdentifier` throughout the file.

	// HUMAddEventViewController.m
	
	- (void)viewDidLoad
	{
    	[super viewDidLoad];
    
    	[self.tableView registerClass:[UITableViewCell class]
           	   forCellReuseIdentifier:HUMAddEventCellIdentifier];
	}

If we want to be able to reuse cells using the `HUMAddEventCellIdentifier`, we have to register a class that the tableView will create or reuse an instance of when we call `dequeueReusableCellWithIdentifier:forIndexPath:`. We do this inside of `viewDidLoad`.

#### Linking the Add Button to the HUMAddEventViewController

Now that we have created a HUMAddEventViewController we can create and show the add view from the HUMMapViewController. Go back to the HUMMapViewController's implementation file and add `#import "HUMAddEventViewController.h"` below the `#import "HUMMapViewController.h"` to import the header file we created in the previous section.

Now we can replace the `addButtonPressed` method to present a HUMAddEventViewController. When we press the Add button on top of the map view, we can either:

1. Push a new HUMAddEventViewController onto a navigation stack that contains both it and the HUMMapViewController
	
2. Present a new HUMAddEventViewController modally.
	
Having the HUMMapViewController present modally means that the HUMAddEventViewController will animate sliding up from the bottom. Pushing onto the navigation stack would give us the "Back" functionality for dismissing views, but in our case we actually want to present modally and use a custom "Cancel" dismissal.

	// HUMMapViewController.m
	
	- (void)addButtonPressed
	{
    	HUMAddEventViewController *addEventViewController = [[HUMAddEventViewController alloc] init];
    	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addEventViewController];
    	[self presentViewController:navigationController animated:YES completion:nil];
	}

Since the `addEventViewController` isn't being placed on a navigation stack with the HUMMapViewController, it won't have a navigation bar but default. We'll place the `addEventViewController` inside its own navigation controller so that it will have a navigation stack and navigation bar of its own.

Now we can present the `navigationController` instead of the `addEventViewController`. This presents the entire `navigationController`'s navigation stack, but right now the only view controller inside the navigation stack is the `addEventViewController`.

You can run the Humon app now and press the "Add" button. However, you won't be able to cancel out of the HUMAddEventViewController, so lets handle that next.

#### Adding a Cancel Button

Inside the HUMAddEventViewController, add a left aligned bar button item to the navigation bar. This bar button item will call the method `cancelButtonPressed` which calls a method on the view controller that presented the HUMAddEventViewController (which in this case is the HUMMapViewController) to dismiss.

	// HUMAddEventViewController.m

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:HUMAddEventCellIdentifier];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                            target:self
                                            action:@selector(cancelButtonPressed)];
    }

    - (void)cancelButtonPressed
    {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
	
If you run the app now, you'll be able to summon and dismiss the HUMAddEventViewController.

### Creating the Confirmation View Controller

![View for confirming event creation](images/ios_app_skeleton_3.png)

Create a subclass of UIViewController and call it HUMConfirmationViewController. The view for this view controller will contain a share button and an edit button, in case the user wants to change the event they just created.

#### Adding a Cancel Button

Add a cancel button as you did in the Add an Event View Controller section. We want the user to be able to cancel directly out of this screen, and not be able to go back to the event they just posted. If the user wants to change the details on an event they just created, they can explicitly follow the edit button.

    // HUMConfirmationViewController.m

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                            target:self
                                            action:@selector(cancelButtonPressed)];
        self.navigationItem.hidesBackButton = YES;
    }

To disable the back button, we just add `self.navigationItem.hidesBackButton = YES;` right below where we added the left bar button item in `viewDidLoad`.

#### Adding a Share Button

Lets add a share button so that users can share their events with their friends. We're going to use some of the default social share functions that are included in the UIActivityViewController.

Create a share button similarly to how we did in the HUMMapViewController. This time, however, lets factor out creating a share button into its own method. We can then call this method `[self createShareButton]` inside of `viewDidLoad`.

    // HUMConfirmationViewController.m

    - (void)createShareButton
    {
        CGRect shareFrame = CGRectMake(self.view.bounds.size.width/2,
                                       self.view.bounds.size.height - 2*44,
                                       self.view.bounds.size.width/2,
                                       44);
        self.shareButton = [[UIButton alloc] initWithFrame:shareFrame];
        self.shareButton.backgroundColor = [UIColor lightGrayColor];
        [self.shareButton setTitle:@"Share Event" forState:UIControlStateNormal];
        [self.shareButton addTarget:self
                             action:@selector(presentActivityViewController)
                   forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.shareButton];
    }
    
We set the share button to call the method `presentActivityViewController` when tapped, so we have to implement that method inside of HUMConfirmationViewController.

    // HUMConfirmationViewController.m

    - (void)presentActivityViewController
    {
        UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc]
                initWithActivityItems:@[@"Event info"]
                applicationActivities:nil];
        [activityViewController setExcludedActivityTypes:
            @[UIActivityTypeCopyToPasteboard, UIActivityTypePrint]];
        [self presentViewController:activityViewController
                           animated:YES
                         completion:nil];
    }

Inside of the method, we create and present a UIActivityViewController. The activityViewController contains activities that allow users to save pictures to their camera roll, or post links to twitter, etc. When we intialize this view controller, we have to include an array of activity items that we want to save or post or share. The activity items you include can be strings, images, or even custom objects. In our case, we're going to want to include a dummy string that will later contain our event info.

We also set the activityViewController's excludedActivityTypes so that the activity view that pops up will not allow the user to copy the event text or print it. There are quite a few activity types that Apple provides by default in the UIActivityViewController and you can exclude them by including them in the array of excluded types. Keep in mind that some options won't always be available, like "Save to Camera Roll" which is only available if one of the activity items is a UIImage.

#### Adding an Edit Button

We'll allow the user to edit their event after creating it, to utelize the PATCH functionality we have in our rails app. Create a method that adds an edit button to the view, and call the method in `viewDidLoad`. If you want to clean your code up even more, you can create a custom subclass of UIButton for this editButton.

    // HUMConfirmationViewController.m

    - (void)createEditButton
    {
        CGRect editFrame = CGRectMake(0,
                                      self.view.bounds.size.height - 2*44,
                                      self.view.bounds.size.width/2,
                                      44);
        self.editButton = [[UIButton alloc] initWithFrame:editFrame];
        self.editButton.backgroundColor = [UIColor darkGrayColor];
        [self.editButton setTitle:@"Edit Event" forState:UIControlStateNormal];
        [self.editButton addTarget:self
                            action:@selector(presentEditViewController)
                  forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.editButton];
    }
    
We set the edit button to call a method called `presentEditViewController`, so lets create that method so we can fill it in later.
    
    // HUMConfirmationViewController.m
    
	- (void)presentEditViewController
	{
    	NSLog(@"You pressed the edit button!");
	}

#### Linking the Confirm Button to the HUMConfirmationViewController

Once the user has successfully created their event, we will present them with the confirmation view. For now, we'll display the confirmation view whenever the user presses the 6th cell in the HUMAddEventViewController, which says "Done".

	//HUMAddEventViewController.m

    - (void)addButtonPressed
    {
        HUMAddEventViewController *addEventViewController =
            [[HUMAddEventViewController alloc] init];
            
        UINavigationController *navigationController = [[UINavigationController
            alloc] initWithRootViewController:addEventViewController];
            
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }
    
Be sure to `#import HUMConfirmationViewController.h` in HUMAddEventViewController.m so you can use it in this method.

The method `tableView:didSelectRowAtIndexPath:` is one of the `<UITableViewDelegate>` methods that the tableView will call on HUMAddEventViewController if the view controller is set as the tableView's delegate. Since we subclassed UITableViewController, HUMAddEventViewController is already set up as the tableView's delegate.

Notice that we chose to push the `confirmationViewController` instead of present it modally. Since the HUMAddEventViewController is already inside of its own navigation stack, we can push this new view controller onto that stack. That way, when we dismiss the navigation controller, both the `confirmationViewController` and the `addEventViewController` will be dismissed.

If you run the app, you'll be able to go through the approximate flow of creating a new event.
