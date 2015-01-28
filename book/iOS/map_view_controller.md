# The Map View Controller

![Map View for viewing events](images/ios_app_skeleton_1.png)

### Create the New View Controller

Create a new view controller subclass called `HUMMapViewController` by selecting File > New > File. This will create a header (.h) file and implementation (.m) file.

![Creating a new view controller](images/ios_app_skeleton_6.png)

### Set the Root View Controller

Now that we have a view controller subclass that will serve as our initial view controller in the app, we can show this view controller on launch. The app delegate has a method for exactly this purpose, called `-application:didFinishLaunchingWithOptions:`, which we will overwrite.

	// HUMAppDelegate.m

	- (BOOL)application:(UIApplication *)application
	    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    self.window = [[UIWindow alloc] initWithFrame:
	                   [[UIScreen mainScreen] bounds]];
	
	    HUMMapViewController *mapViewController =
	        [[HUMMapViewController alloc] init];
	    UINavigationController *navigationController =
	        [[UINavigationController alloc]
	         initWithRootViewController:mapViewController];
	
	    self.window.rootViewController = navigationController;
	    [self.window makeKeyAndVisible];
	    
	    return YES;
	}

The `UIWindow` class handles the task of presenting views onto the device's screen. In the app delegate, the method should already set `self.window` to an instance of `UIWindow`.

To set an instance of `HUMMapViewController` as the initial view controller that we see, we need to add `#import "HUMMapViewController.h"` near the top of the `HUMAppDelegate.m`. If we don't, the compiler will throw an error, since the app delegate needs to be aware of a class before instantiating an instance of it.

So let's create a new instance of `HUMMapViewController` via 
`HUMMapViewController *mapViewController = [[HUMMapViewController alloc] init];`. Since we want to push new views on top of this map view controller, we also initialize a `UINavigationController` with the map view controller as its root view controller. Now, when we want to show the user new view controllers, we can just push them onto that navigation controller.

Next, set that navigation controller as the window's `rootViewController`. This will make the map view controller (since it is the only view controller in the navigation view controller's stack) the first view controller we see on a fresh launch of the app.

Finally, call `makeKeyAndVisible` on the window to make the window visible. This is so you can see your views on the device screen.

Run the app and you'll see an instance of your `HUMMapViewController`!

### Create the MapView

First, import MapKit by placing `@import MapKit;` at the top of `HUMMapViewController.m`.

Inside your implementation file, create a new property called `mapView`. Alternatively, you can place this property in the header file. It's preferable, if possible, to keep properties private by placing them in the hidden interface located in the implementation file. 

Also, declare that the `HUMMapViewController` conforms to the `MKMapViewDelegate` protocol by adding `<MKMapViewDelegate>`. This allows the `HUMMapViewController` to respond to delegate messages that the `mapView` sends.

	// HUMMapViewController.m
	
	@interface HUMMapViewController () <MKMapViewDelegate>
	
	@property (strong, nonatomic) MKMapView *mapView;
	
	@end

Now we want to fill the entirety of the `HUMMapViewController`'s view with a `mapView`. Inside your `-viewDidLoad` method, instantiate a map view and add it as a subview of the main view. Remember to set `HUMMapView` as the delegate of `self.mapview` so it can respond to delegate messages like `-mapView:regionDidChangeAnimated:`.

Also, we set the title of this view controller to the name of our app, `@"Humon"`. For more information on why we used an `NSLocalizedString` here instead of a `@"plain old string literal"`, please visit the [Apple Developer Library](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html#//apple_ref/doc/uid/10000051i-CH6). The short explanation is that we use localized strings for all text that will be displayed to a user. That way we can easily translate our app from English to other languages.

	// HUMMapViewController.m
	
	@implementation HUMMapViewController
	
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		
		// Set the title in the navigation bar
		self.title = NSLocalizedString(@"Humon", nil);
		
		// Create and add a mapView as a subview of the main view
		self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
		self.mapView.delegate = self;
		[self.view addSubview:self.mapView];
		
		// Find the map's center point and add a red dot
	}
	
	@end

When a user adds an event, the new event's coordinate will be at the center of the visible map. Replace the last comment in `viewDidLoad` with the following to add a red dot to the center of the map, so users will know where their new event is being added.

The `masksToBounds` and `cornerRadius` properties mask the edges of the square `centerpointView` so it looks like a circle.

	// HUMMapViewController.m
	
	// Find the map's center point
	CGFloat centerpointRadius = 4;
	CGFloat statusBarHeight = [UIApplication sharedApplication]
                              .statusBarFrame.size.height;
	CGRect centerpointRect = CGRectMake(self.view.center.x - centerpointRadius,
	                                    self.view.center.y - centerpointRadius 
	                                    - statusBarHeight,
	                                    2 * centerpointRadius,
	                                    2 * centerpointRadius);
	
	// Add a red dot to the center point
	UIView *centerpointView = [[UIView alloc] initWithFrame:centerpointRect];
	centerpointView.backgroundColor = [UIColor redColor];
	centerpointView.layer.masksToBounds = YES;
	centerpointView.layer.cornerRadius = centerpointRadius;
	[self.view addSubview:centerpointView];
	
Go ahead and run the app to see the big beautiful map you just created.

### Create the Add Button

Now we'll create an "Add" button and place it in the navigation bar at the top of our the screen.

	// HUMMapViewController.m
	
	- (void)viewDidLoad
	{
	    ...
        
		// Create an "Add" button
	    UIBarButtonItem *button = [[UIBarButtonItem alloc]
	        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	        target:self
	        action:@selector(addButtonPressed)];
	    self.navigationItem.leftBarButtonItem = button;
    }
    
We want our "Add" button to be on our navigation bar, so create an instance of `UIBarButtonItem`. The `target:action:` portion of the `UIBarButtonItem` initializer method sets the button up to call the `-addButtonPressed` method when the button is tapped.

To see the `button` on the navigation bar, set it as the `leftBarButtonItem` on the view controller's `navigationItem`.

We need to implement the method `addButtonPressed`, so add the method below the viewDidLoad method and have it log a confirmation.

	// HUMMapViewController.m
	
	- (void)addButtonPressed
	{
    	NSLog(@"You pressed the add button!");
	}
	
Go ahead and run your project. If everything is set up correctly, you should see a full screen mapView and a button for adding events.

