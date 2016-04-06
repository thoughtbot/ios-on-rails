@class HUMEvent;
@import UIKit;

typedef NS_ENUM(NSUInteger, HUMEventCell) {
    HUMEventCellName,
    HUMEventCellAddress,
    HUMEventCellStart,
    HUMEventCellEnd,
    HUMEventCellSubmit,
    HUMEventCellCount
};

@interface HUMEventViewControllerFromBook : UITableViewController

- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;

@end
