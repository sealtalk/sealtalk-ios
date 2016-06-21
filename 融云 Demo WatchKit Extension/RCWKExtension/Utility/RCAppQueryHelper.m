//
//  RCAppQueryHelper.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCAppQueryHelper.h"
#import <WatchKit/WatchKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCWKAPPCommonDefine.h"
#import "RCAppInfoModel.h"

@interface RCAppQueryHelper ()
//@property(nonatomic, strong) NSDictionary *userInfo;
//@property(nonatomic, strong) void (^reply)(NSDictionary *);
@end

static int rcWKNotificationCount = 0;
@implementation RCAppQueryHelper
+ (void)queryParentAppConnectionStatus:(void (^)(BOOL isConnected))reply {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_CONNECTION_STATUS
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *number = (NSNumber *)replyObject;
                                 reply([number boolValue]);
                               } else {
                                 reply(NO);
                               }
                             }];
}

+ (void)queryParentAppUnreadMessageCount:(void (^)(int count))reply {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_UNREAD_COUNT
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *number = (NSNumber *)replyObject;
                                 reply([number intValue]);
                               } else {
                                 reply(0);
                               }
                             }];
}
+ (void)queryParentAppName:(void (^)(NSString *appName))reply {
    NSString *appName = [[NSUserDefaults standardUserDefaults] objectForKey:@"appName"];
    if (appName.length) {
        reply(appName);
        return;
    }
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_APP_NAME
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 reply(replyObject);
                                   [[NSUserDefaults standardUserDefaults] setObject:replyObject forKey:@"appName"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                               } else {
                                 reply(nil);
                               }
                             }];
}
+ (void)queryParentAppGroups:(void (^)(NSString *appGroups))reply {
   NSString *appGroups = [[NSUserDefaults standardUserDefaults] objectForKey:@"appGroups"];
    if (appGroups.length) {
        reply(appGroups);
        return;
    }
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_APP_GROUPS
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 reply(replyObject);
                                   [[NSUserDefaults standardUserDefaults] setObject:replyObject forKey:@"appGroups"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                               } else {
                                 reply(nil);
                               }
                             }];
}
+ (void)queryParentAppConversationListByType:
            (NSArray *)types reply:(void (^)(NSArray *conversationList))reply {
  [RCAppQueryHelper
      queryParentApp:WK_APP_COMMUNICATE_QUERY_CONVERSATION_LIST
           parameter:@{
             WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : types
           } reply:^(id replyObject) {
             if (replyObject) {
               NSData *data = replyObject;
               reply([NSKeyedUnarchiver unarchiveObjectWithData:data]);
             } else {
               reply(nil);
             }
           }];
}

+ (void)queryParentAppConversation:(NSString *)targetId
                              type:(int)type
                        olderMsgId:(long)olderMsgId
                             count:(int)count
                             reply:(void (^)(NSArray *messages))reply {
  [RCAppQueryHelper
      queryParentApp:WK_APP_COMMUNICATE_QUERY_CONVERSATION
           parameter:@{
             WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE :
                 [NSNumber numberWithInt:type],
             WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId,
             WK_APP_COMMUNICATE_PARAMETER_OLDER_MESSAG_ID :
                 [NSNumber numberWithLong:olderMsgId],
             WK_APP_COMMUNICATE_PARAMETER_COUNT : [NSNumber numberWithInt:count]
           } reply:^(id replyObject) {
             if (replyObject) {
               NSData *data = replyObject;
               NSArray *loadedContents =
                   [NSKeyedUnarchiver unarchiveObjectWithData:data];
               reply(loadedContents);
             } else {
               reply(nil);
             }
           }];
}

+ (void)queryParentAppContacts:(void (^)(NSArray *contacts))reply {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_CONTACT_LIST
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSData *data = replyObject;
                                 NSArray *loadedContents = [NSKeyedUnarchiver
                                     unarchiveObjectWithData:data];
                                 reply(loadedContents);
                               } else {
                                 reply(nil);
                               }
                             }];
}

+ (void)queryParentAppGroupInfos:(void (^)(NSArray *groups))reply {
    [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_GROUP_LIST
                           parameter:nil
                               reply:^(id replyObject) {
                                   if (replyObject) {
                                       NSData *data = replyObject;
                                       NSArray *loadedContents = [NSKeyedUnarchiver
                                                                  unarchiveObjectWithData:data];
                                       reply(loadedContents);
                                   } else {
                                       reply(nil);
                                   }
                               }];
}

+ (void)queryParentAppFriends:(void (^)(NSArray *friends))reply {
    [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_FRIEND_LIST
                           parameter:nil
                               reply:^(id replyObject) {
                                   if (replyObject) {
                                       NSData *data = replyObject;
                                       NSArray *loadedContents = [NSKeyedUnarchiver
                                                                  unarchiveObjectWithData:data];
                                       reply(loadedContents);
                                   } else {
                                       reply(nil);
                                   }
                               }];
}

+ (void)queryParentAppNewMsgSound:(void (^)(BOOL on))reply {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_QUERY_NOTIFY_SOUND
                         parameter:nil
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *on = replyObject;
                                 reply([on boolValue]);
                               } else {
                                 reply(NO);
                               }
                             }];
}

+ (void)setParentAppNewMsgSound:(BOOL)on {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_SET_NOTIFY_SOUND
                         parameter:@{
                           WK_APP_COMMUNICATE_PARAMETER_NEW_MESSAGE_SOUND :
                               [NSNumber numberWithBool:on]
                         } reply:^(id replyObject){
                         }];
}

+ (void)requestParentAppLogout {
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_LOGOUT
                         parameter:nil
                             reply:^(id replyObject){
                             }];
}

+ (void)requestParentAppOpen {
    return;
    [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_OPEN_APP
                           parameter:nil
                               reply:^(id replyObject){
                               }];
}
+ (void)requestParentAppNotification:(BOOL)isNotify {
    if (isNotify) {
        rcWKNotificationCount++;
    } else {
        rcWKNotificationCount--;
    }
    [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_NOTIFICATION
                           parameter:@{
                                       WK_APP_COMMUNICATE_PARAMETER_NOTIFY_OR_NOT :
                                           [NSNumber numberWithBool:(rcWKNotificationCount > 0)]
                                       }
                               reply:^(id replyObject){
                               }];
}

+ (void)requestParentAppSendTxtMsg:(NSString *)targetId
                              type:(int)type
                           content:(NSString *)txtContent
                             reply:(void (^)(BOOL sendToLib))reply {
  NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
  NSNumber *conversationType = [[NSNumber alloc] initWithInteger:type];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : conversationType
  }];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId
  }];

  RCTextMessage *txtMsg = [RCTextMessage messageWithContent:txtContent];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:txtMsg];
  [para
      addEntriesFromDictionary:@{WK_APP_COMMUNICATE_PARAMETER_CONTENT : data}];

  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_SEND_MSG
                         parameter:para
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *result = (NSNumber *)replyObject;
                                 reply([result boolValue]);
                               } else {
                                 reply(NO);
                               }
                             }];
}
+ (void)requestParentAppSendVoiceMsg:(NSString *)targetId
                                type:(int)type
                             content:(NSData *)voiceData
                            duration:(double)duration
                               reply:(void (^)(BOOL sendToLib))reply {
  NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
  NSNumber *conversationType = [[NSNumber alloc] initWithInteger:type];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : conversationType
  }];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId
  }];

  RCVoiceMessage *voiceMsg =
      [RCVoiceMessage messageWithAudio:voiceData duration:duration];
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:voiceMsg];
  [para
      addEntriesFromDictionary:@{WK_APP_COMMUNICATE_PARAMETER_CONTENT : data}];

  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_SEND_MSG
                         parameter:para
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *result = (NSNumber *)replyObject;
                                 reply([result boolValue]);
                               } else {
                                 reply(NO);
                               }
                             }];
}

+ (void)requestParentAppClearUnreadStatus:(NSString *)targetId
                                     type:(int)type
                                    reply:(void (^)(BOOL success))reply {
  NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
  NSNumber *conversationType = [[NSNumber alloc] initWithInteger:type];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : conversationType
  }];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId
  }];

  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_CLEAR_UNREAD_COUNT
                         parameter:para
                             reply:^(id replyObject) {
                               if (replyObject) {
                                 NSNumber *result = (NSNumber *)replyObject;
                                 reply([result boolValue]);
                               } else {
                                 reply(NO);
                               }
                             }];
}

+ (void)requestParentAppLoadImage:(int)conversationType
                         targetId:(NSString *)targetId
                         imageUrl:(NSString *)imageUrl
                            reply:(void (^)(UIImage *image))reply {
  NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
  NSNumber *type =
      [[NSNumber alloc] initWithInteger:conversationType];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : type
  }];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId
  }];
  [para addEntriesFromDictionary:@{
    WK_APP_COMMUNICATE_PARAMETER_IMAGE_URL : imageUrl
  }];

  [RCAppQueryHelper
      queryParentApp:WK_APP_COMMUNICATE_REQUEST_DOWNLOAD_IMAGE
           parameter:para
               reply:^(id replyObject) {
                 if (replyObject) {
                   NSString *to = (NSString *)replyObject;
                   NSLog(@"to string is %@", to);
                   NSFileManager *fileManager = [NSFileManager defaultManager];
                   NSURL *containerUrl = [fileManager
                       containerURLForSecurityApplicationGroupIdentifier:
                           [RCAppInfoModel sharedModel].appGroups];
                   containerUrl = [containerUrl URLByAppendingPathComponent:to];
                   NSData *data = [NSData dataWithContentsOfURL:containerUrl];
                   UIImage *image = [UIImage imageWithData:data];
                   reply(image);
                 } else {
                   reply(nil);
                   NSLog(@"reply is nil");
                 }
               }];
}
+ (void)requestParentAppCacheAllHeadIcon
{
  [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_CACHE_ALL_HEAD_ICON
                         parameter:nil
                             reply:^(id replyObject) {
                               NSLog(
                                   @"requestParentAppCacheAllHeadIcon got reply");
                             }];
}
+ (void)requestParentAppCacheHeadIcon:(int)conversationType
                             targetId:(NSString *)targetId {
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para addEntriesFromDictionary:@{
                                     WK_APP_COMMUNICATE_PARAMETER_TARGET_ID : targetId
                                     }];
    NSNumber *type =
    [[NSNumber alloc] initWithInteger:conversationType];
    [para addEntriesFromDictionary:@{
                                     WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE : type
                                     }];
    
    [RCAppQueryHelper queryParentApp:WK_APP_COMMUNICATE_REQUEST_CACHE_HEAD_ICON
                           parameter:para
                               reply:^(id replyObject) {
                                   NSLog(
                                         @"WK_APP_COMMUNICATE_REQUEST_CACHE_HEAD_ICON got reply");
                               }];
}
+ (void)queryParentApp:(NSString *)query
             parameter:(NSDictionary *)parameter
                 reply:(void (^)(id replyObject))reply {

  NSMutableDictionary *queryInfo = [[NSMutableDictionary alloc]
      initWithDictionary:@{WK_APP_COMMUNICATE_QUERY : query}];
  if (parameter) {
    [queryInfo addEntriesFromDictionary:parameter];
  }
  [WKInterfaceController
      openParentApplication:queryInfo
                      reply:^(NSDictionary *replyInfo, NSError *error) {
                        if (error) {
                          NSLog(@"error is %@", error);
                        }
                        if (!error) {
                          id data = replyInfo[WK_APP_COMMUNICATE_REPLY];
                          reply(data);
                        } else {
                          reply(nil);
                        }
                      }];
}

@end
