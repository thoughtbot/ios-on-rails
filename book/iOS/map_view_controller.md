## The Map View Controller

![Map View for viewing events](images/ios_app_skeleton_1.png)

### Add the MapKit Framework

![Adding the MapKit.framework](images/ios_app_skeleton_4.png)

First, since we're going to be using a map view, we'll need to add the `MapKit.framework` to our Humon target.

![Adding MapKit to the prefix file](images/ios_app_skeleton_5.png)

Now we can import MapKit in the Humon-Prefix file so we can access the map framework throughout the project.

### Create the New View Controller

![Creating a new view controller](images/ios_app_skeleton_6.png)

Create a new view controller subclass called HUMMapViewController by selecting file>new>file. This will create a header (.h) and implementation (.m) file.

### Set the Root View Controller

Now that we have a view controller subclass that will serve as our initial view controller in the app, we can show this view controller on launch. The app delegate has a method for exactly this purpose, called `application:didFinishLaunchingWithOptions:`, which we will overwrite.

	// HUMAppDelegate.m

    - (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        self.window = [[UIWindow alloc] initWithFrame:
                       [[UIScreen mainScreen] bounds]];
        
        HUMMapViewController *viewController = [[HUMMapViewController alloc] init];
        self.window.rootViewController = viewController;
        [self.window makeKeyAndVisible];
        
        return YES;
    }
    
The `UIWindow` class handles presenting views onto the screen of the device. In the app delegate, set`self.window` to an instance of `UIWindow` 

Then create a new instance of `HUMMapViewController` and set it as the window's `rootViewController`. This make the map view controller the first view controller we see on a fresh launch of the app.

To set an instance of `HUMMapViewController` as the initial view controller in the app delegate, we need to add `#import "HUMMapViewController.h"` near the top of the `HUMAppDelegate.m`. If we don't, the compiler will throw an error since the app delegate needs to be aware of a class before instantiating an insta

Finally, call `makeKeyAndVisible` on the window to make the window visible so you can see your views on the device screen.

Run the app and you'll see an instance of your `HUMMapViewController`!

### Create the MapView

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

### Create the Add Button

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

