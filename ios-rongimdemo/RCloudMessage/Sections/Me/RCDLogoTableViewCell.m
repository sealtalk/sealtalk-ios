//
//  RCDLogoTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDLogoTableViewCell.h"

@implementation RCDLogoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)init {
    self = [super init];
    if (self) {
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_rong"]];
        logoImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:logoImageView];
        NSDictionary *views = NSDictionaryOfVariableBindings(logoImageView);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[logoImageView(86)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[logoImageView(86)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:logoImageView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0]];
    }
    return self;
}

@end
