//
//  RCDConversationSettingClearMessageCellTableViewCell.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDConversationSettingClearMessageCell.h"

@implementation RCDConversationSettingClearMessageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];

        _touchBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_nameLabel];
        [self addSubview:_touchBtn];

        [_nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_touchBtn setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_touchBtn(44)]|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_touchBtn)]];
        [self
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_touchBtn]|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_touchBtn)]];

        [self
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel(30)]"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_nameLabel)]];
        [self
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_nameLabel]-20-|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_nameLabel)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_nameLabel
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
