//
//  HUMTimePickerCell.m
//  Humon
//
//  Created by Diana Zmuda on 12/17/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMTimePickerCell.h"

@implementation HUMTimePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:self.frame];
        [self.contentView addSubview:_datePicker];
    }
    return self;
}

@end
