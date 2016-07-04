//
//  RedpacketTakenOutgoingMessage.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-5-30.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketTakenMessage.h"

#define YZHRedpacketTakenOutgoingMessageTypeIdentifier @"YZH:RedPacketEmptyMsg"
// 按照 Android 的方法，定义 MessagePersistant 为 None，这样作为空消息不显示
@interface RedpacketTakenOutgoingMessage : RedpacketTakenMessage

@end
