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
@implementation RCDGroupSettingsTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath andGroupInfo:(RCDGroupInfo *)groupInfo {
    groupInfo = [RCDGroupManager getGroupInfo:groupInfo.groupId];
    //带右边图片的cell
    if (indexPath.section == 1 && indexPath.row == 0) {
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
    }else if (indexPath.section == 1 && indexPath.row == 2){
        self = [super initWithLeftImageStr:nil
                             leftImageSize:CGSizeZero
                              rightImaeStr:@"qr"
                            rightImageSize:CGSizeMake(22, 22)];
    }
    //一般cell
    else {
        self = [super init];
    }
    [self initSubviewsWithIndexPath:indexPath andGroupInfo:groupInfo];
    return self;
}

- (void)initSubviewsWithIndexPath:(NSIndexPath *)indexPath andGroupInfo:(RCDGroupInfo *)groupInfo {
    if (indexPath.section == 0) {
        [self setCellStyle:DefaultStyle];
        self.tag = RCDGroupSettingsTableViewCellGroupNameTag;
        self.leftLabel.text = [NSString stringWithFormat:RCDLocalizedString(@"all_group_member_z"), groupInfo.number];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                [self setCellStyle:DefaultStyle];
                self.tag = RCDGroupSettingsTableViewCellGroupPortraitTag;
                self.leftLabel.text = RCDLocalizedString(@"group_portrait");
            } break;
            case 1:
                [self setCellStyle:DefaultStyle_RightLabel];
                self.leftLabel.text = RCDLocalizedString(@"group_name");
                self.rightLabel.text = groupInfo.groupName;
                break;
            case 2: {
                [self setCellStyle:DefaultStyle];
                self.leftLabel.text = RCDLocalizedString(@"GroupQR");
            } break;
            case 3:
                [self setCellStyle:DefaultStyle];
                self.leftLabel.text = RCDLocalizedString(@"group_announcement");
                break;
            case 4:
                [self setCellStyle:DefaultStyle];
                self.leftLabel.text = RCDLocalizedString(@"GroupManage");
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        [self setCellStyle:DefaultStyle];
        self.leftLabel.text = RCDLocalizedString(@"search_chat_history");
    } else {
        switch (indexPath.row) {
            case 0:
                [self setCellStyle:SwitchStyle];
                self.leftLabel.text = RCDLocalizedString(@"mute_notifications");
                self.switchButton.tag = SwitchButtonTag;
                break;
            case 1:
                [self setCellStyle:SwitchStyle];
                self.leftLabel.text = RCDLocalizedString(@"stick_on_top");
                self.switchButton.tag = SwitchButtonTag + 1;
                break;
            case 2:
                [self setCellStyle:SwitchStyle];
                self.leftLabel.text = RCDLocalizedString(@"SaveToAddress");
                self.switchButton.tag = SwitchButtonTag + 2;
                self.switchButton.on = [RCDGroupManager isInMyGroups:groupInfo.groupId];
                break;
            case 3:
                [self setCellStyle:DefaultStyle];
                self.leftLabel.text = RCDLocalizedString(@"clear_chat_history");
                break;
            default:
                break;
        }
    }
}

@end
