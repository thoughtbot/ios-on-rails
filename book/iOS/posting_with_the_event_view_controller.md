# Posting with the Event View Controller

### Creating a Custom Cell

We just implemented posting a pre-made event to our API, but what we really want is to post an event based on user input. So, we need to create some custom cells for our HUMEventViewController.

Create a new subclass of UITableViewCell called HUMTextFieldCell. Define a property called `textField` in the header file. We'll also want to define a static string that we can use as this cell's reuse identifier.

	// HUMTextFieldCell.h
	
	static NSString *kTextFieldCellID = @"kTextFieldCellID";
	
	@interface HUMTextFieldCell : UITableViewCell
	
	@property (strong, nonatomic) UITextField *textField;
	
	@end

Now we'll want to initialize that `textView` and add it as a subview of our cell in a custom init method. We'll also set the `selectionStyle` to none since we don't want any response if the user selects the cell.

	// HUMTextFieldCell.m
	
	- (id)initWithStyle:(UITableViewCellStyle)style
	    reuseIdentifier:(NSString *)reuseIdentifier
	{
	    self = [super initWithStyle:UITableViewCellStyleDefault
	                reuseIdentifier:reuseIdentifier];
	    if (!self) {
	        return nil;
	    }
	
	    _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
	    _textField.delegate = self;
	    [self.contentView addSubview:_textField];
	    
	    self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	    return self;
	}

We want the user to be able to return out of the text field, so implement the delegate method `textFieldShouldReturn:`.

	// HUMTextFieldCell.m
	
	- (BOOL)textFieldShouldReturn:(UITextField *)textField
	{
	    [textField resignFirstResponder];
	    return YES;
	}

This text field will receive and display text for the name and address properties, but will receive a date object and display text for the start and end dates.

So, lets create a method for setting a date on the cell. We'll use this method on the start and end date cells. Declare it as `- (void)setDate:(NSDate *)date` in HUMTextFieldCell.h and definite it as follows:

	// HUMTextFieldCell.m

	- (void)setDate:(NSDate *)date
	{
	    UIDatePicker *picker = [[UIDatePicker alloc] init];
	    [picker addTarget:self
	               action:@selector(changeTextField:)
	     forControlEvents:UIControlEventValueChanged];
	    [picker setDate:date];
	
	    self.textField.inputView = picker;
	}

We're using a `UIDatePicker` as the `textField`'s input view to let the user pick a new date after we set the initial date on the picker. When they pick a new date, the method `changeTextField:` will fire, as we defined with `addTarget:action:forControlEvents:`. Don't forget to `#import "NSDateFormatter+HUMDefaultDateFormatter.h"`.

	// HUMTextFieldCell.m

	- (void)changeTextField:(UIDatePicker *)picker
	{
	    self.textField.text = [[NSDateFormatter hum_RFC3339DateFormatter]
	                           stringFromDate:picker.date];
	}

### Using a Custom Cell

Back in the HUMEventViewController.m, we can use this new custom cell by adding `#import "HUMTextFieldCell.h"` to the top of the file and then registering our new custom cell class with the `tableView`. We'll use the constant string `kTextFieldCellID` that we just defined.   

	// HUMEventViewController.m
	
	- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;
	{
	    self = [super initWithStyle:UITableViewStylePlain];
	    if (!self) {
	        return nil;
	    }
	    
		[self.tableView registerClass:[HUMTextFieldCell class]
			forCellReuseIdentifier:kTextFieldCellID];
		...
	}

Then, define four new properties in our hidden interface.

	// HUMEventViewController.m
	
	@property (strong, nonatomic) HUMTextFieldCell *nameCell;
	@property (strong, nonatomic) HUMTextFieldCell *addressCell;
	@property (strong, nonatomic) HUMTextFieldCell *startCell;
	@property (strong, nonatomic) HUMTextFieldCell *endCell;

Now we can use these properties and the `kTextFieldCellID` identifier in the `tableView:cellForRowAtIndexPath:` method. After we dequeue a new cell with our identifier, we set whether the user can edit the `textField`. We also reset the input view, in case it was previously a UIDatePicker but should now use the keyboard for input.

	// HUMEventViewController.m
	
	- (UITableViewCell *)tableView:(UITableView *)tableView 
			 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
	{
	    HUMTextFieldCell *cell = [tableView
	                              dequeueReusableCellWithIdentifier:kTextFieldCellID
	                              forIndexPath:indexPath];	                              	                              
	   	cell.textField.userInteractionEnabled = self.editable;
	    cell.textField.inputView = nil;
	    
	    // Switch statement to format cell for index path
	    
	    return cell;
	}

Now, on to the switch statement that will format our cells.

	// HUMEventViewController.m
	
    switch (indexPath.row) {
        case HUMEventCellName:
            self.nameCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Name", nil);
            cell.textField.text = self.event.name;
            break;
        case HUMEventCellAddress:
            self.addressCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Address", nil);
            cell.textField.text = self.event.address;
            break;
        case HUMEventCellStart:
            self.startCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"Start Date", nil);
            [cell setDate:self.event.startDate ?: [NSDate date]];
            break;
        case HUMEventCellEnd:
            self.endCell = cell;
            cell.textField.placeholder = NSLocalizedString(@"End Date", nil);
            [cell setDate:self.event.endDate ?: [NSDate date]];
            break;
        case HUMEventCellSubmit:
            cell.textField.text = NSLocalizedString(@"Submit", nil);
            cell.textField.userInteractionEnabled = NO;
            break;
        default:
            break;
    }

Now that all of our cell properties are set, we can run the app and see what it looks like.

### Reflecting Cell Input

We have our new cell properties, but we are still relying on the fake event data we set in the HUMMapViewController.m.

To make a POST to events with user input, we need to:

1) Remove the fake data we placed in HUMMapViewController.m.

Go back to the `addButtonPressed` method in `HUMMapViewController.m` and remove the assignment of the properties `event.name` `event.address` `event.startDate` `event.endDate`. Do not remove the assignment of `event.coordinate`, since we still need that to be set by the HUMMapViewController.

2) Assign our user inputted properties to the event on HUMEventViewController.

	// HUMEventViewController.m

	- (void)tableView:(UITableView *)tableView
	    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    if (indexPath.row != HUMEventCellSubmit)
	        return;
	
	    self.event.name = self.nameCell.textField.text;
	    self.event.address = self.addressCell.textField.text;
	    self.event.startDate = [(UIDatePicker *)
	    	self.startCell.textField.inputView date];
	    self.event.endDate = [(UIDatePicker *)
	    	self.endCell.textField.inputView date];
	    ...
	}
	
Now, go ahead and run the app. The event object that gets posted by the HUMEventViewController now reflects user input.
