//
//  RCDAddressBookTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddressBookTableViewCell.h"
//#import <QuartzCore/QuartzCore.h>

@implementation RCDAddressBookTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  _acceptBtn = [[UIButton alloc] init];
  _acceptBtn.tag = self.tag;
  [_acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
  [_acceptBtn setTintColor:[UIColor whiteColor]];
  [_acceptBtn setBackgroundColor:[[UIColor alloc] initWithRed:23 / 255.f
                                                        green:136 / 255.f
                                                         blue:213 / 255.f
                                                        alpha:1]];
  _acceptBtn.translatesAutoresizingMaskIntoConstraints = NO;
  [_acceptBtn.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
  [self.contentView addSubview:_acceptBtn];
  NSDictionary *views = NSDictionaryOfVariableBindings(_acceptBtn);

  [self.contentView
      addConstraint:[NSLayoutConstraint
                        constraintWithItem:_acceptBtn
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0f
                                  constant:0]];

  [self.contentView
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"V:[_acceptBtn(20)]"
                                             options:kNilOptions
                                             metrics:nil
                                               views:views]];
  [self.contentView
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:[_acceptBtn(40)]-40-|"
                                             options:kNilOptions
                                             metrics:nil
                                               views:views]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
