//
//  HUMAddEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMAddEventViewController.h"
#import "HUMConfirmationViewController.h"
#import "HUMEvent.h"
#import "HUMRailsAFNClient.h"
#import "HUMUserSession.h"
#import "HUMAppearanceManager.h"

#import "HUMTextFieldCell.h"
#import "HUMTimeCell.h"
#import "HUMTimePickerCell.h"
@import AddressBook;
#import "HUMFooterView.h"

static NSInteger HUMAddEventHeaderHeight = 20;
static NSInteger HUMAddEventFooterHeight = 88;

typedef NS_ENUM(NSUInteger, HUMAddEventSection) {
    HUMAddEventSectionName,
    HUMAddEventSectionAddress,
    HUMAddEventSectionStart,
    HUMAddEventSectionEnd,
    HUMAddEventSectionCount
};

@interface HUMAddEventViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSIndexPath *indexCurrentlyDisplayingTimePicker;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *addressField;

@property (strong, nonatomic) HUMEvent *event;
@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation HUMAddEventViewController

- (instancetype)initWithEventCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) {
        return nil;
    }

    HUMEvent *event = [[HUMEvent alloc] init];
    event.coordinate = coordinate;
    _event = event;

    _geocoder = [[CLGeocoder alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [HUMAppearanceManager humonGreen];
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(HUMAddEventHeaderHeight, 0, 0, 0);

    [self.tableView registerClass:[HUMTextFieldCell class]
           forCellReuseIdentifier:kTextFieldCellID];
    [self.tableView registerClass:[HUMTimeCell class]
           forCellReuseIdentifier:kTimeCellID];
    [self.tableView registerClass:[HUMTimePickerCell class]
           forCellReuseIdentifier:kTimePickerCellID];

    self.title = NSLocalizedString(@"New Event", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
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
    return HUMAddEventSectionCount;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return HUMAddEventHeaderHeight;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
{
    switch (section) {

        case HUMAddEventSectionName:
            return NSLocalizedString(@"Name", nil);

        case HUMAddEventSectionAddress:
            return NSLocalizedString(@"Address", nil);

        case HUMAddEventSectionStart:
            return NSLocalizedString(@"Start time", nil);

        case HUMAddEventSectionEnd:
            return NSLocalizedString(@"End time", nil);
            
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section
{
    if (section == HUMAddEventSectionCount - 1) {
        return HUMAddEventFooterHeight;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForFooterInSection:(NSInteger)section
{
    if (section == HUMAddEventSectionCount - 1) {
        HUMFooterView *footer = [[HUMFooterView alloc] init];
        [footer.button addTarget:self action:@selector(createEvent) forControlEvents:UIControlEventTouchUpInside];
        [footer.button setTitle:NSLocalizedString(@"Create", nil) forState:UIControlStateNormal];
        return footer;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.tableView.rowHeight;
    } else {
        return kTimePickerCellHeight;
    }
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
    if (indexPath.section == HUMAddEventSectionStart ||
        indexPath.section == HUMAddEventSectionEnd) {
        if ([self.indexCurrentlyDisplayingTimePicker isEqual:indexPath]) {
            [self dismissDatePicker];
        } else {
            [self showDatePickerAtIndexPath:indexPath];
        }
    }
}

- (void)dismissDatePicker
{
    if (!self.indexCurrentlyDisplayingTimePicker) {
        return;
    }

    NSIndexPath *indexPreviouslyDisplayingTimePicker = [self.indexCurrentlyDisplayingTimePicker copy];

    self.indexCurrentlyDisplayingTimePicker = nil;
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:indexPreviouslyDisplayingTimePicker.section]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showDatePickerAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissDatePicker];

    self.indexCurrentlyDisplayingTimePicker = indexPath;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Cell creation helper methods

- (HUMTextFieldCell *)textFieldCellForIndexPath:(NSIndexPath *)indexPath
{
    HUMTextFieldCell *cell;

    switch (indexPath.section) {

        case HUMAddEventSectionName:
            cell = [self nameCell];
            break;

        case HUMAddEventSectionAddress:
            cell = [self addressCell];
            break;

        case HUMAddEventSectionStart:
            cell = [self startDateCell];
            break;

        case HUMAddEventSectionEnd:
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
    cell.textField.userInteractionEnabled = YES;
    self.nameField = cell.textField;
    return cell;
}

- (HUMTextFieldCell *)addressCell
{
    HUMTextFieldCell *cell = [self.tableView
                         dequeueReusableCellWithIdentifier:kTextFieldCellID];
    cell.textField.text = self.event.address;
    cell.textField.userInteractionEnabled = YES;
    self.addressField = cell.textField;

    if (!self.event.address) {
        [self reverseGeocodeAddressForCoordinate:self.event.coordinate];
    }

    return cell;
}

- (HUMTimeCell *)startDateCell
{
    HUMTimeCell *cell = [self.tableView
                         dequeueReusableCellWithIdentifier:kTimeCellID];
    cell.date = self.event.startDate;
    cell.textField.userInteractionEnabled = NO;
    return cell;
}

- (HUMTimeCell *)endDateCell
{
    HUMTimeCell *cell = [self.tableView
                         dequeueReusableCellWithIdentifier:kTimeCellID];
    cell.date = self.event.endDate;
    cell.textField.userInteractionEnabled = NO;
    return cell;
}

- (HUMTimePickerCell *)timePickerCell
{
    HUMTimePickerCell *timePickerCell = [self.tableView
                                         dequeueReusableCellWithIdentifier:kTimePickerCellID];

    if (self.indexCurrentlyDisplayingTimePicker.section == HUMAddEventSectionStart) {
        timePickerCell.datePicker.date = self.event.startDate ?: [NSDate date];
    } else if (self.indexCurrentlyDisplayingTimePicker.section == HUMAddEventSectionEnd) {
        timePickerCell.datePicker.date = self.event.endDate ?: [NSDate date];
    }

    [timePickerCell.datePicker addTarget:self
                                  action:@selector(updateDateCell:)
                        forControlEvents:UIControlEventValueChanged];
    return timePickerCell;
}

#pragma mark - Cell selection methods

- (void)updateDateCell:(UIDatePicker *)picker
{
    HUMTimeCell *timeCell = (HUMTimeCell *)[self.tableView cellForRowAtIndexPath:self.indexCurrentlyDisplayingTimePicker];
    [timeCell setDate:picker.date];

    if (self.indexCurrentlyDisplayingTimePicker.section == HUMAddEventSectionStart) {
        self.event.startDate = picker.date;
    } else if (self.indexCurrentlyDisplayingTimePicker.section == HUMAddEventSectionEnd) {
        self.event.endDate = picker.date;
    }
}

- (void)createEvent
{
    if (!self.nameField.text || !self.event.startDate) {
        return;
    }

    [SVProgressHUD show];
    [[HUMRailsAFNClient sharedClient] createEvent:self.event
                              withCompletionBlock:^(HUMEvent *event) {

        if (!event) {
          [SVProgressHUD showErrorWithStatus:
                            NSLocalizedString(@"Event creation error", nil)];
          return;
        }

        [SVProgressHUD dismiss];
        HUMConfirmationViewController *confirmationViewController =
        [[HUMConfirmationViewController alloc] init];
        [self.navigationController pushViewController:confirmationViewController
                                           animated:YES];

    }];
}

#pragma mark - Geocoding methods

- (void)reverseGeocodeAddressForCoordinate:(CLLocationCoordinate2D)coordinate
{
    __weak HUMAddEventViewController *weakSelf = self;

    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:coordinate.latitude
                            longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks,NSError *error){

        if (error || !placemarks.count) {
            return;
        }

        CLPlacemark *placemark = [placemarks firstObject];
        NSDictionary *addressDictionary = placemark.addressDictionary;
        NSString *address =
                    addressDictionary[(NSString *)kABPersonAddressStreetKey];

        weakSelf.event.address = address;
        self.addressField.text = address;
    }];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
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

@end
