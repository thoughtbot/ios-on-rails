# The Add an Event View Controller

![Table View for event details](images/ios_app_skeleton_2.png)

### Subclassing UITableViewController

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

### Linking the Add Button to the HUMAddEventViewController

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

Since the `addEventViewController` isn't being placed on a navigation stack with the HUMMapViewController, it won't have a navigation bar by default. We'll place the `addEventViewController` inside its own navigation controller so that it will have a navigation stack and navigation bar of its own.

Now we can present the `navigationController` instead of the `addEventViewController`. This presents the entire `navigationController`'s navigation stack, but right now the only view controller inside the navigation stack is the `addEventViewController`.

You can run the Humon app now and press the "Add" button. However, you won't be able to cancel out of the HUMAddEventViewController, so lets handle that next.

### Adding a Cancel Button

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

