#import "HUMAppearanceManager.h"
#import "HUMEvent.h"
#import "HUMEventViewController.h"
#import "HUMFooterView.h"
#import "HUMTextFieldCell.h"
#import "HUMTimeCell.h"
#import "HUMTimePickerCell.h"
@import MapKit;

static NSInteger HUMEventHeaderHeight = 20;
static NSInteger HUMEventFooterHeight = 88;

@interface HUMEventViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSIndexPath *indexCurrentlyDisplayingTimePicker;
@property (strong, nonatomic) UIButton *actionButton;

@end

@implementation HUMEventViewController

- (instancetype)initWithEvent:(HUMEvent *)event
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) {
        return nil;
    }

    _event = event;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [HUMAppearanceManager humonGrey];
    self.tableView.separatorColor = [HUMAppearanceManager humonWhite];
    self.tableView.contentInset = UIEdgeInsetsMake(HUMEventHeaderHeight,0,0,0);

    [self.tableView registerClass:[HUMTextFieldCell class]
           forCellReuseIdentifier:kTextFieldCellID];
    [self.tableView registerClass:[HUMTimeCell class]
           forCellReuseIdentifier:kTimeCellID];
    [self.tableView registerClass:[HUMTimePickerCell class]
           forCellReuseIdentifier:kTimePickerCellID];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
         initWithImage:[UIImage imageNamed:@"HUMChevronBack"]
         style:UIBarButtonItemStylePlain
         target:self
         action:@selector(backButtonPressed)];
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return HUMEventSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return HUMEventHeaderHeight;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
{
    switch (section) {

        case HUMEventSectionName:
            return NSLocalizedString(@"Name", nil);

        case HUMEventSectionAddress:
            return NSLocalizedString(@"Address", nil);

        case HUMEventSectionStart:
            return NSLocalizedString(@"Start time", nil);

        case HUMEventSectionEnd:
            return NSLocalizedString(@"End time", nil);

        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section
{
    if (section == HUMEventSectionCount - 1) {
        return HUMEventFooterHeight;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForFooterInSection:(NSInteger)section
{
    if (section == HUMEventSectionCount - 1) {
        HUMFooterView *footer = [[HUMFooterView alloc] init];
        self.actionButton = footer.button;
        [self enableActionButtonIfNeeded];
        [self addActionToFooterButton:footer];
        return footer;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    if (self.indexCurrentlyDisplayingTimePicker &&
        self.indexCurrentlyDisplayingTimePicker.section == section) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.row == 1) {
        cell = [self timePickerCell];
    } else {
        cell = [self textFieldCellForIndexPath:indexPath];
    }

	return cell;
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == HUMEventSectionStart ||
        indexPath.section == HUMEventSectionEnd) {
        if ([self.indexCurrentlyDisplayingTimePicker isEqual:indexPath]) {
            [self dismissDatePicker];
        } else {
            [self showDatePickerAtIndexPath:indexPath];
        }
        [self.view endEditing:YES];
    }
}

- (void)dismissDatePicker
{
    if (!self.indexCurrentlyDisplayingTimePicker) {
        return;
    }

    NSIndexPath *indexPreviouslyDisplayingTimePicker =
    [self.indexCurrentlyDisplayingTimePicker copy];
    NSIndexPath *indexOfTimePicker = [NSIndexPath indexPathForRow:1
        inSection:indexPreviouslyDisplayingTimePicker.section];

    self.indexCurrentlyDisplayingTimePicker = nil;
    [self.tableView deleteRowsAtIndexPaths:@[indexOfTimePicker]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showDatePickerAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissDatePicker];

    self.indexCurrentlyDisplayingTimePicker = indexPath;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath
                                              indexPathForRow:1
                                              inSection:indexPath.section]]
                          withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Cell creation helper methods

- (HUMTextFieldCell *)textFieldCellForIndexPath:(NSIndexPath *)indexPath
{
    HUMTextFieldCell *cell;

    switch (indexPath.section) {

        case HUMEventSectionName:
            cell = [self nameCell];
            break;

        case HUMEventSectionAddress:
            cell = [self addressCell];
            break;

        case HUMEventSectionStart:
            cell = [self startDateCell];
            break;

        case HUMEventSectionEnd:
            cell = [self endDateCell];
            break;

        default:
            break;
    }

    cell.textField.delegate = self;

    return cell;
}

- (HUMTextFieldCell *)nameCell
{
    HUMTextFieldCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kTextFieldCellID];

    cell.textField.text = self.event.name;
    cell.textField.placeholder = NSLocalizedString(@"Required", nil);
    self.nameField = cell.textField;
    return cell;
}

- (HUMTextFieldCell *)addressCell
{
    HUMTextFieldCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kTextFieldCellID];

    cell.textField.text = self.event.address;
    cell.textField.placeholder = NSLocalizedString(@"Optional", nil);
    self.addressField = cell.textField;

    return cell;
}

- (HUMTimeCell *)startDateCell
{
    HUMTimeCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kTimeCellID];

    cell.textField.placeholder = NSLocalizedString(@"Required", nil);
    cell.date = self.event.startDate;
    return cell;
}

- (HUMTimeCell *)endDateCell
{
    HUMTimeCell *cell = [self.tableView
        dequeueReusableCellWithIdentifier:kTimeCellID];

    cell.textField.placeholder = NSLocalizedString(@"Optional", nil);
    cell.date = self.event.endDate;
    return cell;
}

- (HUMTimePickerCell *)timePickerCell
{
    HUMTimePickerCell *timePickerCell = [self.tableView
        dequeueReusableCellWithIdentifier:kTimePickerCellID];

    if (self.indexCurrentlyDisplayingTimePicker.section
        == HUMEventSectionStart) {
        timePickerCell.datePicker.date = self.event.startDate ?: [NSDate date];
    } else if (self.indexCurrentlyDisplayingTimePicker.section
               == HUMEventSectionEnd) {
        timePickerCell.datePicker.date = self.event.endDate ?: [NSDate date];
    }

    [timePickerCell.datePicker addTarget:self
                                  action:@selector(updateDateCell:)
                        forControlEvents:UIControlEventValueChanged];
    return timePickerCell;
}

- (void)addActionToFooterButton:(HUMFooterView *)footer
{
    // To be overwritten by subclasses of HUMEventViewController
    // so they can customize the footer button's action and title.
}

#pragma mark - Cell selection methods

- (void)updateDateCell:(UIDatePicker *)picker
{
    HUMTimeCell *timeCell = (HUMTimeCell *)[self.tableView
        cellForRowAtIndexPath:self.indexCurrentlyDisplayingTimePicker];
    [timeCell setDate:picker.date];

    if (self.indexCurrentlyDisplayingTimePicker.section
        == HUMEventSectionStart) {
        self.event.startDate = picker.date;
        [self enableActionButtonIfNeeded];
    } else if (self.indexCurrentlyDisplayingTimePicker.section
               == HUMEventSectionEnd) {
        self.event.endDate = picker.date;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self dismissDatePicker];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameField) {
        self.event.name = textField.text;
    } else if (textField == self.addressField) {
        self.event.address = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string
{
    [self enableActionButtonIfNeeded];
    return YES;
}

- (void)enableActionButtonIfNeeded
{
    BOOL eventFieldsAreValid = self.event.name.length &&
                               self.event.address.length &&
                               self.event.startDate;
    self.actionButton.enabled = eventFieldsAreValid;
}

@end
