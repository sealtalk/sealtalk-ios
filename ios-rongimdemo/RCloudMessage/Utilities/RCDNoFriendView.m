//
//  RCDNoFriendView.m
//  RCloudMessage
//
//  Created by Jue on 2016/11/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDNoFriendView.h"
#import "UIColor+RCColor.h"

@implementation RCDNoFriendView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self layoutView];
    }
    return self;
}

- (void)layoutView {
    self.displayLabel = [UILabel new];
    self.displayLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
    self.displayLabel.font = [UIFont systemFontOfSize:14.f];
    self.displayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.displayLabel];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.displayLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.displayLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
}
@end
