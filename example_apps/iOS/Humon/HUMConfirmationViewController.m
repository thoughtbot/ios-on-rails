//
//  HUMConfirmationViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/6/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMConfirmationViewController.h"

@interface HUMConfirmationViewController ()

@property UIButton *shareButton;

@end

@implementation HUMConfirmationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.hidesBackButton = YES;
    
    CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height - 2*44, self.view.bounds.size.width, 44);
    self.shareButton = [[UIButton alloc] initWithFrame:buttonFrame];
    self.shareButton.backgroundColor = [UIColor grayColor];
    [self.shareButton setTitle:@"Share Event" forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(presentActivityViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
}

- (void)presentActivityViewController
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Event info"] applicationActivities:nil];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)cancelButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
