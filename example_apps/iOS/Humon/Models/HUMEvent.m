//
//  HUMEvent.m
//  Humon
//
//  Created by Diana Zmuda on 11/25/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMEvent.h"
#import "HUMUser.h"
#import "HUMUserSession.h"
#import "NSDateFormatter+HUMDefaultDateFormatter.h"
#import "NSObject+HUMNullCheck.h"

@implementation HUMEvent

+ (NSArray *)eventsWithJSON:(NSArray *)JSON
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    for (NSDictionary *eventJSON in JSON) {
        HUMEvent *event = [[HUMEvent alloc] initWithJSON:eventJSON];
        [events addObject:event];
    }
    
    return [events copy];
}

- (instancetype)initWithJSON:(NSDictionary *)JSON
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _name = JSON[@"name"];
    if ([JSON[@"address"] hum_isNotNull]) {
        _address = JSON[@"address"];
    }

    _startDate = [[NSDateFormatter hum_RFC3339DateFormatter]
                  dateFromString:JSON[@"started_at"]];
    if ([JSON[@"ended_at"] hum_isNotNull]) {
        _endDate = [[NSDateFormatter hum_RFC3339DateFormatter]
                    dateFromString:JSON[@"ended_at"]];
    }

    double lat = [JSON[@"lat"] doubleValue];
    double lon = [JSON[@"lon"] doubleValue];
    _coordinate = CLLocationCoordinate2DMake(lat, lon);

    _user = [[HUMUser alloc] initWithJSON:JSON[@"owner"]];
    _eventID = [NSString stringWithFormat:@"%@", JSON[@"id"]];
    _attendees = [JSON[@"attendees"] integerValue];
    
    return self;
}

- (NSDictionary *)JSONDictionary
{
    NSMutableDictionary *JSONDictionary = [[NSMutableDictionary alloc] init];


    [JSONDictionary setObject:self.name forKey:@"name"];
    if (self.address) {
        [JSONDictionary setObject:self.address forKey:@"address"];
    }

    [JSONDictionary setObject:@(self.coordinate.latitude) forKey:@"lat"];
    [JSONDictionary setObject:@(self.coordinate.longitude) forKey:@"lon"];

    if (!self.startDate) {
        self.startDate = [NSDate date];
    }
    NSString *start = [[NSDateFormatter hum_RFC3339DateFormatter]
                       stringFromDate:self.startDate];
    [JSONDictionary setObject:start forKey:@"started_at"];

    NSString *end = [[NSDateFormatter hum_RFC3339DateFormatter]
                     stringFromDate:self.endDate];
    if (end) {
        [JSONDictionary setObject:end forKey:@"ended_at"];
    }

    NSDictionary *user = @{@"device_token" : [HUMUserSession userID]};
    [JSONDictionary setObject:user forKey:@"owner"];
    
    return [JSONDictionary copy];
}

- (NSString *)humanReadableString
{
    NSString *sharingString = [NSString stringWithFormat:@"%@ at %@, %@", self.name, self.address, self.startDate];
    return sharingString;
}

#pragma mark - Methods for comparing events

- (NSUInteger)hash
{
    if (!self.eventID) {
        return [super hash];
    }

    NSString *hashString = [NSString stringWithFormat:
                            @"%@%@",
                            self.eventID,
                            self.user.userID];
    return [hashString hash];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![self isKindOfClass:[object class]]) {
        return NO;
    }

    HUMEvent *event = (HUMEvent *)object;
    
    BOOL objectsHaveSameID = [self.eventID isEqualToString:event.eventID];
    BOOL objectsHaveSameUser = [self.user.userID isEqualToString:event.user.userID];

    // TODO: This won't be necessary once the API stops returning owners with NULL tokens
    if (self.user.userID == event.user.userID) {
        objectsHaveSameUser = YES;
    }

    return objectsHaveSameID && objectsHaveSameUser;
}

#pragma mark - MKAnnotation Protocol

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

@end
