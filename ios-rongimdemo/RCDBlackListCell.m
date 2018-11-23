//
//  RCDBlackListCell.m
//  RCloudMessage
//
//  Created by 蔡建海 on 15/7/14.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDBlackListCell.h"
#import "RCDHttpTool.h"
#import "UIImageView+WebCache.h"

@interface RCDBlackListCell ()
@property(nonatomic, strong) UIImageView *iPhoto;
@property(nonatomic, strong) UILabel *labelName;
@end

@implementation RCDBlackListCell

//
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {

        [self updateUI];
    }

    return self;
}

#pragma mark - private
//
- (void)updateUI {
    UIImage *image = [UIImage imageNamed:@"contact"];
    self.iPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    self.iPhoto.image = image;
    self.iPhoto.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.iPhoto];

    self.labelName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.labelName.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.labelName];
}

//
- (void)rcCellDefault {
    self.labelName.text = nil;
    self.iPhoto.image = nil;
}

#pragma mark - custom
//
- (void)setUserInfo:(RCUserInfo *)info {
    [self rcCellDefault];

    //
    if (info.name == nil || info.portraitUri == nil) {

        [RCDHTTPTOOL getUserInfoByUserID:info.userId
                              completion:^(RCUserInfo *user) {

                                  info.name = user.name;
                                  info.portraitUri = user.portraitUri;

                                  dispatch_async(dispatch_get_main_queue(), ^{

                                      [self.iPhoto sd_setImageWithURL:[NSURL URLWithString:info.portraitUri]
                                                     placeholderImage:[UIImage imageNamed:@"contact"]];
                                      self.labelName.text = info.name;
                                  });
                              }];
    } else {
        [self.iPhoto sd_setImageWithURL:[NSURL URLWithString:info.portraitUri]
                       placeholderImage:[UIImage imageNamed:@"contact"]];
        self.labelName.text = info.name;
    }

    [self setNeedsLayout];
}

//
- (void)layoutSubviews {
    [super layoutSubviews];
    self.iPhoto.center = CGPointMake(15 + self.iPhoto.frame.size.width / 2, self.frame.size.height / 2);
    self.labelName.center = CGPointMake(self.iPhoto.frame.origin.x + self.iPhoto.frame.size.width + 10 +
                                            self.labelName.frame.size.width / 2,
                                        self.frame.size.height / 2);
}

@end
