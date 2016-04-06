@import UIKit;

typedef NS_ENUM(NSUInteger, HUMButtonColor) {
    HUMButtonColorWhite,
    HUMButtonColorGreen
};

static NSInteger const HUMButtonHeight = 44.0;

@interface HUMButton : UIButton

- (id)initWithColor:(HUMButtonColor)color;

@end
