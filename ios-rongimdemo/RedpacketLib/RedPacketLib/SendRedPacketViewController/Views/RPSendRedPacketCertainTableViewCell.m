//
//  RPSendRedPacketCertainTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketCertainTableViewCell.h"
#import "RPSendRedPacketItem.h"
#import "RedpacketColorStore.h"

@interface RPSendRedPacketCertainTableViewCell()
@property (nonatomic,strong)UILabel * sumMoneyLable;
@property (nonatomic,strong)UIButton * makeSureButton;
@end
@implementation RPSendRedPacketCertainTableViewCell
@synthesize RPCellDelagete = _RPCellDelagete;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [RedpacketColorStore rp_backGroundGrayColor];
        self.sumMoneyLable = [UILabel new];
        self.sumMoneyLable.textAlignment = NSTextAlignmentCenter;
        self.sumMoneyLable.font = [UIFont systemFontOfSize:37];
        self.sumMoneyLable.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.sumMoneyLable];
        
        NSLayoutConstraint * sumMoneyLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.sumMoneyLable
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.contentView
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                       multiplier:1
                                                                                         constant:15];
        NSLayoutConstraint * sumMoneyLableRightConstraint = [NSLayoutConstraint constraintWithItem:self.sumMoneyLable
                                                                                         attribute:NSLayoutAttributeRight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.contentView
                                                                                         attribute:NSLayoutAttributeRight
                                                                                        multiplier:1
                                                                                          constant:-15];
        NSLayoutConstraint * sumMoneyLableTopConstraint = [NSLayoutConstraint constraintWithItem:self.sumMoneyLable
                                                                                       attribute:NSLayoutAttributeTop
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.contentView
                                                                                       attribute:NSLayoutAttributeTop
                                                                                      multiplier:1
                                                                                        constant:15];
        NSLayoutConstraint * sumMoneyLableBottomConstraint = [NSLayoutConstraint constraintWithItem:self.sumMoneyLable
                                                                                           attribute:NSLayoutAttributeHeight
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:nil
                                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                                          multiplier:1
                                                                                            constant:44];
        [self.contentView addConstraints:@[sumMoneyLableTopConstraint,sumMoneyLableLeftConstraint,sumMoneyLableBottomConstraint,sumMoneyLableRightConstraint]];
        
        
        self.makeSureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.makeSureButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.makeSureButton.layer.cornerRadius = 4;
        self.makeSureButton.layer.masksToBounds = YES;
        [self.makeSureButton setTitle:@"塞钱进红包" forState:UIControlStateNormal];
        [self.makeSureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.makeSureButton addTarget:self action:@selector(didTapSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.makeSureButton setBackgroundImage:[RedpacketColorStore rp_createImageWithColor:[RedpacketColorStore rp_redButtonNormalColor]] forState:UIControlStateNormal];
        [self.makeSureButton setBackgroundImage:[RedpacketColorStore rp_createImageWithColor:[RedpacketColorStore rp_redButtonHighColor]] forState:UIControlStateHighlighted];
        [self.makeSureButton setBackgroundImage:[RedpacketColorStore rp_createImageWithColor:[RedpacketColorStore rp_redButtonDisableColor]] forState:UIControlStateDisabled];
        [self.contentView addSubview:self.makeSureButton];
        NSLayoutConstraint * makeSureButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:self.makeSureButton
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.contentView
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                       multiplier:1
                                                                                         constant:15];
        NSLayoutConstraint * makeSureButtonRightConstraint = [NSLayoutConstraint constraintWithItem:self.makeSureButton
                                                                                         attribute:NSLayoutAttributeRight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.contentView
                                                                                         attribute:NSLayoutAttributeRight
                                                                                        multiplier:1
                                                                                          constant:-15];
        NSLayoutConstraint * makeSureButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.makeSureButton
                                                                                       attribute:NSLayoutAttributeTop
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.contentView
                                                                                       attribute:NSLayoutAttributeTop
                                                                                      multiplier:1
                                                                                        constant:70];
        NSLayoutConstraint * makeSureButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.makeSureButton
                                                                                           attribute:NSLayoutAttributeHeight
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:nil
                                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                                          multiplier:1
                                                                                            constant:44];
        [self.contentView addConstraints:@[makeSureButtonLeftConstraint,makeSureButtonRightConstraint,makeSureButtonTopConstraint,makeSureButtonHeightConstraint]];
        
    }
    return self;
}
- (void)setCellItem:(RPBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    NSAssert([self.cellItem.rawItem isKindOfClass:[RPSendRedPacketItem class]], @"source type error");
    self.sumMoneyLable.text = [NSString stringWithFormat:@"¥%.2f",(CGFloat)(((RPSendRedPacketItem*)self.cellItem.rawItem).totalMoney.floatValue/100.0f)];
    self.makeSureButton.enabled = ((RPSendRedPacketItem*)self.cellItem.rawItem).submitEnable;
}
- (void)didTapSubmitButton:(UIButton *)sender{
    if ([self.RPCellDelagete respondsToSelector:@selector(didSendRedPacket)]) {
        [self.RPCellDelagete didSendRedPacket];
    }
}

@end
