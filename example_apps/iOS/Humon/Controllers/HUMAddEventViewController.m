//
//  HUMAddEventViewController.m
//  Humon
//
//  Created by Diana Zmuda on 11/5/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMAddEventViewController.h"
#import "HUMConfirmationViewController.h"
#import "HUMEvent.h"
#import "HUMFooterView.h"
#import "HUMRailsAFNClient.h"
#import "HUMRailsClient.h"
#import "HUMTextFieldCell.h"
@import AddressBook;

@interface HUMAddEventViewController () <UITextFieldDelegate>

@property (strong, nonatomic) CLGeocoder *geocoder;

@end

@implementation HUMAddEventViewController

- (instancetype)initWithEvent:(HUMEvent *)event
{
    self = [super initWithEvent:event];
    if (!self) {
        return nil;
    }

    _geocoder = [[CLGeocoder alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"New Event", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.event.address) {
        [self reverseGeocodeAddressForCoordinate:self.event.coordinate];
    }
}

#pragma mark - Cell creation helper methods

- (void)addActionToFooterButton:(HUMFooterView *)footer
{
    [footer.button addTarget:self
                      action:@selector(createEvent:)
            forControlEvents:UIControlEventTouchUpInside];
    [footer.button setTitle:NSLocalizedString(@"Create", nil)
                   forState:UIControlStateNormal];
}

#pragma mark - Cell selection methods

- (void)createEvent:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        [sender setEnabled:NO];
    }

    [SVProgressHUD show];

    // We could also make this request using our AFN client.
    // [[HUMRailsAFNClient sharedClient] createEvent:self.event
    [[HUMRailsClient sharedClient] createEvent:self.event
        withCompletionBlock:^(NSString *eventID, NSError *error) {

        if (error) {
            NSLog(@"Event creation error: %@", error);
            [SVProgressHUD showErrorWithStatus:
                            NSLocalizedString(@"Event creation error", nil)];
            return;
        }

        self.event.eventID = eventID;
        [SVProgressHUD dismiss];
        HUMConfirmationViewController *confirmationViewController =
        [[HUMConfirmationViewController alloc] initWithEvent:self.event];
        [self.navigationController pushViewController:confirmationViewController
                                           animated:YES];

    }];
}

#pragma mark - Geocoding methods

- (void)reverseGeocodeAddressForCoordinate:(CLLocationCoordinate2D)coordinate
{
    __weak HUMAddEventViewController *weakSelf = self;

    CLLocation *location = [[CLLocation alloc]
                            initWithLatitude:coordinate.latitude
                            longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks,NSError *error){

        if (error || !placemarks.count) {
            NSLog(@"Reverse geocode error: %@", error);
            return;
        }

        CLPlacemark *placemark = [placemarks firstObject];
        NSDictionary *addressDictionary = placemark.addressDictionary;
        NSString *address =
                    addressDictionary[(NSString *)kABPersonAddressStreetKey];

        weakSelf.event.address = address;
        if (!weakSelf.addressField.text.length) {
            weakSelf.addressField.text = address;
        }
    }];
}

@end
