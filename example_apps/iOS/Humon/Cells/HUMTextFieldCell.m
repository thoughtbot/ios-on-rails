//
//  HUMTextFieldCell.m
//  Humon
//
//  Created by Diana Zmuda on 4/24/14.
//  Copyright (c) 2014 thoughtbot. All rights reserved.
//

#import "HUMTextFieldCell.h"
#import "HUMAppearanceManager.h"
#import "NSDateFormatter+HUMDefaultDateFormatter.h"

@interface HUMTextFieldCell () <UITextFieldDelegate>


@end

@implementation HUMTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    [self setupTextField];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [HUMAppearanceManager humonWhite];

    return self;
}

- (void)setupTextField
{
    UITextField *textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;

    textField.placeholder = NSLocalizedString(@"...", nil);
    textField.delegate = self;

    [self.contentView addSubview:textField];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:textField
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:1.0
                                     constant:0.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:textField
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeWidth
                                     multiplier:1.0
                                     constant:-18.0]];

    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:textField
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeLeft
                                     multiplier:1.0
                                     constant:14.0]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:textField
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0
                                     constant:0.0]];

    _textField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
}

#pragma mark - Text field cell as a date picker methods

- (void)setDate:(NSDate *)date
{
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    [picker addTarget:self
               action:@selector(changeTextField:)
     forControlEvents:UIControlEventValueChanged];
    [picker setDate:date];

    self.textField.inputView = picker;
}

- (void)changeTextField:(UIDatePicker *)picker
{
    self.textField.text = [[NSDateFormatter hum_RFC3339DateFormatter]
                           stringFromDate:picker.date];
}

@end
