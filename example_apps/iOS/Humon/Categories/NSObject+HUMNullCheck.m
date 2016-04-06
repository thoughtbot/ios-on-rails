#import "NSObject+HUMNullCheck.h"

@implementation NSObject (HUMNullCheck)

- (BOOL)hum_isNotNull
{
    if ([self isKindOfClass:[NSNull class]]) {
        return NO;
    } else {
        return YES;
    }
}

@end
