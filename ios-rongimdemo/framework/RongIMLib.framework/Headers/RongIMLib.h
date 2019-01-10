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
#import <RongIMLib/RCChatRoomInfo.h>
#import <RongIMLib/RCConversation.h>
#import <RongIMLib/RCDiscussion.h>
#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserTypingStatus.h>
/// 消息相关类
#import <RongIMLib/RCCSLeaveMessage.h>
#import <RongIMLib/RCCSPullLeaveMessage.h>
#import <RongIMLib/RCCommandMessage.h>
#import <RongIMLib/RCCommandNotificationMessage.h>
#import <RongIMLib/RCContactNotificationMessage.h>
#import <RongIMLib/RCDiscussionNotificationMessage.h>
#import <RongIMLib/RCGroupNotificationMessage.h>
#import <RongIMLib/RCImageMessage.h>
#import <RongIMLib/RCInformationNotificationMessage.h>
#import <RongIMLib/RCLocationMessage.h>
#import <RongIMLib/RCMessage.h>
#import <RongIMLib/RCMessageContent.h>
#import <RongIMLib/RCMediaMessageContent.h>
#import <RongIMLib/RCProfileNotificationMessage.h>
#import <RongIMLib/RCPublicServiceCommandMessage.h>
#import <RongIMLib/RCPublicServiceMultiRichContentMessage.h>
#import <RongIMLib/RCPublicServiceRichContentMessage.h>
#import <RongIMLib/RCRealTimeLocationEndMessage.h>
#import <RongIMLib/RCRealTimeLocationStartMessage.h>
#import <RongIMLib/RCRecallNotificationMessage.h>
#import <RongIMLib/RCRichContentMessage.h>
#import <RongIMLib/RCTextMessage.h>
#import <RongIMLib/RCUnknownMessage.h>
#import <RongIMLib/RCVoiceMessage.h>
#import <RongIMLib/RCSightMessage.h>
/// 工具类
#import <RongIMLib/RCAMRDataConverter.h>
#import <RongIMLib/RCTSMutableDictionary.h>
#import <RongIMLib/RCUtilities.h>
#import <RongIMLib/interf_dec.h>
#import <RongIMLib/interf_enc.h>
///客服
#import <RongIMLib/RCCSLeaveMessageItem.h>
#import <RongIMLib/RCCustomerServiceInfo.h>
#import <RongIMLib/RCEvaluateItem.h>

/// 其他
#import <RongIMLib/RCChatRoomMemberInfo.h>
#import <RongIMLib/RCCustomerServiceGroupItem.h>
#import <RongIMLib/RCPublicServiceMenu.h>
#import <RongIMLib/RCPublicServiceProfile.h>
#import <RongIMLib/RCRealTimeLocationManager.h>
#import <RongIMLib/RCStatusMessage.h>
#import <RongIMLib/RCUploadImageStatusListener.h>
#import <RongIMLib/RCUploadMediaStatusListener.h>
#import <RongIMLib/RCUserInfo.h>
#import <RongIMLib/RCWatchKitStatusDelegate.h>

#import <RongIMLib/RCFileMessage.h>
#import <RongIMLib/RCFileUtility.h>
#import <RongIMLib/RCReadReceiptInfo.h>
#import <RongIMLib/RCUserOnlineStatusInfo.h>

// log
#import <RongIMLib/RCFwLog.h>

//Downlad
#import <RongIMLib/RCDownloadItem.h>
#import <RongIMLib/RCResumeableDownloader.h>
