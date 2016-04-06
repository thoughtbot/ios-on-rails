@import UIKit;

static NSString *kTimePickerCellID = @"kTimePickerCellID";
static NSInteger kTimePickerCellHeight = 216;

@interface HUMTimePickerCell : UITableViewCell

@property (strong, nonatomic) UIDatePicker *datePicker;

@end
