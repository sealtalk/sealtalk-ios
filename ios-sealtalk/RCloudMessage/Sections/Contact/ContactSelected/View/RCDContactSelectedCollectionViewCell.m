//
//  RCDContactSelectedCollectionViewCell.m
//  RCloudMessage
//
//  Created by Jue on 2016/10/20.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactSelectedCollectionViewCell.h"
#import "DefaultPortraitView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@implementation RCDContactSelectedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.contentView addSubview:self.portraitImgView];
    [self.portraitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.contentView);
    }];
}

- (void)setUserModel:(RCDFriendInfo *)userModel {
    self.portraitImgView.image = nil;
    if ([userModel.portraitUri isEqualToString:@""]) {
        UIImage *portrait = [DefaultPortraitView portraitView:userModel.userId name:userModel.name];
        ;
        self.portraitImgView.image = portrait;
    } else {
        [self.portraitImgView sd_setImageWithURL:[NSURL URLWithString:userModel.portraitUri]
                                placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}

#pragma mark - Setter && Getter
- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
        _portraitImgView.clipsToBounds = YES;
        _portraitImgView.layer.cornerRadius = 5;
        _portraitImgView.backgroundColor = [UIColor clearColor];
        _portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImgView;
}

@end
