//
//  RCDChatRoomManager.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatRoomManager.h"
#import "RCDChatRoomAPI.h"
@implementation RCDChatRoomManager
+ (void)getChatRoomList:(void (^)(NSArray<RCDChatRoom *> *rooms))complete {
    [RCDChatRoomAPI getChatRoomList:^(NSArray<RCDChatRoom *> *_Nonnull rooms) {
        if (complete) {
            complete(rooms);
        }
    }];
}
@end
