//
//  RCConversationSettingTableViewCell.m
//  RongIMToolkit
//
//  Created by Liv on 15/3/25.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDDiscussSettingSwitchCell.h"

@implementation RCDDiscussSettingSwitchCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        [_label setText:@"test"];
        [_label setTextAlignment:NSTextAlignmentLeft];
        _swich = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self addSubview:_label];
        [self addSubview:_swich];

        [_swich setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_label setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_swich(33)]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_swich)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_swich
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:-20]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_swich
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_label(30)]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_label)]];
        [self addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-16-[_label][_swich]"
                                                     options:kNilOptions
                                                     metrics:nil
                                                       views:NSDictionaryOfVariableBindings(_label, _swich)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_label
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0]];
    }
    return self;
}

@end
