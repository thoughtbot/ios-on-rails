//
//  HUMUITests.m
//  Humon
//
//  Created by Diana Zmuda on 11/12/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "HUMUITests.h"

@implementation HUMUITests

- (void)testValidButton
{
    [tester tapViewWithAccessibilityLabel:@"Add Event"];
}

- (void)testInvalidButton
{
    [tester tapViewWithAccessibilityLabel:@"InvalidButtonName"];
}

@end
