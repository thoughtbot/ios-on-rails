//
//  HUMOldEventViewController.h
//  Humon
//
//  Created by Diana Zmuda on 10/21/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

@class HUMEvent;

typedef NS_ENUM(NSUInteger, HUMEventCell) {
    HUMEventCellName,
    HUMEventCellAddress,
    HUMEventCellStart,
    HUMEventCellEnd,
    HUMEventCellSubmit,
    HUMEventCellCount
};

@interface HUMOldEventViewController : UITableViewController

- (instancetype)initWithEvent:(HUMEvent *)event editable:(BOOL)editable;

@end
