@class HUMUser;
@import Foundation;

@interface HUMUserSession : NSObject

+ (NSString *)userID;
+ (NSString *)userToken;
+ (void)setUserID:(NSNumber *)userID;
+ (void)setUserToken:(NSString *)userToken;
+ (BOOL)userIsLoggedIn;

@end
