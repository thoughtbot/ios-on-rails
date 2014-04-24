//
//  HUMConfirmationViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/6/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMConfirmationViewController.h"
#import "HUMButton.h"
#import "HUMAppearanceManager.h"

@interface HUMConfirmationViewController ()

@property UIButton *shareButton;
@property HUMButton *doneButton;

@end

@implementation HUMConfirmationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Success!", nil);
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [HUMAppearanceManager humonGreen];
    
    [self createShareButton];
    [self createDoneButton];
}

- (void)createShareButton
{
    HUMButton *button = [[HUMButton alloc] init];
    [button addTarget:self
               action:@selector(presentActivityViewController)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [self.view addSubview:button];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:HUMButtonHeight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:80.0]];
}

- (void)createDoneButton
{
    HUMButton *button = [[HUMButton alloc] init];
    [button addTarget:self
               action:@selector(cancelButtonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.view addSubview:button];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:HUMButtonHeight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0]];
}

- (void)presentActivityViewController
{
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc]
            initWithActivityItems:@[@"Event info"]
            applicationActivities:nil];
    [activityViewController setExcludedActivityTypes:
        @[UIActivityTypeCopyToPasteboard, UIActivityTypePrint]];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}

- (void)cancelButtonPressed
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
