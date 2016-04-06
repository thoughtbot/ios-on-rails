#import "HUMTimePickerCell.h"

@implementation HUMTimePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:self.frame];
        [self.contentView addSubview:_datePicker];
    }
    return self;
}

@end
