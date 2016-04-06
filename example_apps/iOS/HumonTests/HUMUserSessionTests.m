#import <XCTest/XCTest.h>
#import "HUMUserSession.h"

@interface HUMUserSessionTests : XCTestCase

@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *userToken;

@end

@implementation HUMUserSessionTests

- (void)setUp
{
    [super setUp];
    self.userID = @123;
    self.userToken = @"fakeUserToken";
}

- (void)testUserIDSetting
{
    [HUMUserSession setUserID:self.userID];
    NSString *currentUserID = [HUMUserSession userID];
    XCTAssertEqualObjects(currentUserID, @"123",
                          @"User ID should equal '123'");
}

- (void)testUserIDRemoval
{
    [HUMUserSession setUserID:nil];
    NSString *currentUserID = [HUMUserSession userID];
    XCTAssertNil(currentUserID, @"User ID should be nil");
}

- (void)testUserTokenSetting
{
    [HUMUserSession setUserToken:self.userToken];
    NSString *currentUserToken = [HUMUserSession userToken];
    XCTAssertEqualObjects(currentUserToken, self.userToken, @"User token should equal %@", self.userToken);
}

- (void)testUserTokenRemoval
{
    [HUMUserSession setUserToken:nil];
    NSString *currentUserToken = [HUMUserSession userToken];
    XCTAssertNil(currentUserToken, @"User token should be nil");
}

- (void)testUserIsLoggedIn
{
    [HUMUserSession setUserToken:self.userToken];
    [HUMUserSession setUserID:self.userID];
    BOOL userIsLoggedIn = [HUMUserSession userIsLoggedIn];
    XCTAssertTrue(userIsLoggedIn, @"User session should be logged in");
}

- (void)testUserIsLoggedOut
{
    [HUMUserSession setUserToken:nil];
    [HUMUserSession setUserID:nil];
    BOOL userIsLoggedIn = [HUMUserSession userIsLoggedIn];
    XCTAssertFalse(userIsLoggedIn, @"User session should be logged out");
}

@end
