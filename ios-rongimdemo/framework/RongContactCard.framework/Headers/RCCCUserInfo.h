//
//  RCCCUserInfo.h
//  RongContactCard
//
//  Created by Jue on 2017/1/12.
//  Copyright © 2017年 ios-rongContactCard. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface RCCCUserInfo : RCUserInfo

//父类RCUserInfo中有三个属性，用户ID、用户昵称和用户头像地址

//用户备注名
@property(nonatomic, strong) NSString *displayName;

@end
