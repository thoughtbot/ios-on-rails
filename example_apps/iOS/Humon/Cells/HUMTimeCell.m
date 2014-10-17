//
//  HUMTimeCell.m
//  Humon
//
//  Created by Diana Zmuda on 12/16/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMTimeCell.h"

@implementation HUMTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    self.textField.placeholder = NSLocalizedString(@"Pick a date", nil);
    self.textField.userInteractionEnabled = NO;
    
    return self;
}

- (void)setDate:(NSDate *)date
{
    if (!date) {
        return;
    }

    _date = date;
    
    self.textField.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

@end
