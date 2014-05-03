# The Event Object

Users will be interacting with the HUMAddEventViewController to create events in the app. 

### Creating an Event Object

Create a subclass of NSObject called HUMEvent. This subclass will have a series of properties that define each event object.

Add the following properties to your HUMEvent.h's `@interface`:

	// HUMEvent.h
	
	// Properties set on creation of the event object
	@property (copy, nonatomic) NSString *name;
	@property (copy, nonatomic) NSString *address;
	@property (strong, nonatomic) NSDate *startDate;
	@property (strong, nonatomic) NSDate *endDate;
	
	// Properties set by the rails API
	@property (strong, nonatomic) HUMUser *user;
	@property (strong, nonatomic) NSNumber *eventID;
	@property (assign, nonatomic) NSInteger attendees;
	
	// Properties used for placing the event on a map
	@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
	
We use the `copy` property attribute for the properties that are of type NSString so that if we set the property `name` to a NSMutableString and then mutate the string, the property `name` will not change with the mutation.

For properties like `user`, we want to be able to mutate the object after setting it as a property, so we use the `strong` property attribute.

For properties that are primitives like `attendees`, we use `assign`.

### Methods for Initializing an Event

Declare three methods for intializing HUMEvent objects:

	// HUMEvent.h

	+ (NSArray *)eventsWithJSON:(NSArray *)JSON;
	- (instancetype)initWithJSON:(NSDictionary *)JSON;
	- (NSDictionary *)JSONDictionary;

`initWithJSON:` is a custom intialization method for creating a HUMEvent object with a JSON dictionary from the API. It initializes a HUMEvent object and sets its properties to corresponding values from the `eventJSON` dictionary. We haven't defined the `RFC3339DateFormatter` yet, but we will do so in the next section.

	// HUMEvent.m
	
	- (instancetype)initWithJSON:(NSDictionary *)JSON
	{
    	self = [super init];
    
    	if (!self)
        	return nil;
    
        _name = JSON[@"name"];
        _address = JSON[@"address"];
        
        _startDate = [[NSDateFormatter RFC3339DateFormatter]
                      dateFromString:JSON[@"started_at"]];
        _endDate = [[NSDateFormatter RFC3339DateFormatter]
                    dateFromString:JSON[@"ended_at"]];
        
        double lat = [JSON[@"lat"] doubleValue];
        double lon = [JSON[@"lon"] doubleValue];
        _coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        _user = [[HUMUser alloc] initWithJSON:JSON[@"user"]];
        _eventID = JSON[@"id"];
        _attendees = [JSON[@"attendees"] integerValue];
    
    	return self;
	}

`eventsWithJSON:` is a class method that takes in an array of JSON dictionaries and returns an array of HUMEvent objects.

	// HUMEvent.m
	
	+ (NSArray *)eventsWithJSON:(NSArray *)JSON
	{
    	NSMutableArray *events = [[NSMutableArray alloc] init];
    
    	for (NSDictionary *eventJSON in JSON) {
        	HUMEvent *event = [[HUMEvent alloc] initWithJSON:eventJSON];
        	[events addObject:event];
    	}
    
    	return [events copy];
	}

`JSONDictionary` is a method that returns a JSON formatted dictionary of all the properties on an event. This method will be used when we need JSON data to POST an event to the API. We haven't defined the `RFC3339DateFormatter` yet, but we will do so in the next section.

	// HUMEvent.m
	
	- (NSDictionary *)JSONDictionary
	{
    	NSMutableDictionary *JSONDictionary = [[NSMutableDictionary alloc] init];
    
    	[JSONDictionary setObject:self.address forKey:@"address"];
    	[JSONDictionary setObject:self.name forKey:@"name"];
    
    	[JSONDictionary setObject:@(self.coordinate.latitude) forKey:@"lat"];
    	[JSONDictionary setObject:@(self.coordinate.longitude) forKey:@"lon"];
    
    	NSString *start = [[NSDateFormatter RFC3339DateFormatter]
                       stringFromDate:self.startDate];
    	NSString *end = [[NSDateFormatter RFC3339DateFormatter]
                     stringFromDate:self.endDate];
    	[JSONDictionary setObject:start forKey:@"started_at"];
    	[JSONDictionary setObject:end forKey:@"ended_at"];
    
    	NSDictionary *user = @{@"device_token" : [HUMUserSession userID]};
    	[JSONDictionary setObject:user forKey:@"user"];
    
    	return [JSONDictionary copy];
	}

### Formatting the Event's Date

Since our rails app uses RFC 3339 formatting when sending and recieving dates in JSON, we have to use an NSDateFormatter that can translate these RFC 3339 date strings.

![Creating a Category](images/ios_making_an_event_1.png)
![Naming a Category](images/ios_making_an_event_2.png)

Create a new category on NSDateFormatter that will contain all of our default date formatters. Notice that the naming scheme for categories is `ClassYoureAddingCategoryTo+CategoryName`. 

For now, we will only need one date formatter. Place `+ (instancetype)RFC3339DateFormatter;` in your `NSDateFormatter+HUMDefaultDateFormatter.h`. Define the method as follows:

	// NSDateFormatter+HUMDefaultDateFormatter.m
	
	+ (instancetype)RFC3339DateFormatter
	{
    	static NSDateFormatter *dateFormatter = nil;
    
    	static dispatch_once_t onceToken;
    	dispatch_once(&onceToken, ^{
        	dateFormatter = [[NSDateFormatter alloc] init];
        	NSLocale *enUSPOSIXLocale = [[NSLocale alloc]
                                     initWithLocaleIdentifier:@"en_US_POSIX"];
        
        	[dateFormatter setLocale:enUSPOSIXLocale];
        	[dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    	});

    	return dateFormatter;
	}

We don't want to instantiate a new RFC 3339 date formatter every time we need to translate a date from the API, so we use a singleton.

First, we declare a static `dateFormatter` and instantiate it in a `dispatch_once` block. Once we set the locale, date format, and time zone to match what we're receiving from the API, we can use the date formatter to translate RFC 3339 date strings to NSDates and vice versa.
	
For an in-depth explanation of date formatters and using NSLocale, read into https://developer.apple.com/library/ios/qa/qa1480/_index.html

Be sure to add `#import NSDateFormatter+HUMDefaultDateFormatter.h` at the top of HUMEvent.m since we used the date formatter in that file, and need to know about this `RFC3339DateFormatter` method.
