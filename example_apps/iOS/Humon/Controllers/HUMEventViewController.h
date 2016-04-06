@class HUMEvent;
@import UIKit;

typedef NS_ENUM(NSUInteger, HUMEventSection) {
    HUMEventSectionName,
    HUMEventSectionAddress,
    HUMEventSectionStart,
    HUMEventSectionEnd,
    HUMEventSectionCount
};

@interface HUMEventViewController : UITableViewController

- (instancetype)initWithEvent:(HUMEvent *)event;

@property (strong, nonatomic) HUMEvent *event;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *addressField;

@end
