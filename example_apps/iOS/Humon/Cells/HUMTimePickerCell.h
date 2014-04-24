//
//  HUMTimePickerCell.h
//  Humon
//
//  Created by Diana Zmuda on 12/17/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

static NSString *kTimePickerCellID = @"kTimePickerCellID";
static NSInteger kTimePickerCellHeight = 216;

@interface HUMTimePickerCell : UITableViewCell

@property (strong, nonatomic) UIDatePicker *datePicker;

@end
