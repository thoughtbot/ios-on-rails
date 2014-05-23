//
//  HUMEventViewController.h
//  Humon
//
//  Created by Diana Zmuda on 5/7/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

@class HUMEvent;

typedef NS_ENUM(NSUInteger, HUMEventSection) {
    HUMEventSectionName,
    HUMEventSectionAddress,
    HUMEventSectionStart,
    HUMEventSectionEnd,
    HUMEventSectionCount
};

@interface HUMEventViewController : UITableViewController

- (instancetype)initWithEvent:(HUMEvent *)event;

@property (strong, nonatomic) HUMEvent *event;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *addressField;

@end
