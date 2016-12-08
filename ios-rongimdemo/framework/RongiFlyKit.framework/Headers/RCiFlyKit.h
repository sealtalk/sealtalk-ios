//
//  RCiFlyKit.h
//  RongiFlyKit
//
//  Created by Sin on 16/11/22.
//  Copyright © 2016年 Sin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 讯飞输入法核心类
 */
@interface RCiFlyKit : NSObject

/**
 如果不需要讯飞sdk的输入统计，那么可以直接使用iFlyKit中内置的讯飞appkey
 如果需要修改讯飞sdk的appkey，请在IMKit初始化之后调用这个方法，保证IMKit加载该模块的时候，使用正确的讯飞appkey
 注：因为讯飞的appkey和sdk是绑定的，所以如果你需要更换讯飞的appkey，就必须更换成对应的iflyMSC.framework
 @param key 新的讯飞sdk的appkey
 @discussion  [RCiFlyKit setiFlyAppKey:@"58243521"];
 */
+ (void)setiFlyAppkey:(NSString *)key;

@end
