//
//  RedpacketMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketMessageModel.h"
#import "NSDictionary+YZHExtern.h"
#import "YZHRedpacketGlobal.h"

@implementation RedpacketUserInfo



@end

@implementation RedpacketViewModel

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _redpacketIcon = @"";
        _redpacketOrgIcon = @"";
        _redpacketOrgName = @"云红包";
    }
    
    return self;
}

@end


@interface RedpacketMessageModel ()
{

}

@end

@implementation RedpacketMessageModel

+ (BOOL)isMessageRelatedRedpacket:(NSDictionary *)redpacketDic
{
    return [self isRedpacketMessage:redpacketDic] || [self isRedpacket:redpacketDic];
}

+ (BOOL)isRelatedCurrentUser:(NSDictionary *)redpacketDic
{
    NSString *currentId = [[self class] currentUserByClassMethod].userId;
    NSString *sendId = [redpacketDic valueForKey:RedpacketKeyRedpacketSenderId];
    NSString *receiverId = [redpacketDic valueForKey:RedpacketKeyRedpacketReceiverId];
    
    return [currentId isEqualToString:sendId] || [currentId isEqualToString:receiverId];
}

+ (BOOL)isRedpacket:(NSDictionary *)redpacketDic
{
    BOOL isRedpacket = [[redpacketDic stringForKey:RedpacketKeyRedpacketSign] boolValue];
    return isRedpacket;
}

+ (BOOL)isRedpacketMessage:(NSDictionary *)redpacketDic
{
    BOOL isRedpacketTakenMessage = [[redpacketDic stringForKey:RedpacketKeyRedpacketTakenMessageSign] boolValue];
    return isRedpacketTakenMessage;
}

+ (RedpacketMessageModel *)redpacketMessageModelWithDic:(NSDictionary *)redpacketDic;
{
    RedpacketMessageModel *model = [RedpacketMessageModel new];
    [model configWithRedpacketDic:redpacketDic];
    
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _redpacketType = RedpacketTypeSingle;
        _messageType = RedpacketMessageTypeRedpacket;
        
        _redpacketViewInfo = [RedpacketViewModel new];
        _redpacketSender = [RedpacketUserInfo new];
        _redpacketReceiver = [RedpacketUserInfo new];
    }
    
    return self;
}

- (RedpacketUserInfo *)currentUser
{
    return [[self class] currentUserByClassMethod];
}

+ (RedpacketUserInfo *)currentUserByClassMethod
{
    return [YZHRedpacketGlobal shareInstance].currentUserInfo;
}


- (BOOL)isRedacketSender
{
    return [self.currentUser.userId isEqualToString:_redpacketSender.userId];
}

- (BOOL)isRedpacketMessage
{
    return self.messageType == RedpacketMessageTypeRedpacket;
}

- (BOOL)isRedapcketTakenMessage
{
    return self.messageType == RedpacketMessageTypeTedpacketTakenMessage;
}

- (BOOL)isRelatedCurrentUser
{
    return [self.currentUser.userId isEqualToString:self.redpacketSender.userId] ||
    [self.currentUser.userId isEqualToString:self.redpacketReceiver.userId];
}

- (void)configWithRedpacketDic:(NSDictionary *)redpacketDic
{
    _redpacketId = [redpacketDic stringForKey:RedpacketKeyRedpacketID];
    if ([[self class] isMessageRelatedRedpacket:redpacketDic]) {
        //  IM红包消息里边带着的参数
        self.redpacketSender.userId = [redpacketDic stringForKey:RedpacketKeyRedpacketSenderId];
        self.redpacketSender.userNickname = [redpacketDic stringForKey:RedpacketKeyRedpacketSenderNickname];
        self.redpacketReceiver.userId = [redpacketDic stringForKey:RedpacketKeyRedpacketReceiverId];
        self.redpacketReceiver.userNickname = [redpacketDic stringForKey:RedpacketKeyRedpacketReceiverNickname];

        self.redpacketViewInfo.redpacketGreeting = [redpacketDic stringForKey:RedpacketKeyRedpacketGreeting];
        self.redpacketViewInfo.redpacketOrgName = [redpacketDic stringForKey:RedpacketKeyRedpacketOrgName];
        
        if ([RedpacketMessageModel isRedpacket:redpacketDic]) {
            self.messageType = RedpacketMessageTypeRedpacket;
        }else {
            self.messageType = RedpacketMessageTypeTedpacketTakenMessage;
        }
        
    }else {
        //  Server后端发送红包成功之后的回调
        self.redpacketSender = self.currentUser;
        
        
        /*
         if ([redpacketDic stringForKey:@"GroupId"].length > 0) {
         self.redpacketReceiver.userId = [redpacketDic stringForKey:@"GroupId"];
         self.redpacketReceiver.userNickname = [redpacketDic stringForKey:@"GroupId"];
         self.redpacketReceiver.isGroup = YES;
         
         }else {
         self.redpacketReceiver.userId = [redpacketDic stringForKey:@"Recipient"];
         self.redpacketReceiver.userNickname = [redpacketDic stringForKey:@"Recipient"];
         self.redpacketReceiver.isGroup = NO;
         }
         */
        
        /*  server端修改后不再提供,不要从这边读取
        self.redpacketViewInfo.redpacketGreeting = [redpacketDic stringForKey:@"Message"];
         */
    }
}

- (NSDictionary *)redpacketMessageModelToDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.redpacketId forKey:RedpacketKeyRedpacketID];
    
    [dic setValue:self.redpacketSender.userId forKey:RedpacketKeyRedpacketSenderId];
    [dic setValue:self.redpacketSender.userNickname forKey:RedpacketKeyRedpacketSenderNickname];
    [dic setValue:self.redpacketReceiver.userNickname forKey:RedpacketKeyRedpacketReceiverNickname];
    [dic setValue:self.redpacketReceiver.userId forKey:RedpacketKeyRedpacketReceiverId];
    
    if (_messageType == RedpacketMessageTypeRedpacket) {
        //  红包消息
        [dic setValue:@(YES) forKey:RedpacketKeyRedpacketSign];
    }else {
        //  红包被抢消息
        [dic setValue:@(YES) forKey:RedpacketKeyRedpacketTakenMessageSign];
    }
    
    [dic setValue:self.redpacketViewInfo.redpacketOrgName forKey:RedpacketKeyRedpacketOrgName];
    [dic setValue:self.redpacketViewInfo.redpacketGreeting forKey:RedpacketKeyRedpacketGreeting];
    
    return dic;
}

- (NSData *)toJsonData
{
    NSDictionary *param = [self redpacketMessageModelToDic];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:&parseError];
    /*
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    */
    
    return jsonData;
}


@end
