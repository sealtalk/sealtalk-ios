//
//  RCWKAPPCommonDefine.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#ifndef RongIMDemo_RCWKAPPCommonDefine_h
#define RongIMDemo_RCWKAPPCommonDefine_h
#include "RCWKAppExtenalDefine.h"

#pragma mark - WK App directly commoncation
#define WK_APP_COMMUNICATE_QUERY @"rc:wk:query"
#define WK_APP_COMMUNICATE_REPLY @"rc:wk:reply"

#define WK_APP_COMMUNICATE_QUERY_UNREAD_COUNT @"unread count"
#define WK_APP_COMMUNICATE_QUERY_APP_NAME @"app name"
#define WK_APP_COMMUNICATE_QUERY_APP_GROUPS @"app groups"
#define WK_APP_COMMUNICATE_QUERY_CONVERSATION_LIST @"conversation list"
#define WK_APP_COMMUNICATE_QUERY_CONVERSATION @"conversation"
#define WK_APP_COMMUNICATE_QUERY_CONNECTION_STATUS @"connection status"
#define WK_APP_COMMUNICATE_QUERY_CONTACT_LIST @"contact list"
#define WK_APP_COMMUNICATE_QUERY_GROUP_LIST @"group list"
#define WK_APP_COMMUNICATE_QUERY_FRIEND_LIST @"friend list"
#define WK_APP_COMMUNICATE_QUERY_NOTIFY_SOUND @"query notify sound"
#define WK_APP_COMMUNICATE_SET_NOTIFY_SOUND @"set notify sound"
#define WK_APP_COMMUNICATE_REQUEST_LOGOUT @"log out"
#define WK_APP_COMMUNICATE_REQUEST_OPEN_APP @"open app"
#define WK_APP_COMMUNICATE_REQUEST_NOTIFICATION @"receive status notification"
#define WK_APP_COMMUNICATE_REQUEST_CLEAR_UNREAD_COUNT @"clear unread count"
#define WK_APP_COMMUNICATE_REQUEST_SEND_MSG @"send message"
#define WK_APP_COMMUNICATE_REQUEST_DOWNLOAD_IMAGE @"download image"
#define WK_APP_COMMUNICATE_REQUEST_CACHE_ALL_HEAD_ICON @"cache all head icon"
#define WK_APP_COMMUNICATE_REQUEST_CACHE_HEAD_ICON @"cache head icon"

#define WK_APP_COMMUNICATE_PARAMETER_CONVERSATION_TYPE @"conversation type"
#define WK_APP_COMMUNICATE_PARAMETER_TARGET_ID @"targetID"
#define WK_APP_COMMUNICATE_PARAMETER_OLDER_MESSAG_ID @"older message id"
#define WK_APP_COMMUNICATE_PARAMETER_CONTENT @"content"
#define WK_APP_COMMUNICATE_PARAMETER_COUNT @"count"
#define WK_APP_COMMUNICATE_PARAMETER_IMAGE_URL @"imageUrl"
#define WK_APP_COMMUNICATE_PARAMETER_NEW_MESSAGE_SOUND @"new msg sound"
#define WK_APP_COMMUNICATE_PARAMETER_NOTIFY_OR_NOT @"isnotify"
#endif
