//
//  HUMLocateEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 4/23/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMAddEventViewController.h"
#import "HUMEvent.h"
#import "HUMLocateEventViewController.h"

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

    [self createMapView];
    [self createCenteredPlacemark];

    self.title = NSLocalizedString(@"Add an event here?", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                        target:self
                                        action:@selector(cancelButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                    initWithImage:[UIImage imageNamed:@"HUMChevronForward"]
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(nextButtonPressed)];
}

- (void)createMapView
{
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.visibleMapRect = self.mapRect;
    [self.view addSubview:self.mapView];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.mapView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.mapView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:1.0
                              constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.mapView
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0
                              constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.mapView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0]];
}

- (void)createCenteredPlacemark
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:
                              [UIImage imageNamed:@"HUMPlacemarkLarge"]];
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

    NSArray *images = @[[UIImage imageNamed:@"HUMPlacemarkLarge"],
                        [UIImage imageNamed:@"HUMPlacemarkLargeTalking"]];
    imageView.image = [UIImage animatedImageWithImages:images duration:0.4];
    [imageView startAnimating];
}

- (void)cancelButtonPressed
{
    [self.navigationController.presentingViewController
        dismissViewControllerAnimated:YES
        completion:nil];
}

- (void)nextButtonPressed
{
    HUMEvent *event = [[HUMEvent alloc] init];
    event.coordinate = self.mapView.centerCoordinate;
    HUMAddEventViewController *addEventViewController =
        [[HUMAddEventViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:addEventViewController
                                         animated:YES];
}

@end
