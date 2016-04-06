#import <XCTest/XCTest.h>
#import "HUMJSONFileManager.h"

@interface HUMJSONFileManagerTests : XCTestCase

@end

@implementation HUMJSONFileManagerTests

- (void)testSingleEventDictionary
{
    NSDictionary *event = [HUMJSONFileManager singleEventJSON];
    XCTAssertEqual(event.count, 8,
                   @"Should initialize single event JSON from file");
}

- (void)testMultipleEventArray
{
    NSArray *events = [HUMJSONFileManager multipleEventsJSON];
    XCTAssertEqual(events.count, 2,
                   @"Should initialize multiple events JSON from file");
}

@end
