//
//  UIImage+HUMColorImage.m
//  Humon
//
//  Created by Diana Zmuda on 4/23/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "UIImage+HUMColorImage.h"

@implementation UIImage (HUMColorImage)

+ (UIImage *)hum_imageOfSize:(CGSize)size color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
