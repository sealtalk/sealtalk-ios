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

@interface RCDPrivateSettingsTableViewController ()

//开始会话
@property(strong, nonatomic) UIButton *btChat;

@end

@implementation RCDPrivateSettingsTableViewController {
  NSString *portraitUrl;
  NSString *nickname;
  BOOL enableNotification;
  RCConversation *currentConversation;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    heigh = 90.f;
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
  static NSString *InfoCellIdentifier = @"RCDPrivateSettingsUserInfoCell";
  RCDPrivateSettingsUserInfoCell *infoCell =
      (RCDPrivateSettingsUserInfoCell *)[tableView
          dequeueReusableCellWithIdentifier:InfoCellIdentifier];

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
    infoCell.PortraitImageView.layer.cornerRadius = 6.f;
    infoCell.PortraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    infoCell.NickNameLabel.text = nickname;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the
array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath
*)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath
*)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
                               withObject:@"缓存聊天记录成功！"
                            waitUntilDone:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ClearHistoryMsg" object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
          [loadingView removeFromSuperview];
        });
        
      } error:^(RCErrorCode status) {
        [self performSelectorOnMainThread:@selector(clearCacheAlertMessage:)
                               withObject:@"缓存聊天记录失败！"
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
  [self addFooterView];
}

- (void)loadUserInfo:(NSString *)userId {
  [RCDHTTPTOOL getUserInfoByUserID:userId
                        completion:^(RCUserInfo *user) {
                          portraitUrl = user.portraitUri;
                          nickname = user.name;
                          dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                          });

                        }];
}

- (void)addFooterView {
  /******************添加footerview*******************/
  UIView *view = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
  //发起会话按钮
  UIImage *imageChat = [UIImage imageNamed:@"group_add"];
  _btChat = [[UIButton alloc] init];
  [_btChat setTitle:@"发起会话" forState:UIControlStateNormal];
  [_btChat setBackgroundImage:imageChat forState:UIControlStateNormal];
  [_btChat setCenter:CGPointMake(view.bounds.size.width / 2,
                                 view.bounds.size.height / 2)];
  [_btChat addTarget:self
                action:@selector(buttonChatAction:)
      forControlEvents:UIControlEventTouchUpInside];
  [view addSubview:_btChat];

  [_btChat setHidden:NO];

  //自动布局
  [_btChat setTranslatesAutoresizingMaskIntoConstraints:NO];

  NSDictionary *views = NSDictionaryOfVariableBindings(_btChat);

  [view addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-10-[_btChat]"
                                               options:0
                                               metrics:nil
                                                 views:views]];

  [view addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:|-10-[_btChat]-10-|"
                                               options:0
                                               metrics:nil
                                                 views:views]];

  self.tableView.tableFooterView = view;
}

- (void)buttonChatAction:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
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
