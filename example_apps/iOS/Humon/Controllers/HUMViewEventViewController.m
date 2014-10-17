//
//  HUMViewEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 5/7/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMConfirmationViewController.h"
#import "HUMEvent.h"
#import "HUMFooterView.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"
#import "HUMViewEventViewController.h"

@interface HUMViewEventViewController () <UITextFieldDelegate>

@end

@implementation HUMViewEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"View Event", nil);
}

#pragma mark - Cell creation helper methods

- (void)addActionToFooterButton:(HUMFooterView *)footer
{
    [footer.button addTarget:self action:@selector(joinEvent:)
            forControlEvents:UIControlEventTouchUpInside];
    [footer.button setTitle:NSLocalizedString(@"Join", nil)
                   forState:UIControlStateNormal];
}

#pragma mark - Cell selection methods

- (void)joinEvent:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        [sender setEnabled:NO];
    }
    
    [SVProgressHUD show];

    // We could also make this request using our AFN client.
    // [[HUMRailsAFNClient sharedClient]
    [[HUMRailsClient sharedClient]
        createAttendanceForEvent:self.event
        withCompletionBlock:^(NSError *error) {

        if (error) {
            NSLog(@"Event join error: %@", error);
            [SVProgressHUD showErrorWithStatus:
            NSLocalizedString(@"Event join error", nil)];
            return;
        }

        [SVProgressHUD dismiss];
        HUMConfirmationViewController *confirmationViewController =
        [[HUMConfirmationViewController alloc] initWithEvent:self.event];
        [self.navigationController pushViewController:confirmationViewController
                                             animated:YES];

    }];
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do nothing.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

@end
