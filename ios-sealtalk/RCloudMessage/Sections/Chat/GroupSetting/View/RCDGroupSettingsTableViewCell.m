//
//  RCDGroupSettingsTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupSettingsTableViewCell.h"
#import "RCDGroupInfo.h"
#import "RCDUtilities.h"
#import "RCDGroupManager.h"
#import "RCDDBManager.h"

@implementation RCDGroupSettingsTableViewCell
- (instancetype)initWithTitle:(NSString *)title andGroupInfo:(RCDGroupInfo *)groupInfo {
    groupInfo = [RCDGroupManager getGroupInfo:groupInfo.groupId];
    if ([title isEqualToString:RCDLocalizedString(@"group_portrait")]) {
        NSString *groupPortrait;
        if ([groupInfo.portraitUri isEqualToString:@""]) {
            groupPortrait = [RCDUtilities defaultGroupPortrait:groupInfo];
        } else {
            groupPortrait = groupInfo.portraitUri;
        }
        self = [super initWithLeftImageStr:nil
                             leftImageSize:CGSizeZero
                              rightImaeStr:groupPortrait
                            rightImageSize:CGSizeMake(25, 25)];
    } else if ([title isEqualToString:RCDLocalizedString(@"GroupQR")]) {
        self = [super initWithLeftImageStr:nil
                             leftImageSize:CGSizeZero
                              rightImaeStr:@"qr"
                            rightImageSize:CGSizeMake(22, 22)];
    }
    //一般cell
    else {
        self = [super init];
    }
    [self initSubviewsWithTitle:title andGroupInfo:groupInfo];
    return self;
}

- (void)initSubviewsWithTitle:(NSString *)title andGroupInfo:(RCDGroupInfo *)groupInfo {
    self.leftLabel.text = title;
    if ([title
            isEqualToString:[NSString stringWithFormat:RCDLocalizedString(@"all_group_member_z"), groupInfo.number]]) {
        [self setCellStyle:DefaultStyle];
        self.tag = RCDGroupSettingsTableViewCellGroupNameTag;
    } else if ([title isEqualToString:RCDLocalizedString(@"group_portrait")]) {
        [self setCellStyle:DefaultStyle];
        self.tag = RCDGroupSettingsTableViewCellGroupPortraitTag;
    } else if ([title isEqualToString:RCDLocalizedString(@"group_name")]) {
        [self setCellStyle:DefaultStyle_RightLabel];
        self.rightLabel.text = groupInfo.groupName;
    } else if ([title isEqualToString:RCDLocalizedString(@"GroupQR")]) {
        [self setCellStyle:DefaultStyle];
    } else if ([title isEqualToString:RCDLocalizedString(@"group_announcement")]) {
        [self setCellStyle:DefaultStyle];
    } else if ([title isEqualToString:RCDLocalizedString(@"GroupManage")]) {
        [self setCellStyle:DefaultStyle];
    } else if ([title isEqualToString:RCDLocalizedString(@"search_chat_history")]) {
        [self setCellStyle:DefaultStyle];
    } else if ([title isEqualToString:RCDLocalizedString(@"mute_notifications")]) {
        [self setCellStyle:SwitchStyle];
        self.switchButton.tag = SwitchButtonTag;
    } else if ([title isEqualToString:RCDLocalizedString(@"stick_on_top")]) {
        [self setCellStyle:SwitchStyle];
        self.switchButton.tag = SwitchButtonTag + 1;
    } else if ([title isEqualToString:RCDLocalizedString(@"SaveToAddress")]) {
        [self setCellStyle:SwitchStyle];
        self.switchButton.tag = SwitchButtonTag + 2;
        self.switchButton.on = [RCDGroupManager isInMyGroups:groupInfo.groupId];
    } else if ([title isEqualToString:RCDLocalizedString(@"ScreenCaptureNotification")]) {
        [self setCellStyle:SwitchStyle];
        self.switchButton.tag = SwitchButtonTag + 3;
    } else if ([title isEqualToString:RCDLocalizedString(@"CleanUpGroupMessagesRegularly")]) {
        [self setCleanUpGroupMessagesRegularly:groupInfo];
    } else if ([title isEqualToString:RCDLocalizedString(@"clear_chat_history")]) {
        [self setClearChatHistory];
    } else if ([title isEqualToString:RCDLocalizedString(@"MyInfoInGroup")]) {
        [self setCellStyle:DefaultStyle];
    }
}

- (void)setClearChatHistory {
    [self setCellStyle:DefaultStyle];
    self.leftLabel.text = RCDLocalizedString(@"clear_chat_history");
}

- (void)setCleanUpGroupMessagesRegularly:(RCDGroupInfo *)groupInfo {
    [self setCellStyle:DefaultStyle_RightLabel];
    self.leftLabel.text = RCDLocalizedString(@"CleanUpGroupMessagesRegularly");
    RCDGroupMessageClearStatus status =
        [RCDDBManager getMessageClearStatus:ConversationType_GROUP targetId:groupInfo.groupId];
    [self changeGroupMessageStatus:status];
}

- (void)changeGroupMessageStatus:(RCDGroupMessageClearStatus)status {
    NSString *content = nil;
    switch (status) {
    case RCDGroupMessageClearStatusClose:
        content = RCDLocalizedString(@"PleaseSetTime");
        break;
    case RCDGroupMessageClearStatusBefore3d:
        content = RCDLocalizedString(@"CleanUpGroupMessages3DaysAgo");
        break;
    case RCDGroupMessageClearStatusBefore7d:
        content = RCDLocalizedString(@"CleanUpGroupMessages7DaysAgo");
        break;
    case RCDGroupMessageClearStatusBefore36h:
        content = RCDLocalizedString(@"CleanUpGroupMessages36HoursAgo");
        break;
    case RCDGroupMessageClearStatusUnknown:
        content = RCDLocalizedString(@"PleaseSetTime");
    default:
        break;
    }
    self.rightLabel.text = content;
}

@end
