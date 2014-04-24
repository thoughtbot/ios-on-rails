//
//  HUMLocateEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 4/23/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMLocateEventViewController.h"
#import "HUMAddEventViewController.h"

@interface HUMLocateEventViewController ()

@property (assign, nonatomic) MKMapRect mapRect;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation HUMLocateEventViewController

- (id)initWithVisibleRect:(MKMapRect)mapRect
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _mapRect = mapRect;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.showsUserLocation = YES;
    self.mapView.visibleMapRect = self.mapRect;
    [self.view addSubview:self.mapView];

    [self addCenteredPlacemark];

    self.title = NSLocalizedString(@"Add an event here?", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                        target:self
                                        action:@selector(backButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                        target:self
                                        action:@selector(nextButtonPressed)];
}

- (void)addCenteredPlacemark
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"HUMLargePlacemark"]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0 constant:0.0]];
}

- (void)backButtonPressed
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextButtonPressed
{
    HUMAddEventViewController *addEventViewController =
        [[HUMAddEventViewController alloc]
        initWithEventCoordinate:self.mapView.centerCoordinate];
    [self.navigationController pushViewController:addEventViewController
                                         animated:YES];
}

@end
