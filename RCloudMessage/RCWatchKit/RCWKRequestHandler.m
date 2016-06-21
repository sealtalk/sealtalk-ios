//
//  RCWKRequestHandler.m
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//
#import <RongIMLib/RongIMLib.h>
#import "RCWKRequestHandler.h"
#import "RCWKAPPCommonDefine.h"
#import "RCWKSharedUserDefault.h"
#import "RCWKNotifier.h"

@interface RCWKRequestHandler ()
@property(strong, nonatomic) NSDictionary *userInfo;
@property(strong, nonatomic) void (^reply)(NSDictionary *);
@property(weak, nonatomic) id<RCWKAppInfoProvider> provider;
@end

@implementation RCWKRequestHandler
- (instancetype)initHelperWithUserInfo:(NSDictionary *)userInfo
                              provider:(id<RCWKAppInfoProvider>)provider
                                 reply:(void (^)(NSDictionary *))reply {
  self = [super init];

  if (self) {
    self.userInfo = userInfo;
    self.reply = reply;
    self.provider = provider;
  }

  return self;
}

- (BOOL)handleWatchKitRequest {
  NSString *query = [self getQuery];
  NSLog(@"get the query of %@", query);

  if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_UNREAD_COUNT]) {
    int count = [[RCIMClient sharedRCIMClient]
        getUnreadCount:
            @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    [self replyWKApp:[NSNumber numberWithInt:count]];
  } else if ([query
                 isEqualToString:WK_APP_COMMUNICATE_QUERY_CONVERSATION_LIST]) {
    NSArray *conversationTypes =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
    NSArray *conversationList =
        [[RCIMClient sharedRCIMClient] getConversationList:conversationTypes];

    for (RCConversation *conversation in conversationList) {
      NSLog(@"object is %@", conversation.objectName);
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:conversationList];
    [self replyWKApp:data];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_CONVERSATION]) {
    NSLog(@"query conversation");
    NSString *targetID =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_TARGET_ID];
    NSNumber *conversationType =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
    NSNumber *olderMsgId =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_OLDER_MESSAG_ID];
    NSNumber *count =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_COUNT];
    NSArray *messages = [[RCIMClient sharedRCIMClient]
        getHistoryMessages:[conversationType intValue]
                  targetId:targetID
           oldestMessageId:[olderMsgId longValue]
                     count:[count intValue]];
    [messages enumerateObjectsUsingBlock:^(RCMessage *msg, NSUInteger idx,
                                           BOOL *stop) {
      if ([msg.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMsg = (RCImageMessage *)msg.content;
        imageMsg.thumbnailImage =
            [self scaleImage:imageMsg.thumbnailImage maxWidth:80 round:NO];
        imageMsg.originalImage =
            [self scaleImage:imageMsg.originalImage maxWidth:140 round:NO];
      } else if ([msg.content isKindOfClass:[RCLocationMessage class]]) {
        RCLocationMessage *locationMsg = (RCLocationMessage *)msg.content;
        locationMsg.thumbnailImage =
            [self scaleImage:locationMsg.thumbnailImage maxWidth:80 round:NO];
      }
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:messages];
    [self replyWKApp:data];
  } else if ([query
                 isEqualToString:WK_APP_COMMUNICATE_REQUEST_CACHE_ALL_HEAD_ICON]) {
    NSArray *array = [self.provider getAllUserInfo];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerUrl =
        [fileManager containerURLForSecurityApplicationGroupIdentifier:
                         [self.provider getAppGroups]];
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          for (RCUserInfo *userInfo in array) {
            NSURL *currentUrl =
                [containerUrl URLByAppendingPathComponent:userInfo.userId];
            if (![fileManager fileExistsAtPath:[currentUrl path]]) {
              UIImage *image = [UIImage
                  imageWithData:
                      [NSData dataWithContentsOfURL:
                                  [NSURL URLWithString:userInfo.portraitUri]]];
              NSLog(@"size is %f, %f", image.size.width, image.size.height);
              if (image && [image size].width > 0) {
                [self copyImage:image to:userInfo.userId maxWidth:50 round:YES];
              }
            }
          }
          [[RCWKNotifier sharedWKNotifier] notifyWatchKitLoadImageDone:nil];
        });

    NSNumber *result = [NSNumber numberWithBool:YES];
    [self replyWKApp:result];
  } else if ([query
              isEqualToString:WK_APP_COMMUNICATE_REQUEST_CACHE_HEAD_ICON]) {

      NSString *targetId = [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_TARGET_ID];
      NSNumber *conversationType = [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
      NSFileManager *fileManager = [NSFileManager defaultManager];
      NSURL *containerUrl =
      [fileManager containerURLForSecurityApplicationGroupIdentifier:
       [self.provider getAppGroups]];
      dispatch_async(
                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             NSURL *currentUrl =
                             [containerUrl URLByAppendingPathComponent:targetId];
                             if (![fileManager fileExistsAtPath:[currentUrl path]]) {
                                 if (conversationType.intValue == ConversationType_PUBLICSERVICE
                                     || conversationType.intValue == ConversationType_APPSERVICE) {
                                     NSArray *publicServices = [[RCIMClient sharedRCIMClient] getPublicServiceList];
                                     for (RCPublicServiceProfile *profile in publicServices) {
                                         if ([profile.publicServiceId isEqualToString:targetId]) {
                                             UIImage *image = [UIImage
                                                               imageWithData:
                                                               [NSData dataWithContentsOfURL:
                                                                [NSURL URLWithString:profile.portraitUrl ]]];
                                             NSLog(@"size is %f, %f", image.size.width, image.size.height);
                                             if (image && [image size].width > 0) {
                                                 [self copyImage:image to:targetId maxWidth:50 round:YES];
                                             }
                                             break;
                                         }
                                     }
                                 }

                             }
                         [[RCWKNotifier sharedWKNotifier] notifyWatchKitLoadImageDone:nil];
                     });
      
      NSNumber *result = [NSNumber numberWithBool:YES];
      [self replyWKApp:result];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_REQUEST_SEND_MSG]) {
    NSString *targetID =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_TARGET_ID];
    NSNumber *conversationType =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
    NSData *contentData =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONTENT];
    RCMessageContent *content =
        [NSKeyedUnarchiver unarchiveObjectWithData:contentData];
      /*
       - (RCMessage *)sendMessage:(RCConversationType)conversationType
       targetId:(NSString *)targetId
       content:(RCMessageContent *)content
       pushContent:(NSString *)pushContent
       success:(void (^)(long messageId))successBlock
       error:(void (^)(RCErrorCode nErrorCode,
       long messageId))errorBlock;
       */
    id response =
        [[RCIMClient sharedRCIMClient] sendMessage:[conversationType intValue]
            targetId:targetID
            content:content
        pushContent:nil
            success:^(long messageId) {
              NSLog(@"success");
              [self replyWKApp:[NSNumber numberWithBool:YES]];
            }
            error:^(RCErrorCode nErrorCode, long messageId) {
              NSLog(@"error %d", (int)nErrorCode);
              [self replyWKApp:[NSNumber numberWithBool:NO]];
            }];

    if (!response) {
      [self replyWKApp:[NSNumber numberWithBool:NO]];
    }
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_APP_NAME]) {
    [self replyWKApp:[self.provider getAppName]];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_APP_GROUPS]) {
    [self replyWKApp:[self.provider getAppGroups]];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_NOTIFY_SOUND]) {
    NSNumber *on = [NSNumber
        numberWithBool:[self.provider getNewMessageNotificationSound]];
    [self replyWKApp:on];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_SET_NOTIFY_SOUND]) {
    NSNumber *on =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_NEW_MESSAGE_SOUND];
    [self.provider setNewMessageNotificationSound:[on boolValue]];
    [self replyWKApp:nil];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_REQUEST_NOTIFICATION]) {
      NSNumber *notify =
      [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_NOTIFY_OR_NOT];
      [[RCWKNotifier sharedWKNotifier] setWatchAttached:[notify boolValue]];
      if ([RCIMClient sharedRCIMClient].watchKitStatusDelegate == nil) {
          [RCIMClient sharedRCIMClient].watchKitStatusDelegate = [RCWKNotifier sharedWKNotifier];
      }
      [self replyWKApp:nil];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_REQUEST_LOGOUT]) {
    [self.provider logout];
    [self replyWKApp:nil];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_REQUEST_OPEN_APP]) {
      [self.provider openParentApp];
      [self replyWKApp:nil];
  } else if ([query
                 isEqualToString:WK_APP_COMMUNICATE_QUERY_CONNECTION_STATUS]) {

      [self replyWKApp:[NSNumber numberWithBool:[self.provider getLoginStatus]]];
  } else if ([query isEqualToString:
                        WK_APP_COMMUNICATE_REQUEST_CLEAR_UNREAD_COUNT]) {
    NSString *targetID =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_TARGET_ID];
    NSNumber *conversationType =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
    BOOL result = [[RCIMClient sharedRCIMClient]
        clearMessagesUnreadStatus:[conversationType intValue]
                         targetId:targetID];
    [self replyWKApp:[NSNumber numberWithBool:result]];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_CONTACT_LIST]) {
    NSArray *contacts = [self.provider getAllUserInfo];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:contacts];
    [self replyWKApp:data];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_GROUP_LIST]) {
      NSArray *groups = [self.provider getAllGroupInfo];
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups];
      [self replyWKApp:data];
  } else if ([query isEqualToString:WK_APP_COMMUNICATE_QUERY_FRIEND_LIST]) {
      NSArray *groups = [self.provider getAllFriends];
      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups];
      [self replyWKApp:data];
  } else if ([query
                 isEqualToString:WK_APP_COMMUNICATE_REQUEST_DOWNLOAD_IMAGE]) {
    NSString *targetId =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_TARGET_ID];
    NSNumber *conversationType =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE];
    NSString *imageUrl =
        [self getQueryParameter:WK_APP_COMMUNICATE_PARAMETER_IMAGE_URL];

      if ([self isLocalPath:imageUrl]) {
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              //当imageUrl是本地路径时，由于沙盒路径经常会变动，直接使用会无法找到文件，生成一个image message对象，设置路径然后再取出，就能取出当前正确的路径。
              RCImageMessage *imageMsg = [[RCImageMessage alloc] init];
              imageMsg.imageUrl = imageUrl;
              NSString *toPath = @"loadedImage.tmp";
              if ([self copyForShare:imageMsg.imageUrl to:toPath maxWidth:140]) {
                  [self replyWKApp:toPath];
              } else {
                  [self replyWKApp:nil];
              }
          });
      } else {
      [[RCIMClient sharedRCIMClient] downloadMediaFile:[conversationType intValue]
                                              targetId:targetId
                                             mediaType:MediaType_IMAGE
                                              mediaUrl:imageUrl
                                              progress:^(int progress) {
                                                   NSLog(@"progress %d", progress);
                                              }
                                               success:^(NSString *mediaPath) {
                                                   NSLog(@"[RongIMKit]:downloadMediaFile.mediaPath > %@, isMainThread > "
                                                         @"%d",
                                                         mediaPath, [NSThread isMainThread]);
                                                   
                                                   NSString *toPath = @"loadedImage.tmp";
                                                   if ([self copyForShare:mediaPath to:toPath maxWidth:140]) {
                                                       [self replyWKApp:toPath];
                                                   } else {
                                                       [self replyWKApp:nil];
                                                   }
                                               }
                                                 error:^(RCErrorCode errorCode) {
                                                     NSLog(@"[RongIMKit]: downloadMediaFile.errorCode > %d",
                                                           (int)errorCode);
                                                     [self replyWKApp:nil];
                                                     
                                                 }];
      }
      
  } else {
    return NO;
  }
  return YES;
}

- (void)replyWKApp:(id)replyObject {
  if (replyObject) {
    NSDictionary *replyInfo = @{WK_APP_COMMUNICATE_REPLY : replyObject};
    self.reply(replyInfo);
  } else {
    self.reply(nil);
  }
}
- (NSString *)getQuery {
  return self.userInfo[WK_APP_COMMUNICATE_QUERY];
}

- (id)getQueryParameter:(NSString *)parameterType {
  return self.userInfo[parameterType];
}

- (UIImage *)scaleImage:(UIImage *)image
               maxWidth:(NSUInteger)maxWidth
                  round:(BOOL)round {
  if (round) {
    CGRect frame = CGRectMake(0, 0, maxWidth, maxWidth);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxWidth, maxWidth), NO,
                                           1.0);
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:maxWidth / 2] addClip];
    [image drawInRect:frame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  } else if (image.size.width > maxWidth) {
    double scale = maxWidth / image.size.width;
    CGSize size = CGSizeMake(maxWidth, image.size.height * scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = scaledImage;
  }
  return image;
}

- (BOOL)copyImage:(UIImage *)image
               to:(NSString *)to
         maxWidth:(int)maxWidth
            round:(BOOL)round {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *containerUrl =
      [fileManager containerURLForSecurityApplicationGroupIdentifier:
                       [self.provider getAppGroups]];
  containerUrl = [containerUrl URLByAppendingPathComponent:to];

  image = [self scaleImage:image maxWidth:maxWidth round:round];
  NSData *data = UIImagePNGRepresentation(image);

  return [data writeToURL:containerUrl atomically:YES];
}
- (BOOL)copyForShare:(NSString *)fromPath
                  to:(NSString *)to
            maxWidth:(int)maxWidth {

  UIImage *image = [UIImage imageWithContentsOfFile:fromPath];
  return [self copyImage:image to:to maxWidth:maxWidth round:NO];
}
- (BOOL)isLocalPath:(NSString *)path {
    if ([path length] && ([path characterAtIndex:0] == '/' || [path characterAtIndex:0] == '~')) {
        return YES;
    }
    return NO;
}
@end
