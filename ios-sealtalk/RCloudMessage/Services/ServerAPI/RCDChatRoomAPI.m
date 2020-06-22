//
//  RCDChatRoomAPI.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/13.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatRoomAPI.h"
#import "RCDHTTPUtility.h"
@implementation RCDChatRoomAPI
+ (void)getChatRoomList:(void (^)(NSArray<RCDChatRoom *> *))complete {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"misc/demo_square"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSDictionary *list = result.content;
                                         NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                                         for (NSDictionary *dic in list) {
                                             if ([dic[@"type"] isEqualToString:@"chatroom"]) {
                                                 RCDChatRoom *chatRoom = [RCDChatRoom new];
                                                 chatRoom.targetId = dic[@"id"];
                                                 chatRoom.name = dic[@"name"];
                                                 [tempArray addObject:chatRoom];
                                             }
                                         }
                                         if (complete) {
                                             complete(tempArray);
                                         }
                                     } else {
                                         if (complete) {
                                             complete(nil);
                                         }
                                     }
                                 }];
}
@end
