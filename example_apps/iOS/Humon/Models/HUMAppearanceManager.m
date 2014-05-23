//
//  HUMAppearanceManager.m
//  Humon
//
//  Created by Diana Zmuda on 4/23/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMAppearanceManager.h"
#import "UIImage+HUMColorImage.h"

@implementation HUMAppearanceManager

+ (UIColor *)humonGreen
{
    return [UIColor colorWithRed:0.0 green:0.7 blue:0.6 alpha:1.0];
}

+ (UIColor *)humonGreenDark
{
    return [UIColor colorWithRed:0.0 green:0.4 blue:0.3 alpha:1.0];
}

+ (UIColor *)humonGrey
{
    return [UIColor colorWithRed:0.97 green:0.98 blue:0.97 alpha:1.0];
}

+ (UIColor *)humonGreyDark
{
    return [UIColor colorWithRed:0.32 green:0.33 blue:0.32 alpha:1.0];
}

+ (UIColor *)humonBlack
{
    return [UIColor colorWithRed:0.0 green:0.1 blue:0.05 alpha:1.0];
}

+ (UIColor *)humonWhite
{
    return [UIColor colorWithRed:0.98 green:1.0 blue:0.99 alpha:1.0];
}

+ (void)setupDefaultAppearances
{
    UIImage *whiteImage = [UIImage hum_imageOfSize:CGSizeMake(1, 1)
                                         color:[HUMAppearanceManager humonWhite]];
    UIImage *greenImage = [UIImage hum_imageOfSize:CGSizeMake(1, 1)
                                         color:[self humonGreen]];

    [[UINavigationBar appearance] setBarTintColor:[self humonGreen]];
    [[UINavigationBar appearance] setBackgroundImage:greenImage
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:whiteImage];

    NSDictionary *textAttributes =
        @{ NSForegroundColorAttributeName : [HUMAppearanceManager humonWhite] };

    [[UINavigationBar appearance] setTintColor:[HUMAppearanceManager humonWhite]];
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil]
                           setTextColor:[HUMAppearanceManager humonGreyDark]];

    [[UITextField appearance] setTextColor:[HUMAppearanceManager humonBlack]];

    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
