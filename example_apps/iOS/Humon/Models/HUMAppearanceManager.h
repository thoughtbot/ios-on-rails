//
//  HUMAppearanceManager.h
//  Humon
//
//  Created by Diana Zmuda on 4/23/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

@interface HUMAppearanceManager : NSObject

+ (UIColor *)humonGreen;
+ (UIColor *)humonGreenDark;
+ (UIColor *)humonGrey;
+ (UIColor *)humonGreyDark;
+ (UIColor *)humonBlack;
+ (UIColor *)humonWhite;

+ (void)setupDefaultAppearances;

@end
