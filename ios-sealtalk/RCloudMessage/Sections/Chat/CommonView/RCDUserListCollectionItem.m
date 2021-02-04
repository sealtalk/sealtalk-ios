//
//  RCDUserListCollectionItem.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUserListCollectionItem.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUserInfoManager.h"
@implementation RCDUserListCollectionItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _ivAva = [[UIImageView alloc] initWithFrame:CGRectZero];
        _ivAva.clipsToBounds = YES;
        _ivAva.layer.cornerRadius = 5.f;
        [_ivAva setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_ivAva];

        _titleLabel = [UILabel new];
        [_titleLabel setTextColor:RCDDYCOLOR(0x999999, 0x9f9f9f)];
        [_titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_titleLabel];

        _btnImg = [[UIButton alloc] initWithFrame:CGRectZero];
        [_btnImg setHidden:YES];
        [_btnImg setImage:[RCDUtilities imageNamed:@"delete_member_tip" ofBundle:@"RongCloud.bundle"]
                 forState:UIControlStateNormal];
        [_btnImg addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnImg];

        [_ivAva setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_btnImg setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_ivAva]|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_ivAva)]];

        [self.contentView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"H:|[_titleLabel]|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_titleLabel)]];
        [self.contentView
            addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[_ivAva(55)]-9-[_titleLabel(==15)]"
                                                   options:kNilOptions
                                                   metrics:nil
                                                     views:NSDictionaryOfVariableBindings(_titleLabel, _ivAva)]];

        [self.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_btnImg(25)]"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_btnImg)]];
        [self.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_btnImg(25)]"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_btnImg)]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_ivAva
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0f
                                                                      constant:0]];
    }
    return self;
}

- (void)deleteItem:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteTipButtonClicked:)]) {
        [self.delegate deleteTipButtonClicked:self];
    }
}

- (void)setUserModel:(NSString *)userId {
    if (self.groupId.length > 0) {
        [RCDUtilities getGroupUserDisplayInfo:userId
                                      groupId:self.groupId
                                       result:^(RCUserInfo *user) {
                                           [self setUIInfo:user];
                                       }];
    } else {
        [RCDUtilities getUserDisplayInfo:userId
                                complete:^(RCUserInfo *user) {
                                    [self setUIInfo:user];
                                }];
    }
}

- (void)setUIInfo:(RCUserInfo *)user {
    if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.btnImg setHidden:YES];
    }
    self.ivAva.image = nil;
    self.userId = user.userId;
    self.titleLabel.text = user.name;
    [self.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                  placeholderImage:[UIImage imageNamed:@"icon_person"]];
}

@end
