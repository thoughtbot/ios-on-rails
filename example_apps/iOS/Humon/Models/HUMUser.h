@import Foundation;

@interface HUMUser : NSObject

@property (copy, nonatomic) NSString *userID;

- (id)initWithJSON:(NSDictionary *)JSONDictionary;
- (BOOL)isCurrentUser;

@end
