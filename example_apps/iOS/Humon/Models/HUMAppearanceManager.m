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

+ (void)setupDefaultAppearances
{
    UIImage *whiteImage = [UIImage imageOfSize:CGSizeMake(1, 1)
                                         color:[UIColor whiteColor]];
    UIImage *greenImage = [UIImage imageOfSize:CGSizeMake(1, 1)
                                         color:[self humonGreen]];

    [[UINavigationBar appearance] setBarTintColor:[self humonGreen]];
    [[UINavigationBar appearance] setBackgroundImage:greenImage
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:whiteImage];

    NSDictionary *textAttributes =
        @{ NSForegroundColorAttributeName : [UIColor whiteColor] };

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil]
                           setTextColor:[UIColor whiteColor]];

    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
