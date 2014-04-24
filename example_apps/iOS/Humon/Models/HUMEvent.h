//
//  HUMEvent.h
//  Humon
//
//  Created by Diana Zmuda on 11/25/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

@class HUMUser;
@import MapKit;

@interface HUMEvent : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) HUMUser *user;
@property (copy, nonatomic) NSString *eventID;
@property (assign, nonatomic) NSInteger attendees;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

+ (NSArray *)eventsWithJSON:(NSArray *)JSON;
- (instancetype)initWithJSON:(NSDictionary *)JSON;
- (NSDictionary *)JSONDictionary;

@end
