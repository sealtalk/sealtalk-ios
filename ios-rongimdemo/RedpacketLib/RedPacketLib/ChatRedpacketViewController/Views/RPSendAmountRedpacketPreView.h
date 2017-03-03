//
//  RPSendAmountRedpacketPreView.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/10/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketPreView.h"

@interface RPSendAmountRedpacketPreView : RPRedpacketPreView

@property (nonatomic, copy) void(^convertActionBlock)();
@property (nonatomic, copy)NSString * receivernickName;
@end
