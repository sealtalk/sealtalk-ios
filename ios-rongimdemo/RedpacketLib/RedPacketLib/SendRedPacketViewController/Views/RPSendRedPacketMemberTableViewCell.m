//
//  RPSendRedPacketMemberTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketMemberTableViewCell.h"
#import "RPSendRedPacketItem.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"

@interface RPSendRedPacketMemberTableViewCell()
@property (nonatomic,strong)UILabel * nameLable;
@property (nonatomic,strong)UIImageView * subImageView;
@end
@implementation RPSendRedPacketMemberTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.describeLable.text = @"谁可以领";
        self.unitsLable.text = @"";
        self.nameLable = [UILabel new];
        [self.contentView addSubview:self.nameLable];
        self.nameLable.textColor = [RedpacketColorStore rp_textColorBlack];
        self.nameLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.nameLable.font = [UIFont systemFontOfSize:14];
        NSLayoutConstraint * countLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.nameLable
                                                                                     attribute:NSLayoutAttributeRight
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.unitsLable
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                    multiplier:1
                                                                                      constant:-16];
        NSLayoutConstraint * countLableCenterConstraint = [NSLayoutConstraint constraintWithItem:self.nameLable
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.describeLable
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                      multiplier:1
                                                                                        constant:0];
        [self.contentView addConstraints:@[countLableLeftConstraint,countLableCenterConstraint]];
        
        UIImage * iamge = rpRedpacketBundleImage(@"payView_arrow");
        self.subImageView = [[UIImageView alloc]initWithImage:iamge];
        self.subImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.subImageView];
        NSLayoutConstraint * imageViewRightConsTraint = [NSLayoutConstraint constraintWithItem:self.subImageView
                                                                                      attribute:NSLayoutAttributeRight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.contentView
                                                                                      attribute:NSLayoutAttributeRight
                                                                                     multiplier:1
                                                                                       constant:-15];
        NSLayoutConstraint * imageViewCenterConsTraint = [NSLayoutConstraint constraintWithItem:self.subImageView
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.describeLable
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                      multiplier:1
                                                                                        constant:0];
        [self.contentView addConstraints:@[imageViewRightConsTraint,imageViewCenterConsTraint]];
    }
    return self;
}
- (void)setCellItem:(RPBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    NSAssert([self.cellItem.rawItem isKindOfClass:[RPSendRedPacketItem class]], @"source type error");
    RPSendRedPacketItem * item = ((RPSendRedPacketItem*)self.cellItem.rawItem);
    self.nameLable.text = @"任何人";
    if (item.memberList.count) {
        NSMutableString * nameString = [NSMutableString string];
        [item.memberList enumerateObjectsUsingBlock:^(RedpacketUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [nameString appendFormat:@"%@,",obj.userNickname];
        }];
        self.nameLable.text = [nameString substringToIndex:nameString.length-1];
    }
}
- (CGFloat)spaceViewHeight{
    return 16;
}
@end
