//
//  RedPacketInfoModel.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/15.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedPacketInfoModel : NSObject
/** 已领取 */
@property (nonatomic, copy) NSString *taken;
/** 总共个数 */
@property (nonatomic, copy) NSString *total;
/** 是否领取完 */
@property (nonatomic ,assign) BOOL isGetFinish;
@property (nonatomic ,assign) BOOL isInfoDict;
/** 领取时长 */
@property (nonatomic, copy) NSString *timeLength;
/** 被领取金额 */
@property (nonatomic, copy) NSString *takenAmmount;
/** 领取人列表 */
@property (nonatomic) NSMutableArray *recipientsGroup;
/** 传入生成model所需要的字典 */
+(instancetype)initWithDict:(NSDictionary *)dict;
- (void)refreshWithDict:(NSDictionary *)dict;
@end
