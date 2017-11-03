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

@implementation RCDGroupSettingsTableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath andGroupInfo:(RCDGroupInfo *)groupInfo {
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
        self.leftLabel.text = [NSString stringWithFormat:@"全部群成员(%@)", groupInfo.number];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
        case 0: {
            [self setCellStyle:DefaultStyle];
            self.tag = RCDGroupSettingsTableViewCellGroupPortraitTag;
            self.leftLabel.text = @"群组头像";
        } break;
        case 1:
            [self setCellStyle:DefaultStyle_RightLabel];
            self.leftLabel.text = @"群组名称";
            self.rightLabel.text = groupInfo.groupName;
            break;
        case 2:
            [self setCellStyle:DefaultStyle];
            self.leftLabel.text = @"群公告";
            break;
        default:
            break;
        }
    } else if (indexPath.section == 2) {
        [self setCellStyle:DefaultStyle];
        self.leftLabel.text = @"查找聊天记录";
    } else {
        switch (indexPath.row) {
        case 0:
            [self setCellStyle:SwitchStyle];
            self.leftLabel.text = @"消息免打扰";
            self.switchButton.tag = SwitchButtonTag;
            break;
        case 1:
            [self setCellStyle:SwitchStyle];
            self.leftLabel.text = @"会话置顶";
            self.switchButton.tag = SwitchButtonTag + 1;
            break;
        case 2:
            [self setCellStyle:DefaultStyle];
            self.leftLabel.text = @"清除聊天记录";
            break;
        default:
            break;
        }
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
