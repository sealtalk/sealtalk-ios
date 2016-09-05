//
//  RCAppQueryHelper.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RCAppQueryHelper : NSObject
+ (void)queryParentAppConnectionStatus:(void (^)(BOOL isConnected))reply;
+ (void)queryParentAppUnreadMessageCount:(void (^)(int count))reply;
+ (void)queryParentAppName:(void (^)(NSString *appName))reply;
+ (void)queryParentAppGroups:(void (^)(NSString *appGroups))reply;
+ (void)queryParentAppConversationListByType:
            (NSArray *)types reply:(void (^)(NSArray *conversationList))reply;
+ (void)queryParentAppConversation:(NSString *)targetId
                              type:(int)type
                        olderMsgId:(long)olderMsgId
                             count:(int)count
                             reply:(void (^)(NSArray *messages))reply;
+ (void)queryParentAppContacts:(void (^)(NSArray *contacts))reply;
+ (void)queryParentAppGroupInfos:(void (^)(NSArray *groups))reply;
+ (void)queryParentAppFriends:(void (^)(NSArray *friends))reply;
+ (void)queryParentAppNewMsgSound:(void (^)(BOOL on))reply;
+ (void)setParentAppNewMsgSound:(BOOL)on;
+ (void)requestParentAppLogout;
+ (void)requestParentAppOpen;
+ (void)requestParentAppNotification:(BOOL)isNotify;
+ (void)requestParentAppSendTxtMsg:(NSString *)targetId
                              type:(int)type
                           content:(NSString *)txtContent
                             reply:(void (^)(BOOL sendToLib))reply;
+ (void)requestParentAppSendVoiceMsg:(NSString *)targetId
                                type:(int)type
                             content:(NSData *)voiceData
                            duration:(double)duration
                               reply:(void (^)(BOOL sendToLib))reply;
+ (void)requestParentAppClearUnreadStatus:(NSString *)targetId
                                     type:(int)type
                                    reply:(void (^)(BOOL success))reply;

+ (void)requestParentAppLoadImage:(int)conversationType
                         targetId:(NSString *)targetId
                         imageUrl:(NSString *)imageUrl
                            reply:(void (^)(UIImage *image))reply;
+ (void)requestParentAppCacheAllHeadIcon;

+ (void)requestParentAppCacheHeadIcon:(int)conversationType
                             targetId:(NSString *)targetId;
@end
