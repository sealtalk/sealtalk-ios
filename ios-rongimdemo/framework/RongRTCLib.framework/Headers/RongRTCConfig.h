//
//  RongRTCConfig.h
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/5/21.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCConfig : NSObject

/**
  设置媒体服务服务地址（私有部署用户使用），公有云请不要设置
 */
@property (nonatomic,copy)NSString *mediaServerUrl;

/**
 加入房间场景
 */
@property (nonatomic)RongRTCJoinRoomMode mode;

@end

NS_ASSUME_NONNULL_END
