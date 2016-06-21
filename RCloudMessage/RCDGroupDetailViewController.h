//
//  RCDGroupDetailViewController.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCDGroupInfo.h"

#define  EditNickNameInGroup @"EditNickNameInGroup"
#define  EditGroupIntroduce @"EditGroupIntroduce"
#define  EditGroupName @"EditGroupName"
/**
 *  定义block
 *
 *  @param isSuccess isSuccess description
 */
typedef void (^clearMessageCompletion)(BOOL isSuccess);

@interface RCDGroupDetailViewController : UITableViewController
/**
 *  清除历史消息后，会话界面调用roload data
 */
@property(nonatomic, copy) clearMessageCompletion clearHistoryCompletion;

@property (strong, nonatomic) IBOutlet UITableView *tbGroupInfo;
@property (strong, nonatomic)  RCDGroupInfo *groupInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbGroupName;
@property (weak, nonatomic) IBOutlet UIImageView *imgGroupPortait;
@property (weak, nonatomic) IBOutlet UILabel *lbGroupIntru;
@property (weak, nonatomic) IBOutlet UILabel *lbGroupNotice;
@property (weak, nonatomic) IBOutlet UILabel *lbMyNickNameInGroup;
@property (weak, nonatomic) IBOutlet UILabel *lbNumberInGroup;
@property (weak, nonatomic) IBOutlet UISwitch *swMessageNotDistrub;
@property (weak, nonatomic) IBOutlet UISwitch *swConversationTop;
@property (weak, nonatomic) IBOutlet UIButton *btClearMessage;
@property (weak, nonatomic) IBOutlet UITableViewCell *messageDisTrubleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *messageTopCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearMessageCell;

@property (weak, nonatomic) IBOutlet UIButton *btChat;
@property (weak, nonatomic) IBOutlet UIButton *btJoinOrQuitGroup;
- (IBAction)joinOrQuitGroup:(id)sender;
- (IBAction)beginGroupChat:(id)sender;
- (IBAction)setIsMessageDistruble:(id)sender;
- (IBAction)setConversationTop:(id)sender;

@end
