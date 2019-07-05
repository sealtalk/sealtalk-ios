//
//  RCDUserListCollectionItem.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUserListCollectionItem.h"
#import "DefaultPortraitView.h"
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
        [_titleLabel setTextColor:[UIColor colorWithHexString:@"0x999999" alpha:1.0]];
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

- (void)setUserModel:(NSString *)userId{
    RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:userId];
    if (userInfo) {
        [self setUIInfo:userInfo];
    }else{
        [RCDUserInfoManager getUserInfoFromServer:userId complete:^(RCUserInfo *userInfo) {
            rcd_dispatch_main_async_safe(^{
                [self setUIInfo:userInfo];
            });
        }];
    }
}

- (void)setUIInfo:(RCUserInfo *)userInfo{
    if ([userInfo.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self.btnImg setHidden:YES];
    }
    RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userInfo.userId];
    self.ivAva.image = nil;
    self.userId = userInfo.userId;
    if (friend.displayName.length > 0) {
        self.titleLabel.text = friend.displayName;
    }else{
        self.titleLabel.text = userInfo.name;
    }
    if ([userInfo.portraitUri isEqualToString:@""]) {
        self.ivAva.image = [DefaultPortraitView portraitView:userInfo.userId name:userInfo.name];
    } else {
        [self.ivAva sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}
@end
