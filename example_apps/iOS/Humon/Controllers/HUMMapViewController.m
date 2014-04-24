//
//  HUMMapViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMMapViewController.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"
#import "HUMEvent.h"
#import "HUMUserSession.h"
@import MapKit;
#import "HUMLocateEventViewController.h"

@interface HUMMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) NSURLSessionDataTask *currentEventGetTask;

@end

@implementation HUMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];

    self.title = NSLocalizedString(@"Humon", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                            target:self
                                            action:@selector(addButtonPressed)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![HUMUserSession userID]) {
        
        [SVProgressHUD show];
        
        [[HUMRailsAFNClient sharedClient]
            createCurrentUserWithCompletionBlock:^(NSError *error) {
            
            if (error) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"App authentication error", nil)];
            } else {
                [SVProgressHUD dismiss];
                [self reloadEventsOnMap];
            }
            
        }];
        
    } else {
        [self reloadEventsOnMap];
    }
}

- (void)addButtonPressed
{
    HUMLocateEventViewController *locateEventController =
        [[HUMLocateEventViewController alloc]
         initWithVisibleRect:self.mapView.visibleMapRect];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locateEventController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Map delegate methods

- (void)mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.mapView.region = MKCoordinateRegionMakeWithDistance(
                            self.mapView.userLocation.coordinate, 1000, 1000);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self reloadEventsOnMap];
}

#pragma mark - Map helper methods

- (void)reloadEventsOnMap
{
    if (![HUMUserSession userID]) {
        return;
    }
    
    [self.currentEventGetTask cancel];
    self.currentEventGetTask = [[HUMRailsAFNClient sharedClient]
                                fetchEventsInRegion:self.mapView.region
                                withCompletionBlock:^(NSArray *events) {

        if (events) {
            self.currentEventGetTask = nil;
            [self updateMapViewAnnotationsWithAnnotations:events];
        }

    }];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    NSSet *after = [NSSet setWithArray:annotations];
    
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    [self.mapView addAnnotations:[toAdd allObjects]];
    [self.mapView removeAnnotations:[toRemove allObjects]];
}

@end
