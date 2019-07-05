//
//  RCDVersionCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDVersionCell.h"

@implementation RCDVersionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addNewImageView {
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
    newImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:newImageView];
    UILabel *leftLabel = self.leftLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(leftLabel, newImageView);
    [self.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftLabel]-10-[newImageView(50)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[newImageView(23)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:newImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}

@end
