//
//  RPMyIncomeRedPacketCell.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/10/31.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RPMyIncomeRedPacketCell : UITableViewCell
@property (nonatomic, assign)BOOL isSend;
/*
 * 红包记录的，每条信息对应的字典
 */
@property (nonatomic) NSDictionary *incomeCellData;
@end
