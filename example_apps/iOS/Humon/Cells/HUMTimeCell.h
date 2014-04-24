//
//  HUMTimeCell.h
//  Humon
//
//  Created by Diana Zmuda on 12/16/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMTextFieldCell.h"

static NSString *kTimeCellID = @"kTimeCellID";

@interface HUMTimeCell : HUMTextFieldCell

@property (strong, nonatomic) NSDate *date;

@end
