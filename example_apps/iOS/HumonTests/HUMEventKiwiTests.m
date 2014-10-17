//
//  HUMEventKiwiTests.m
//  Humon
//
//  Created by Diana Zmuda on 1/9/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "Kiwi.h"
#import "HUMEvent.h"
#import "HUMJSONFileManager.h"

SPEC_BEGIN(HUMEventSpec)

describe(@"Event object", ^{

    __block NSDictionary *JSON;
    __block HUMEvent *event;

    beforeAll(^{
        JSON = [HUMJSONFileManager singleEventJSON];
        event = [[HUMEvent alloc] initWithJSON:JSON];
    });

    it(@"should not be nil", ^{
        [[event shouldNot] beNil];
    });

    it(@"should initialize multiple events", ^{
        NSArray *JSONarray = [HUMJSONFileManager multipleEventsJSON];
        NSArray *eventArray = [HUMEvent eventsWithJSON:JSONarray];
        [[theValue(eventArray.count) should] equal:theValue(JSONarray.count)];
    });

    it(@"should generate JSON from the object", ^{
        NSMutableDictionary *desiredJSON = [JSON mutableCopy];
        [desiredJSON removeObjectForKey:@"owner"];
        BOOL jsonIsTheSame = [[event JSONDictionary] isEqualToDictionary:desiredJSON];
        [[theValue(jsonIsTheSame) should] equal:theValue(YES)];
    });

    it(@"should have a human readable string", ^{
        NSString *readableString = @"Picnic at Dolores Park, 9/15/13, 5:00 PM";
        [[event.humanReadableString should] equal:readableString];
    });

    it(@"should be the same as an event with the same ID and user", ^{
        HUMEvent *sameEvent = [[HUMEvent alloc] initWithJSON:JSON];
        [[event should] equal:sameEvent];
    });

});

SPEC_END
