# The Add an Event View Controller

![Table View for event details](images/ios_app_skeleton_2.png)

### Subclassing UITableViewController

Create a new subclass of UITableViewController called HUMEventViewController. UITableViewController is a subclass of UIViewController that has a tableView property and conforms to the `<UITableViewDataSource>` and `<UITableViewDelegate>` protocols. This means that we have to implement the `tableView:numberOfRowsInSection:` and `tableView:cellForRowAtIndexPath:` so the tableView will know how many cells to display and what these cells will look like. You can remove any other `tableView:` methods you see in the implementation file.

	// HUMEventViewController.m
	
	- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section
	{
    	return 6;
	}

    - (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        UITableViewCell *cell = [[tableView
                        dequeueReusableCellWithIdentifier:HUMEventCellIdentifier
                                             forIndexPath:indexPath];    
        
        return cell;
    }

The method `tableView:cellForRowAtIndexPath:` returns a cell for every row in the tableview. Instead of instantiating and returning a new cell every time, we use `dequeueReusableCellWithIdentifier:forIndexPath:` so that we can reuse cells that have already been instantiated. The identifier argument allows you to recycle different types of cells, in case you wanted to have a `@"GreenCellIdentifier"` and a `@"BlueCellIdentifier"`.

We use static strings as cell identifiers, since there's no need to create a new instance of the identifier every time we want to use it. This is why we are using `HUMEventCellIdentifier` here instead of a string literal like `@"cell"`.

To create a static string, place `static NSString *const HUMEventCellIdentifier = @"HUMEventCellIdentifier";` inside your HUMEventViewController implementation file. Now you can refer to this `@"HUMEventCellIdentifier"` string as `HUMEventCellIdentifier` throughout the file.

	// HUMEventViewController.m
	
	- (void)viewDidLoad
	{
    	[super viewDidLoad];
    
    	[self.tableView registerClass:[UITableViewCell class]
           	   forCellReuseIdentifier:HUMEventCellIdentifier];
	}

If we want to be able to reuse cells using the `HUMEventCellIdentifier`, we have to register a class that the tableView will create or reuse an instance of when we call `dequeueReusableCellWithIdentifier:forIndexPath:`. We do this inside of `viewDidLoad`.

### Linking the Add Button to the HUMAddEventViewController

Now that we have created a HUMAddEventViewController we can create and show the add view from the HUMMapViewController. Go back to the HUMMapViewController's implementation file and add `#import "HUMEventViewController.h"` below the `#import "HUMMapViewController.h"` to import the header file we created in the previous section.

Now we can replace the `addButtonPressed` method to present a HUMEventViewController. When we press the Add button on top of the map view, we can either:

1. Push a new HUMEventViewController onto the navigation stack managed by the UINavigationController we created in the AppDelegate.m.
	
2. Present a new HUMAddEventViewController modally.
	
Having the HUMMapViewController present modally means that the HUMEventViewController would animate sliding up from the bottom. 

Pushing onto the navigation stack means that the UINavigationController we created in the AppDelegate.m would then contain a HUMMapViewController at the bottom, and a HUMEventViewController on the top. The topmost view controller will be visible, aka the HUMEventViewController.

This is what we're going to do, and it will also give us the "Back" functionality for dismissing the HUMEventViewController.

	// HUMMapViewController.m
	
	- (void)addButtonPressed
	{
    	HUMEventViewController *eventViewController = [[HUMEventViewController alloc] init];
	    [self.navigationController pushViewController:eventViewController
	                                         animated:YES];
	}

You can run the Humon app now and press the "Add" button to see your new event view controller.
