## The Confirmation View Controller

![View for confirming event creation](images/ios_app_skeleton_3.png)

Create a subclass of UIViewController and call it HUMConfirmationViewController. The view for this view controller will contain a share button and an edit button, in case the user wants to change the event they just created.

### Adding a Cancel Button

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

### Adding a Share Button

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

Inside of the method, we create and present a UIActivityViewController. The activityViewController contains activities that allow users to save pictures to their camera roll, or post links to twitter, etc. When we initialize this view controller, we have to include an array of activity items that we want to save or post or share. The activity items you include can be strings, images, or even custom objects. In our case, we're going to want to include a dummy string that will later contain our event info.

We also set the activityViewController's excludedActivityTypes so that the activity view that pops up will not allow the user to copy the event text or print it. There are quite a few activity types that Apple provides by default in the UIActivityViewController and you can exclude them by including them in the array of excluded types. Keep in mind that some options won't always be available, like "Save to Camera Roll" which is only available if one of the activity items is a UIImage.

### Adding an Edit Button

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

### Linking the Confirm Button to the HUMConfirmationViewController

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

