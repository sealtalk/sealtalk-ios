//
//  RCDLanguageSettingTableViewCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/2/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLanguageSettingTableViewCell.h"
#import "UIColor+RCColor.h"

@interface RCDLanguageSettingTableViewCell ()

@property(nonatomic, strong) NSDictionary *cellSubViews;

@end

@implementation RCDLanguageSettingTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.font = [UIFont systemFontOfSize:17.f];
    self.leftLabel.textColor = [UIColor colorWithHexString:@"0x262626" alpha:1.0f];
    self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.rightImageView = [[UIImageView alloc] init];
    self.rightImageView.layer.cornerRadius = 5.0f;
    self.rightImageView.layer.masksToBounds = YES;
    self.rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.rightImageView];
    
    self.cellSubViews = NSDictionaryOfVariableBindings(_leftLabel, _rightImageView);
    [self setLayout];
}

- (void)setLayout {
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftLabel(21)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_leftLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightImageView(20)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rightImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    [self.contentView
     addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-10-[_leftLabel]-(>=10)-[_rightImageView(20)]-20-|"
      options:0
      metrics:nil
      views:self.cellSubViews]];
}@end
