//
//  RCDPrivateSettingsUserInfoCell.m
//  RCloudMessage
//
//  Created by Jue on 16/5/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPrivateSettingsUserInfoCell.h"
#import "UIColor+RCColor.h"

@implementation RCDPrivateSettingsUserInfoCell

- (id)initWithIsHaveDisplayName:(BOOL)isHaveDisplayName{
  self = [super init];
  if (self) {
    self.PortraitImageView = [[UIImageView alloc] init];
    self.PortraitImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.PortraitImageView];
    
    self.NickNameLabel = [[UILabel alloc] init];
    self.NickNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.NickNameLabel.font = [UIFont systemFontOfSize:16.f];
    self.NickNameLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
    [self addSubview:self.NickNameLabel];
    
    NSDictionary *subViews = NSDictionaryOfVariableBindings(_PortraitImageView,_NickNameLabel);
    
    [self
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.PortraitImageView
                    attribute:NSLayoutAttributeCenterY
                    relatedBy:NSLayoutRelationEqual
                    toItem:self
                    attribute:NSLayoutAttributeCenterY
                    multiplier:1
                    constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_PortraitImageView(65)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_PortraitImageView(65)]-10-[_NickNameLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subViews]];
    if (isHaveDisplayName == YES) {
      self.displayNameLabel = [[UILabel alloc] init];
      self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
      self.displayNameLabel.font = [UIFont systemFontOfSize:12.f];
      self.displayNameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
      [self addSubview:self.displayNameLabel];
      [self
       addConstraint:[NSLayoutConstraint
                      constraintWithItem:self.NickNameLabel
                      attribute:NSLayoutAttributeTop
                      relatedBy:NSLayoutRelationEqual
                      toItem:self.PortraitImageView
                      attribute:NSLayoutAttributeTop
                      multiplier:1
                      constant:13.5]];
      
      [self
       addConstraint:[NSLayoutConstraint
                      constraintWithItem:self.displayNameLabel
                      attribute:NSLayoutAttributeBottom
                      relatedBy:NSLayoutRelationEqual
                      toItem:self.PortraitImageView
                      attribute:NSLayoutAttributeBottom
                      multiplier:1
                      constant:-13.5]];
      
      [self
       addConstraint:[NSLayoutConstraint
                      constraintWithItem:self.displayNameLabel
                      attribute:NSLayoutAttributeLeft
                      relatedBy:NSLayoutRelationEqual
                      toItem:self.NickNameLabel
                      attribute:NSLayoutAttributeLeft
                      multiplier:1
                      constant:0]];
    } else {
      [self
       addConstraint:[NSLayoutConstraint
                      constraintWithItem:self.NickNameLabel
                      attribute:NSLayoutAttributeCenterY
                      relatedBy:NSLayoutRelationEqual
                      toItem:self
                      attribute:NSLayoutAttributeCenterY
                      multiplier:1
                      constant:0]];
    }
  }
  return self;

}

@end
