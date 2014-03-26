//
//  HUMMapViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMMapViewController.h"
#import "HUMAddEventViewController.h"
#import <MapKit/MapKit.h>

@interface HUMMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *addButton;

@end

@implementation HUMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    CGRect buttonFrame = CGRectMake(0, self.view.bounds.size.height - 2*44, self.view.bounds.size.width, 44);
    self.addButton = [[UIButton alloc] initWithFrame:buttonFrame];
    self.addButton.backgroundColor = [UIColor grayColor];
    [self.addButton setTitle:@"Add Event" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
}

- (void)addButtonPressed
{
    HUMAddEventViewController *addEventViewController = [[HUMAddEventViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addEventViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
