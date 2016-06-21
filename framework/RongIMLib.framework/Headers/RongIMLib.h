/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RongIMLib.h
//  Created by xugang on 14/12/11.

#import <UIKit/UIKit.h>

//! Project version number for RongIMLib.
FOUNDATION_EXPORT double RongIMLibVersionNumber;

//! Project version string for RongIMLib.
FOUNDATION_EXPORT const unsigned char RongIMLibVersionString[];

/// IMLib核心类
#import <RongIMLib/RCIMClient.h>
#import <RongIMLib/RCStatusDefine.h>
/// 会话相关类
#import <RongIMLib/RCConversation.h>
#import <RongIMLib/RCDiscussion.h>
#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserTypingStatus.h>
#import <RongIMLib/RCChatRoomInfo.h>
/// 消息相关类
#import <RongIMLib/RCMessage.h>
#import <RongIMLib/RCMessageContent.h>
#import <RongIMLib/RCMessageContentView.h>
#import <RongIMLib/RCTextMessage.h>
#import <RongIMLib/RCImageMessage.h>
#import <RongIMLib/RCVoiceMessage.h>
#import <RongIMLib/RCLocationMessage.h>
#import <RongIMLib/RCRichContentMessage.h>
#import <RongIMLib/RCRealTimeLocationStartMessage.h>
#import <RongIMLib/RCRealTimeLocationEndMessage.h>
#import <RongIMLib/RCCommandMessage.h>
#import <RongIMLib/RCCommandNotificationMessage.h>
#import <RongIMLib/RCInformationNotificationMessage.h>
#import <RongIMLib/RCUnknownMessage.h>
#import <RongIMLib/RCProfileNotificationMessage.h>
#import <RongIMLib/RCPublicServiceCommandMessage.h>
#import <RongIMLib/RCPublicServiceMultiRichContentMessage.h>
#import <RongIMLib/RCPublicServiceRichContentMessage.h>
#import <RongIMLib/RCDiscussionNotificationMessage.h>
#import <RongIMLib/RCGroupNotificationMessage.h>
#import <RongIMLib/RCContactNotificationMessage.h>
/// 工具类
#import <RongIMLib/RCUtilities.h>
#import <RongIMLib/RCAmrDataConverter.h>
#import <RongIMLib/interf_enc.h>
#import <RongIMLib/interf_dec.h>

///客服
#import <RongIMLib/RCEvaluateItem.h>
#import <RongIMLib/RCCustomerServiceInfo.h>

/// 其他
#import <RongIMLib/RCUserInfo.h>
#import <RongIMLib/RCChatRoomMemberInfo.h>
#import <RongIMLib/RCPublicServiceMenu.h>
#import <RongIMLib/RCPublicServiceProfile.h>
#import <RongIMLib/RCRealTimeLocationManager.h>
#import <RongIMLib/RCUploadImageStatusListener.h>
#import <RongIMLib/RCWatchKitStatusDelegate.h>
#import <RongIMLib/RCStatusMessage.h>