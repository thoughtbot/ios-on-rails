# The Event View Controller

![Table View for event details](images/ios_app_skeleton_2.png)

### Subclassing UITableViewController

Create another new view controller subclass called `EventViewController` by selecting File > New > File.

Select the `EventViewController.swift` file and declare a `EventViewController` class that is as subclass of `UITableViewController`. `UITableViewController` is a subclass of `UIViewController` that has a `tableView` property and conforms to the `<UITableViewDataSource>` and `<UITableViewDelegate>` protocols.

	// EventViewController.swift
	
	import UIKit
	
	class EventViewController: UITableViewController {
	}
	
### Assign the Class in the Storyboard

The `EventViewController` is a `UITableViewController` subclass that will replace the current class of our `table view controller` in the Storyboard.

Open `Main.storyboard` and select the `table view controller`.
In the attributes inspector, set the custom class of the `table view controller` to `EventViewController`.

### Conform to the Data Source Protocol

This means that we have to implement the `tableView:numberOfRowsInSection:` and `tableView:cellForRowAtIndexPath:` so the `tableView` will know how many cells to display and what these cells will look like. You can remove any other `-tableView:...` methods you see in the implementation file.

	// HUMEventViewController.m
	
	- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section
	{
    	return 5;
	}

    - (UITableViewCell *)tableView:(UITableView *)tableView
             cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        UITableViewCell *cell = [tableView
                        dequeueReusableCellWithIdentifier:HUMEventCellIdentifier
                                             forIndexPath:indexPath];    
        
        return cell;
    }

The method `-tableView:cellForRowAtIndexPath:` returns a cell for every row in the tableview. Instead of instantiating and returning a new cell every time, we use `-dequeueReusableCellWithIdentifier:forIndexPath:` so we can reuse cells that have already been instantiated. The identifier argument allows you to recycle different types of cells, in case you wanted to have a `@"GreenCellIdentifier"` and a `@"BlueCellIdentifier"`.

We use static strings as cell identifiers, since there's no need to create a new instance of the identifier every time we want to use it. This is why we are using `HUMEventCellIdentifier` here instead of a string literal like `@"cell"`.

Create a static string named `HUMEventCellIdentifier` and place it just below your imports. Now you can refer to this `@"HUMEventCellIdentifier"` string as `HUMEventCellIdentifier` throughout the file.

	// HUMEventViewController.m
	
	#import "HUMEventViewController.h"
	
	static NSString *const HUMEventCellIdentifier = @"HUMEventCellIdentifier";
	
	...
	
	- (void)viewDidLoad
	{
    	[super viewDidLoad];
    
    	[self.tableView registerClass:[UITableViewCell class]
           	   forCellReuseIdentifier:HUMEventCellIdentifier];
	}

If we want to be able to reuse cells using the `HUMEventCellIdentifier`, we have to register a class that the `tableView` will create or reuse an instance of when we call `dequeueReusableCellWithIdentifier:forIndexPath:`. We do this inside of `viewDidLoad`.
