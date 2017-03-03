//
//  RPDetailViewContrroller.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/7.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHBaseViewController.h"
@class RPAdvertisementDetailModel;

@interface RPAdvertisementDetailViewContrroller : YZHBaseViewController

@property (nonatomic, strong)RPAdvertisementDetailModel *adMessageModel;
@property (nonatomic, weak)RedpacketMessageModel *messageModel;
@property (nonatomic,copy)void(^advertisementDetailAction)(NSDictionary * args);

@end
