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

### Create Static Cells

In the document outline, select the "Table View" below the "Event View Controller". This is the table view that our Event View Controller manages.

IMAGE OF DOCUMENT OUTLINE

Open the attributes inspector in the the utilities sidebar. Incrase the number of prototype cells in the table view to 5 and switch the content from "Dynamic Prototypes" to "Static Cells". We will use these cells to gather information from the user to create a new event.

IMAGE OF ATTRIBUTES INSPECTOR CELL INCREASE

Drag a `text field` from the object library at the bottom of the attributes inspector into four of the blank cells in the `table view controller`.

IMAGE OF PROTOTYPE CELLS

