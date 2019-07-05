//
//  RCDMeCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMeCell.h"

@implementation RCDMeCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setCellWithImageName:(NSString *)imageName labelName:(NSString *)labelName rightLabelName:(NSString *)rightLabelName {
    [self setImageView:self.leftImageView ImageStr:imageName imageSize:CGSizeMake(18, 18) LeftOrRight:0];
    self.leftLabel.text = labelName;
    if (rightLabelName) {
        [self addRightLabel];
        self.rightLabel.text = rightLabelName;
    }
}

- (id)initWithImageName:(NSString *)imageName labelName:(NSString *)labelName {
    if (self) {
        self = [super initWithLeftImageStr:imageName
                             leftImageSize:CGSizeMake(18, 18)
                              rightImaeStr:nil
                            rightImageSize:CGSizeZero];
        self.leftLabel.text = labelName;
        self.rightLabel.text = labelName;
        // [self setCellStyle:DefaultStyle];
    }
    return self;
}

- (void)addRightLabel {
    if (self.leftLabelConstraints != nil) {
        [self.contentView removeConstraints:self.leftLabelConstraints];
    }
    UILabel *leftLabel = self.leftLabel;
    UILabel *rightLabel = self.rightLabel;
    UIImageView *leftImageView = self.leftImageView;
    UIImageView *rightArrow = self.rightArrow;
    NSDictionary *views = NSDictionaryOfVariableBindings(leftLabel, leftImageView, rightLabel, rightArrow);
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-10-[leftImageView(width)]-8-[leftLabel]-(>=10)-[rightLabel]-13-[rightArrow(8)]-10-|" options:0 metrics:@{ @"width" : @(self.leftImageView.frame.size.width) } views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightLabel(21)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:rightLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}
    

- (void)addRedpointImageView {
    if (self.leftLabelConstraints != nil) {
        [self.contentView removeConstraints:self.leftLabelConstraints];
    }
    UIImageView *redpointImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redpoint"]];
    redpointImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:redpointImageView];
    UILabel *leftLabel = self.leftLabel;
    UIImageView *leftImageView = self.leftImageView;
    UIImageView *rightArrow = self.rightArrow;
    NSDictionary *views = NSDictionaryOfVariableBindings(leftLabel, redpointImageView, leftImageView, rightArrow);
    [self.contentView
        addConstraints:
            [NSLayoutConstraint
                constraintsWithVisualFormat:
                    @"H:|-10-[leftImageView(width)]-8-[leftLabel]-10-[redpointImageView(12)]-(>=0)-[rightArrow(8)]-10-|"
                                    options:0
                                    metrics:@{
                                        @"width" : @(self.leftImageView.frame.size.width)
                                    }
                                      views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[redpointImageView(12)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:redpointImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}

@end
