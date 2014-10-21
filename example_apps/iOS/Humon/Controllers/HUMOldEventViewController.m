//
//  HUMOldEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 10/21/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMEvent.h"
#import "HUMOldEventViewController.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"
#import "HUMTextFieldCell.h"

@interface HUMOldEventViewController ()

@property (strong, nonatomic) HUMEvent *event;
@property (assign, nonatomic) BOOL editable;

@property (strong, nonatomic) HUMTextFieldCell *nameCell;
@property (strong, nonatomic) HUMTextFieldCell *addressCell;
@property (strong, nonatomic) HUMTextFieldCell *startCell;
@property (strong, nonatomic) HUMTextFieldCell *endCell;

@end

@implementation HUMOldEventViewController

- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) {
        return nil;
    }

    _event = event;
    _editable = editable;

    [self.tableView registerClass:[HUMTextFieldCell class]
           forCellReuseIdentifier:kTextFieldCellID];

    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (self.editable) {
        return HUMEventCellCount;
    } else {
        return HUMEventCellCount - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HUMTextFieldCell *cell = [tableView
                              dequeueReusableCellWithIdentifier:kTextFieldCellID
                              forIndexPath:indexPath];
    cell.textField.userInteractionEnabled = self.editable;
    cell.textField.inputView = nil;

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

    return cell;
}

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

    [SVProgressHUD show];

    // We could also make this request using our AFN client.
    // [[HUMRailsAFNClient sharedClient] createEvent:self.event
    [[HUMRailsClient sharedClient] createEvent:self.event
        withCompletionBlock:^(NSString *eventID, NSError *error) {

        if (error) {
           [SVProgressHUD showErrorWithStatus:
            NSLocalizedString(@"Failed to create event.", nil)];
        } else {
           [SVProgressHUD dismiss];
           [self.navigationController popToRootViewControllerAnimated:YES];
        }

    }];
}

// Alternate implementation of 'addButtonPressed' in HUMMapViewController
- (void)addButtonPressed
{
    HUMEvent *event = [[HUMEvent alloc] init];
    event.coordinate = CLLocationCoordinate2DMake(37.7583, -122.4275);

    HUMOldEventViewController *eventViewController =
    [[HUMOldEventViewController alloc] initWithEvent:event editable:YES];
    [self.navigationController pushViewController:eventViewController
                                         animated:YES];
}

@end
