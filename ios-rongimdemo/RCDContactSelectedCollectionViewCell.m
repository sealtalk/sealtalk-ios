//
//  RCDContactSelectedCollectionViewCell.m
//  RCloudMessage
//
//  Created by Jue on 2016/10/20.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedCollectionViewCell.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"

@implementation RCDContactSelectedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _ivAva = [[UIImageView alloc] initWithFrame:CGRectZero];
        _ivAva.clipsToBounds = YES;
        _ivAva.layer.cornerRadius = 5.f;
        _ivAva.translatesAutoresizingMaskIntoConstraints = NO;
        [_ivAva setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_ivAva];

        [self.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_ivAva]|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_ivAva)]];

        [self.contentView
            addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_ivAva]|"
                                                                   options:kNilOptions
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_ivAva)]];
    }
    return self;
}

- (void)setUserModel:(RCUserInfo *)userModel {
    self.ivAva.image = nil;
    if ([userModel.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:userModel.userId Nickname:userModel.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.ivAva.image = portrait;
    } else {
        [self.ivAva sd_setImageWithURL:[NSURL URLWithString:userModel.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}

@end
