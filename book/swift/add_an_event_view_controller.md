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

Open the attributes inspector in the the utilities sidebar. Incrase the number of prototype cells in the table view to 4 and switch the content from "Dynamic Prototypes" to "Static Cells". We will use these cells to gather information from the user to create a new event.

IMAGE OF ATTRIBUTES INSPECTOR CELL INCREASE

Drag a `text field` from the object library at the bottom of the attributes inspector into each of the blank cells in the `table view controller`. Resize the text field to be the full size of the cell.

Drag a `bar button item` from the object library onto the right side of the table view controller's navigation bar.

IMAGE OF PROTOTYPE CELLS

Select the `EventViewController.swift` in the file navigator on the left  and toggle the assistant editor. The assistant editor should display `Main.storyboard`, allowing you to create IBOutlets for the text fields and an IBAction for the bar button item. 

Hold down `ctrl` and drag from each text field into the declaration of `EventViewController` to create an outlet for each text field.

Hold down `ctrl` and create and drag from the bar button item to `EventViewController.swift` to create an action for the bar button item to perform.

IMAGE OF IB ACTION POPUP

	// EventViewController.swift

	class EventViewController: UITableViewController {
	
	    @IBOutlet weak var nameTextField: UITextField!
	    @IBOutlet weak var addressTextField: UITextField!
	    @IBOutlet weak var startAtTextField: UITextField!
	    @IBOutlet weak var endAtTextField: UITextField!
	
		@IBAction func saveEvent(_ sender: AnyObject) {
    	}
    	
	}

Now `EventViewController.swift` has outlets and an action for the new views we added to the `EventViewController` in the storyboard. Run the app to see the fleshed out version of the 	event view controller.
