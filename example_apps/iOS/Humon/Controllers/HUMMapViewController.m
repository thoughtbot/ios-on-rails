//
//  HUMMapViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMAnnotationView.h"
#import "HUMEditEventViewController.h"
#import "HUMEvent.h"
#import "HUMLocateEventViewController.h"
#import "HUMMapViewController.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"
#import "HUMUser.h"
#import "HUMUserSession.h"
#import "HUMViewEventViewController.h"
@import MapKit;

@interface HUMMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSURLSessionTask *currentEventGetTask;

@property (assign, nonatomic) BOOL hasUpdatedUserLocation;

@end

@implementation HUMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Humon", nil);
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
        target:self
        action:@selector(addButtonPressed)];
    self.navigationItem.leftBarButtonItem = button;

    [self createMapView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (![HUMUserSession userIsLoggedIn]) {
        
        [SVProgressHUD showWithStatus:
            NSLocalizedString(@"Loading Events", nil)];

        // We could also make this request using our AFN client.
        // [[HUMRailsAFNClient sharedClient]
        [[HUMRailsClient sharedClient]
            createCurrentUserWithCompletionBlock:^(NSError *error) {

            if (error) {
                [SVProgressHUD showErrorWithStatus:
                    NSLocalizedString(@"App authentication error", nil)];
            } else {
                [SVProgressHUD dismiss];
                [self reloadEventsOnMap];
            }

        }];
        
    } else {
        [self reloadEventsOnMap];
    }
}

- (void)createMapView
{
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
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

- (void)addButtonPressed
{
    HUMLocateEventViewController *locateEventController =
        [[HUMLocateEventViewController alloc]
         initWithVisibleRect:self.mapView.visibleMapRect];
    UINavigationController *navigationController =
        [[UINavigationController alloc]
         initWithRootViewController:locateEventController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

#pragma mark - Map delegate methods

- (void)mapView:(MKMapView *)mapView
    didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.hasUpdatedUserLocation) {
        self.mapView.region = MKCoordinateRegionMakeWithDistance(
                            self.mapView.userLocation.coordinate, 1000, 1000);
        self.hasUpdatedUserLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self reloadEventsOnMap];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    HUMEvent *event = annotation;
    NSString *annotationType = [event.user isCurrentUser] ?
        HUMMapViewControllerAnnotationGreen : HUMMapViewControllerAnnotationGrey;
    MKAnnotationView *annotationView =
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationType];

    if (!annotationView) {
        annotationView = [[HUMAnnotationView alloc]
                          initWithAnnotation:annotation
                          reuseIdentifier:annotationType];
    }

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView
    didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view respondsToSelector:@selector(startAnimating)]) {
        [(HUMAnnotationView *)view startAnimating];
    }
}

- (void)mapView:(MKMapView *)mapView
    didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view respondsToSelector:@selector(stopAnimating)]) {
        [(HUMAnnotationView *)view stopAnimating];
    }
}

- (void)mapView:(MKMapView *)mapView
    annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[HUMEvent class]]) {
        HUMEvent *event = view.annotation;

        if ([event.user isCurrentUser]) {
            [self.navigationController pushViewController:
                [[HUMEditEventViewController alloc] initWithEvent:event]
                                                 animated:YES];
        } else {
            [self.navigationController pushViewController:
             [[HUMViewEventViewController alloc] initWithEvent:event]
                                                 animated:YES];
        }

    }
}

#pragma mark - Map helper methods

- (void)reloadEventsOnMap
{
    if (![HUMUserSession userIsLoggedIn]) {
        return;
    }
    
    [self.currentEventGetTask cancel];

    // We could also make this request using our AFN client.
    // self.currentEventGetTask =  [[HUMRailsAFNClient sharedClient]
    self.currentEventGetTask = [[HUMRailsClient sharedClient]
        fetchEventsInRegion:self.mapView.region
        withCompletionBlock:^(NSArray *events, NSError *error) {

        if (error && error.code != NSURLErrorCancelled) {
            NSLog(@"Event fetch error: %@", error);
        }
                                    
        if (events) {
            self.currentEventGetTask = nil;
            [self updateMapViewAnnotationsWithAnnotations:events];
        }

    }];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    if (!annotations.count) {
        return;
    }

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
