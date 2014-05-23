//
//  HUMButton.m
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMButton.h"
#import "UIImage+HUMColorImage.h"
#import "HUMAppearanceManager.h"

@implementation HUMButton

- (id)initWithColor:(HUMButtonColor)color
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (color == HUMButtonColorWhite) {
        [self setupWhiteButton];
    } else if (color == HUMButtonColorGreen) {
        [self setupGreenButton];
    }

    return self;
}

- (void)setupWhiteButton
{
    self.layer.borderColor = [[HUMAppearanceManager humonWhite] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = HUMButtonHeight/2;
    self.layer.masksToBounds = YES;

    [self setTitleColor:[HUMAppearanceManager humonWhite] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage hum_imageOfSize:CGSizeMake(1, 1) color:[HUMAppearanceManager humonWhite]] forState:UIControlStateHighlighted];
}

- (void)setupGreenButton
{
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;

    [self setTitleColor:[HUMAppearanceManager humonWhite] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage hum_imageOfSize:CGSizeMake(1, 1) color:[HUMAppearanceManager humonGreen]] forState:UIControlStateNormal];
    
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage hum_imageOfSize:CGSizeMake(1, 1) color:[HUMAppearanceManager humonGreenDark]] forState:UIControlStateHighlighted];
}

@end
