//
//  HUMConfirmationViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/6/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMAppearanceManager.h"
#import "HUMButton.h"
#import "HUMConfirmationViewController.h"
#import "HUMEvent.h"

@interface HUMConfirmationViewController ()

@property HUMEvent *event;
@property UIButton *shareButton;
@property HUMButton *doneButton;

@end

@implementation HUMConfirmationViewController

- (id)initWithEvent:(HUMEvent *)event
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _event = event;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Success!", nil);
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:
                                 [UIImage imageNamed:@"HUMSuccessImage"]];
    
    [self createShareButton];
    [self createDoneButton];
}

- (void)createShareButton
{
    HUMButton *button = [[HUMButton alloc] initWithColor:HUMButtonColorGreen];
    [button addTarget:self
               action:@selector(presentActivityViewController)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Share", nil)
            forState:UIControlStateNormal];
    [self.view addSubview:button];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                              multiplier:1.0
                              constant:HUMButtonHeight]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                              multiplier:1.0
                              constant:200.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:-(20.0 + HUMButtonHeight)]];
}

- (void)createDoneButton
{
    HUMButton *button = [[HUMButton alloc] initWithColor:HUMButtonColorGreen];
    [button addTarget:self
               action:@selector(cancelButtonPressed)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(@"Done", nil)
            forState:UIControlStateNormal];
    [self.view addSubview:button];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                              multiplier:1.0
                              constant:HUMButtonHeight]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:nil
                              attribute:NSLayoutAttributeNotAnAttribute
                              multiplier:1.0
                              constant:200.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:button
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:-10.0]];
}

- (void)presentActivityViewController
{
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc]
            initWithActivityItems:@[[self.event humanReadableString]]
            applicationActivities:nil];
    [activityViewController setExcludedActivityTypes:
        @[UIActivityTypeCopyToPasteboard, UIActivityTypePrint]];
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}

- (void)cancelButtonPressed
{
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController
            dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
