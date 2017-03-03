//
//  RPMemberRedpacketPreView.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketPreView.h"

@interface RPMemberRedpacketPreView : RPRedpacketPreView

@property (nonatomic, strong) UIImageView       *senderHeadImageView;
@property (nonatomic, strong) UIImageView       *receiveHeadImageView;
@property (nonatomic, strong) UILabel           *senderNickNameLable;
@property (nonatomic, strong) UILabel           *describeLable;
@property (nonatomic, strong) UILabel           *greetingLable;
@property (nonatomic, strong) UILabel           *moneyLable;

@end
