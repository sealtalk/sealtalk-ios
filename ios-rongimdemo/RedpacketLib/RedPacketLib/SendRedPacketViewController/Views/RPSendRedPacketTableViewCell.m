//
//  RPSendRedPacketTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketTableViewCell.h"
#import "RedpacketColorStore.h"

@implementation RPSendRedPacketTableViewCell
@synthesize RPCellDelagete = _RPCellDelagete;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView * spaceView = [UIView new];
        [self.contentView addSubview:spaceView];
        spaceView.translatesAutoresizingMaskIntoConstraints = NO;
        self.spaceView = spaceView;
        self.spaceView.backgroundColor = [RedpacketColorStore rp_backGroundGrayColor];

        
        UILabel * describeLable = [UILabel new];
        [self.contentView addSubview:describeLable];
        self.describeLable = describeLable;
        self.describeLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.describeLable.textColor = [RedpacketColorStore rp_textColorBlack];
        self.describeLable.font = [UIFont systemFontOfSize:15];
        NSLayoutConstraint * describeLableLeftConsTraint = [NSLayoutConstraint constraintWithItem:describeLable
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.contentView
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                       multiplier:1
                                                                                         constant:15];
        NSLayoutConstraint * describeLableCenterConsTraint = [NSLayoutConstraint constraintWithItem:describeLable
                                                                                          attribute:NSLayoutAttributeCenterY
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.contentView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1
                                                                                           constant:22];
        [self.contentView addConstraints:@[describeLableLeftConsTraint,describeLableCenterConsTraint]];
        
        
        UILabel * unitsLable = [UILabel new];
        [self.contentView addSubview:unitsLable];
        self.unitsLable = unitsLable;
        self.unitsLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.unitsLable.textColor = [RedpacketColorStore rp_textColorBlack];
        self.unitsLable.font = [UIFont systemFontOfSize:15];
        NSLayoutConstraint * unitsLableRightConsTraint = [NSLayoutConstraint constraintWithItem:unitsLable
                                                                                        attribute:NSLayoutAttributeRight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.contentView
                                                                                        attribute:NSLayoutAttributeRight
                                                                                       multiplier:1
                                                                                         constant:-15];
        NSLayoutConstraint * unitsLableCenterConsTraint = [NSLayoutConstraint constraintWithItem:unitsLable
                                                                                          attribute:NSLayoutAttributeCenterY
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.contentView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1
                                                                                           constant:22];
        [self.contentView addConstraints:@[unitsLableRightConsTraint,unitsLableCenterConsTraint]];

    }
    return self;
}
- (void)updateConstraints{
    [super updateConstraints];
    NSLayoutConstraint * spaceBottomConstraint = [NSLayoutConstraint constraintWithItem:self.spaceView
                                                                              attribute:NSLayoutAttributeBottom
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentView
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
    NSLayoutConstraint * spaceLeftConstraint = [NSLayoutConstraint constraintWithItem:self.spaceView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.contentView
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1
                                                                             constant:0];
    NSLayoutConstraint * spaceRightConstraint = [NSLayoutConstraint constraintWithItem:self.spaceView
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1
                                                                              constant:0];
    NSLayoutConstraint * spaceHeightConstraint = [NSLayoutConstraint constraintWithItem:self.spaceView
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                                             multiplier:1
                                                                               constant:self.spaceViewHeight];
    [self.contentView addConstraints:@[spaceBottomConstraint,spaceLeftConstraint,spaceRightConstraint,spaceHeightConstraint]];

}
- (CGFloat)spaceViewHeight{
    return 0.0f;
}
@end
