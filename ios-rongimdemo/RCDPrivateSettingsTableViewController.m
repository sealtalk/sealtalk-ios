//
//  RCDPrivateSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/5/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPrivateSettingsTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDHttpTool.h"
#import "RCDPrivateSettingsCell.h"
#import "RCDPrivateSettingsUserInfoCell.h"
#import "UIImageView+WebCache.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"

@interface RCDPrivateSettingsTableViewController ()

//开始会话
@property(strong, nonatomic) UIButton *btChat;

@property(strong, nonatomic) RCDUserInfo *userInfo;

@end

@implementation RCDPrivateSettingsTableViewController {
  NSString *portraitUrl;
  NSString *nickname;
  BOOL enableNotification;
  RCConversation *currentConversation;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  //设置分割线颜色
  self.tableView.separatorColor =
  [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
  }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc]
                            initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText =
    [[UILabel alloc] initWithFrame:CGRectMake(9,4, 85, 17)];
    backText.text = @"返回"; // NSLocalizedStringFromTable(@"Back",
    // @"RongCloudKit", nil);
    //   backText.font = [UIFont systemFontOfSize:17];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self
                action:@selector(leftBarButtonItemPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =
    [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
  self.title = @"聊天详情";
  [self startLoadView];
  
  self.tableView.tableFooterView = [UIView new];
  self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
}

- (void)leftBarButtonItemPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSInteger rows;
  switch (section) {
  case 0:
    rows = 1;
    break;

  case 1:
    rows = 3;
    break;

  default:
    break;
  }

  return rows;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
  if (section == 1) {
    return 20.f;
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat heigh;
  switch (indexPath.section) {
  case 0:
    heigh = 86.5f;
    break;

  case 1:
    heigh = 50.f;
    break;

  default:
    break;
  }
  return heigh;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDPrivateSettingsUserInfoCell *infoCell;
  if (self.userInfo != nil) {
    portraitUrl = self.userInfo.portraitUri;
    if (self.userInfo.displayName.length > 0 && ![self.userInfo.displayName isEqualToString:@""]) {
      infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:YES];
      infoCell.NickNameLabel.text = self.userInfo.displayName;
      infoCell.displayNameLabel.text = [NSString stringWithFormat:@"昵称: %@",self.userInfo.name];
    } else {
      infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:NO];
      infoCell.NickNameLabel.text = self.userInfo.name;
    }
  } else {
    infoCell = [[RCDPrivateSettingsUserInfoCell alloc] initWithIsHaveDisplayName:NO];
    infoCell.NickNameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
    portraitUrl = [RCIM sharedRCIM].currentUserInfo.portraitUri;
  }
  
  
  static NSString *CellIdentifier = @"RCDPrivateSettingsCell";
  RCDPrivateSettingsCell *cell = (RCDPrivateSettingsCell *)[tableView
      dequeueReusableCellWithIdentifier:CellIdentifier];

  infoCell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;

  if (indexPath.section == 0) {
    if ([portraitUrl isEqualToString:@""]) {
      DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
          initWithFrame:CGRectMake(0, 0, 100, 100)];
      [defaultPortrait setColorAndLabel:self.userId Nickname:nickname];
      UIImage *portrait = [defaultPortrait imageFromView];
      infoCell.PortraitImageView.image = portrait;
    } else {
      [infoCell.PortraitImageView
          sd_setImageWithURL:[NSURL URLWithString:portraitUrl]
            placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    infoCell.PortraitImageView.layer.masksToBounds = YES;
    infoCell.PortraitImageView.layer.cornerRadius = 5.f;
    infoCell.PortraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    return infoCell;
  }

  switch (indexPath.row) {
  case 0: {
    cell.TitleLabel.text = @"消息免打扰";
    cell.SwitchButton.hidden = NO;
    cell.SwitchButton.on = !enableNotification;
    [cell.SwitchButton removeTarget:self
                             action:@selector(clickIsTopBtn:)
                   forControlEvents:UIControlEventValueChanged];

    [cell.SwitchButton addTarget:self
                          action:@selector(clickNotificationBtn:)
                forControlEvents:UIControlEventValueChanged];

  } break;

  case 1: {
    cell.TitleLabel.text = @"会话置顶";
    cell.SwitchButton.hidden = NO;
    cell.SwitchButton.on = currentConversation.isTop;
    [cell.SwitchButton addTarget:self
                          action:@selector(clickIsTopBtn:)
                forControlEvents:UIControlEventValueChanged];
  } break;

  case 2: {
    cell.TitleLabel.text = @"清除聊天记录";
    cell.SwitchButton.hidden = YES;
  } break;

  default:
    break;
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    if (indexPath.row == 2) {
      UIActionSheet *actionSheet =
          [[UIActionSheet alloc] initWithTitle:@"确定清除聊天记录？"
                                      delegate:self
                             cancelButtonTitle:@"取消"
                        destructiveButtonTitle:@"确定"
                             otherButtonTitles:nil];

      [actionSheet showInView:self.view];
      actionSheet.tag = 100;
    }
  }
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet.tag == 100) {
    if (buttonIndex == 0) {
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      RCDPrivateSettingsCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
      UIActivityIndicatorView *activityIndicatorView =
      [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      float cellWidth = cell.bounds.size.width;
      UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 50, 15, 40, 40)];
      [loadingView addSubview:activityIndicatorView];
      dispatch_async(dispatch_get_main_queue(), ^{
        [activityIndicatorView startAnimating];
        [cell addSubview:loadingView];
      });

      
      
      [[RCIMClient sharedRCIMClient]deleteMessages:ConversationType_PRIVATE targetId:_userId success:^{
        [self performSelectorOnMainThread:@selector(clearCacheAlertMessage:)
                               withObject:@"清除聊天记录成功！"
                            waitUntilDone:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ClearHistoryMsg" object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
          [loadingView removeFromSuperview];
        });
        
      } error:^(RCErrorCode status) {
        [self performSelectorOnMainThread:@selector(clearCacheAlertMessage:)
                               withObject:@"清除聊天记录失败！"
                            waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
          [loadingView removeFromSuperview];
        });
      }];
      

      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"ClearHistoryMsg"
                        object:nil];
    }
  }
}

- (void)clearCacheAlertMessage:(NSString *)msg {
  UIAlertView *alertView =
  [[UIAlertView alloc] initWithTitle:nil
                             message:msg
                            delegate:nil
                   cancelButtonTitle:@"确定"
                   otherButtonTitles:nil, nil];
  [alertView show];
}

#pragma mark - 本类的私有方法
- (void)startLoadView {
  currentConversation =
      [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE
                                            targetId:self.userId];
  [[RCIMClient sharedRCIMClient]
      getConversationNotificationStatus:ConversationType_PRIVATE
      targetId:self.userId
      success:^(RCConversationNotificationStatus nStatus) {
        enableNotification = NO;
        if (nStatus == NOTIFY) {
          enableNotification = YES;
        }
        [self.tableView reloadData];
      }
      error:^(RCErrorCode status){

      }];

  [self loadUserInfo:self.userId];
}

- (void)loadUserInfo:(NSString *)userId {
  if (![userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    self.userInfo = [[RCDataBaseManager shareInstance] getFriendInfo:userId];
  }
}

- (void)clickNotificationBtn:(id)sender {
  UISwitch *swch = sender;
  [[RCIMClient sharedRCIMClient]
      setConversationNotificationStatus:ConversationType_PRIVATE
      targetId:self.userId
      isBlocked:swch.on
      success:^(RCConversationNotificationStatus nStatus) {

      }
      error:^(RCErrorCode status){

      }];
}

- (void)clickIsTopBtn:(id)sender {
  UISwitch *swch = sender;
  [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_PRIVATE
                                             targetId:self.userId
                                                isTop:swch.on];
}


@end
