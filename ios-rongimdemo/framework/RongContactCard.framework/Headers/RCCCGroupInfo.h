//
//  RCCCGroupInfo.h
//  RongContactCard
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCGroup.h>

@interface RCCCGroupInfo : RCGroup <NSCoding>

//父类RCGroup中有三个属性，群组ID、群组名称和群组头像地址

/** 人数 */
@property(nonatomic, strong) NSString *number;

@end
