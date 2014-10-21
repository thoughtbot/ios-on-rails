//
//  HUMTextFieldCell.h
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

static NSString *kTextFieldCellID = @"kTextFieldCellID";

@interface HUMTextFieldCell : UITableViewCell

@property (strong, nonatomic) UITextField *textField;

- (void)setDate:(NSDate *)date;

@end
