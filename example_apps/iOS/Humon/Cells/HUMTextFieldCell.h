@import UIKit;

static NSString *kTextFieldCellID = @"kTextFieldCellID";

@interface HUMTextFieldCell : UITableViewCell

@property (strong, nonatomic) UITextField *textField;

- (void)setDate:(NSDate *)date;

@end
