//
//  HUMEditEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 5/7/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMConfirmationViewController.h"
#import "HUMEditEventViewController.h"
#import "HUMEvent.h"
#import "HUMFooterView.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"

@interface HUMEditEventViewController ()

@end

@implementation HUMEditEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Edit Event", nil);
}

#pragma mark - Cell creation helper methods

- (void)addActionToFooterButton:(HUMFooterView *)footer
{
    [footer.button addTarget:self action:@selector(changeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [footer.button setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
}

#pragma mark - Cell selection methods

- (void)changeEvent:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        [sender setEnabled:NO];
    }

    [SVProgressHUD show];

    // We could also make this request using our AFN client.
    //[[HUMRailsAFNClient sharedClient] changeEvent:self.event
    [[HUMRailsClient sharedClient] changeEvent:self.event
        withCompletionBlock:^(NSString *eventID, NSError *error) {

                                  if (error || ![eventID isEqualToString:self.event.eventID]) {
                                      NSLog(@"Event edit error: %@", error);
                                      [SVProgressHUD showErrorWithStatus:
                                       NSLocalizedString(@"Event edit error", nil)];
                                      return;
                                  }

                                  [SVProgressHUD dismiss];
                                  HUMConfirmationViewController *confirmationViewController =
                                  [[HUMConfirmationViewController alloc] initWithEvent:self.event];
                                  [self.navigationController pushViewController:confirmationViewController
                                                                       animated:YES];
                                  
                              }];
}

@end
