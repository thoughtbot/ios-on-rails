//
//  HUMFooterView.m
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMFooterView.h"
#import "HUMButton.h"

@implementation HUMFooterView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    HUMButton *button = [[HUMButton alloc] initWithColor:HUMButtonColorGreen];
    [self addSubview:button];

    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:button
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:nil
                         attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0
                         constant:HUMButtonHeight]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:button
                         attribute:NSLayoutAttributeWidth
                         relatedBy:NSLayoutRelationEqual
                         toItem:nil
                         attribute:NSLayoutAttributeNotAnAttribute
                         multiplier:1.0
                         constant:200.0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:button
                         attribute:NSLayoutAttributeCenterX
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterX
                         multiplier:1.0
                         constant:0.0]];
    [self addConstraint:[NSLayoutConstraint
                         constraintWithItem:button
                         attribute:NSLayoutAttributeCenterY
                         relatedBy:NSLayoutRelationEqual
                         toItem:self
                         attribute:NSLayoutAttributeCenterY
                         multiplier:1.0
                         constant:0.0]];

    self.button = button;

    return self;
}

@end
