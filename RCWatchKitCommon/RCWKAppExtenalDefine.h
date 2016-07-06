//
//  RCWKAppExtenalDefine.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RongIMWatchKit_RCWKAppExtenalDefine_h
#define RongIMWatchKit_RCWKAppExtenalDefine_h

#pragma mark - WK App shared user default

#define WK_APP_SHARED_DEFAULT_MSG_LAST_UPDATE_TIME                             \
  @"rc:demo:msg last update date"
#define WK_APP_SHARED_DEFAULT_CONNECTION_STATUS @"rc:demo:connection status"
#define WK_APP_SHARED_DEFAULT_CONTACT_UPDATE_TIME                              \
  @"rc:demo:contact last update date"
#define WK_APP_SHARED_DEFAULT_LAST_LOADED_IMAGE @"rc:demo:last update image"

#pragma mark - WK notifition center
#define RC_MESSAGE_CHANGED_EVENT @"RC_MESSAGE_CHANGED_EVENT"
#define RC_USER_INFO_CHANGED_EVENT @"RC_USER_INFO_CHANGED_EVENT"
#define RC_GROUP_INFO_CHANGED_EVENT @"RC_GROUP_INFO_CHANGED_EVENT"
#define RC_FRIEND_CHANGED_EVENT @"RC_FRIEND_CHANGED_EVENT"
#define RC_LOAD_IMAGE_DONE_EVENT @"RC_LOAD_IMAGE_DONE_EVENT"
#define RC_CONNECTION_STATUS_CHANGED_EVENT @"RC_CONNECTION_STATUS_CHANGED_EVENT"

#endif
