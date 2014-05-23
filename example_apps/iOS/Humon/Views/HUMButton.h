//
//  HUMButton.h
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HUMButtonColor) {
    HUMButtonColorWhite,
    HUMButtonColorGreen
};

static NSInteger const HUMButtonHeight = 44.0;

@interface HUMButton : UIButton

- (id)initWithColor:(HUMButtonColor)color;

@end
