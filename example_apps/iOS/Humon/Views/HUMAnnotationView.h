//
//  HUMAnnotationView.h
//  Humon
//
//  Created by Diana Zmuda on 5/13/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import <MapKit/MapKit.h>

static NSString *const HUMMapViewControllerAnnotationGreen = @"HUMMapViewControllerAnnotationGreen";
static NSString *const HUMMapViewControllerAnnotationGrey = @"HUMMapViewControllerAnnotationGrey";

@interface HUMAnnotationView : MKAnnotationView

- (void)startAnimating;
- (void)stopAnimating;

@end
