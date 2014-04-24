//
//  HUMButton.m
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMButton.h"

@implementation HUMButton

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.tintColor = [UIColor whiteColor];
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = HUMButtonHeight/2;

    return self;
}

@end
