//
//  HUMAddEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMAddEventViewController.h"
#import "HUMConfirmationViewController.h"

static NSString *const HUMAddEventCellIdentifier = @"HUMAddEventCellIdentifier";

@interface HUMAddEventViewController ()

@end

@implementation HUMAddEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HUMAddEventCellIdentifier];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
}

- (void)cancelButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HUMAddEventCellIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HUMConfirmationViewController *confirmationViewController = [[HUMConfirmationViewController alloc] init];
    [self.navigationController pushViewController:confirmationViewController animated:YES];
}

@end
