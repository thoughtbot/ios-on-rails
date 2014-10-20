# Making the POST Event Request

### Creating a New Init Method

Our POST to events will happen in the HUMEventViewController. This view controller will be used for creating a new event as well as viewing other people's events, so we'll create an init method that encompasses both these cases.

	// HUMEventViewController.h
	
	@class HUMEvent;

	@interface HUMEventViewController : UITableViewController
	
	- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;
	
	@end
	
Now, lets implement this method. Don't forget to `#import "HUMEvent.h"`

	// HUMEventViewController.m

	- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;
	{
	    self = [super initWithStyle:UITableViewStylePlain];
	    if (!self) {
	        return nil;
	    }
	
	    _event = event;
	    _editable = editable;
	
	    return self;
	}

This method implementation references two properties we don't have yet, so place declarations for those in the hidden interface.

	// HUMEventViewController.m

	@interface HUMEventViewController ()
	
	@property (strong, nonatomic) HUMEvent *event;
	@property (assign, nonatomic) BOOL editable;
	
	@end
	
### Adding a Submit Event Method

Lets take a step back and remember what this view controller is supposed to look like. The HUMEventViewController will have 4 cells for each property of our event (name, address, startDate, endDate) and a submit cell. Instead of referring to these by their indexes, lets define these cell indexes in an enum at the top of `HUMEventViewController.h`. This enum starts at HUMEventCellName = 0 and goes to HUMEventCellCount = 5.

	// HUMEventViewController.h
	
	typedef NS_ENUM(NSUInteger, HUMEventCell) {
	    HUMEventCellName,
	    HUMEventCellAddress,
	    HUMEventCellStart,
	    HUMEventCellEnd,
	    HUMEventCellSubmit,
	    HUMEventCellCount
	};
	
Now we can change the `tableView:numberOfRowsInSection:` to `return HUMEventCellCount;` instead of `return 5;`

We can also use this new enum when we declare `tableView:didSelectRowAtIndexPath:`to determine (in a user readable fashion) which cell was selected.
	
	// HUMEventViewController.m
	
	- (void)tableView:(UITableView *)tableView
	    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    // Return if the user didn't select the submit cell
	    // This is the same as (indexPath.row != 5) but much more readable
	    if (indexPath.row != HUMEventCellSubmit)
	        return;
	
	    // Post the event
	    [SVProgressHUD show];
	    [[HUMRailsClient sharedClient] createEvent:self.event
	        withCompletionBlock:^(NSString *eventID, NSError *error) {
	
			// Handle the error or dismiss the view controller on success
	        if (error) {
	            [SVProgressHUD showErrorWithStatus:
	             NSLocalizedString(@"Failed to create event.", nil)];
	        } else {
	            [SVProgressHUD dismiss];
	            [self.navigationController popToRootViewControllerAnimated:YES];
	        }
	
	    }];
	}

### Using the New Init Method

Now we just have to use this new init method in the `HUMMapViewController`. Change the `addButtonPressed` method to use this new init method and be sure to `#import "HUMEvent.h"`.

	// HUMMapViewController.m

	- (void)addButtonPressed
	{
	    // Create a fake event
	    HUMEvent *event = [[HUMEvent alloc] init];
	    event.name = @"Picnic";
	    event.address = @"123 Fake St.";
	    event.coordinate = self.mapView.centerCoordinate;
	    event.startDate = [NSDate date];
	    event.endDate = [NSDate dateWithTimeIntervalSinceNow:100];
	
	    // Push an event controller with the fake event
	    HUMTableViewController *eventViewController =
	        [[HUMTableViewController alloc] initWithEvent:event editable:YES];
	    [self.navigationController pushViewController:eventViewController
	                                         animated:YES];
	}

Now if you run the app you should be able to press the add button, tap the 5th cell in the event table view, and make a successful POST to events.
