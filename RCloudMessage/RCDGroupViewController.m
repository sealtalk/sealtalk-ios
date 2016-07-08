//
//  SecondViewController.m
//  RongCloud
//
//  Created by Liv on 14/10/31.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDGroupViewController.h"
#import "AFHttpTool.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RedpacketDemoViewController.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDGroupSettingsTableViewController.h"
#import "RCDGroupTableViewCell.h"
#import "RCDHttpTool.h"
#import "RCDLoginInfo.h"
#import "RCDRCIMDataSource.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDGroupViewController () <
    UITableViewDataSource, UITableViewDelegate, JoinQuitGroupDelegate>

@property(nonatomic, strong) NSMutableArray *groups;
//@property(nonatomic, strong) UILabel *noGroup;

@end

@implementation RCDGroupViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    //设置为不用默认渲染方式
    self.tabBarItem.image = [[UIImage imageNamed:@"icon_group"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_group_hover"]
        imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  //设置tableView样式
  self.tableView.separatorColor =
      [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
  self.tableView.tableFooterView = [UIView new];
  // self.tableView.tableHeaderView = [[UIView alloc]
  // initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
  // 12)];

  __weak RCDGroupViewController *weakSelf = self;

  _groups = [NSMutableArray
      arrayWithArray:[[RCDataBaseManager shareInstance] getAllGroup]];
  if ([_groups count] > 0) {
    [weakSelf.tableView reloadData];
  }

  [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
          NSMutableArray *tempGroups = [NSMutableArray
                                       arrayWithArray:[[RCDataBaseManager shareInstance] getAllGroup]];
          dispatch_async(dispatch_get_main_queue(), ^{
            _groups = tempGroups;
            [weakSelf.tableView reloadData];
          });
        });
  }];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  UILabel *titleView = [[UILabel alloc]
      initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
  titleView.backgroundColor = [UIColor clearColor];
  titleView.font = [UIFont boldSystemFontOfSize:19];
  titleView.textColor = [UIColor whiteColor];
  titleView.textAlignment = NSTextAlignmentCenter;
  titleView.text = @"群组";
  self.tabBarController.navigationItem.titleView = titleView;

  self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

  return _groups.count;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDGroupInfo *groupInfo = _groups[indexPath.row];
  RedpacketDemoViewController *temp = [[RedpacketDemoViewController alloc] init];
  temp.targetId = groupInfo.groupId;
  temp.conversationType = ConversationType_GROUP;
  temp.userName = groupInfo.groupName;
  temp.title = groupInfo.groupName;
  [self.navigationController pushViewController:temp animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  //    UIViewController *destination = segue.destinationViewController;
  //
  //    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
  //
  //    RCDGroupInfo *groupInfo=[_groups objectAtIndex:indexPath.row];
  //
  //    [destination setValue:groupInfo forKey:@"groupInfo"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"RCDGroupCell";
  RCDGroupTableViewCell *cell = (RCDGroupTableViewCell *)[tableView
      dequeueReusableCellWithIdentifier:CellIdentifier];
  cell.btJoin.hidden = YES;

  RCDGroupInfo *group = _groups[indexPath.row];
  cell.lblGroupName.text = group.groupName;
  cell.groupID = group.groupId;
  //    cell.lblInstru.text = @"群组介绍";
  if ([RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE) {
    cell.imvGroupPort.layer.masksToBounds = YES;
    cell.imvGroupPort.layer.cornerRadius = 28.f;
  } else {
    cell.imvGroupPort.layer.masksToBounds = YES;
    cell.imvGroupPort.layer.cornerRadius = 6.f;
  }

  if ([group.portraitUri isEqualToString:@""]) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:group.groupId Nickname:group.groupName];
    UIImage *portrait = [defaultPortrait imageFromView];
    cell.imvGroupPort.image = portrait;
  } else {
    [cell.imvGroupPort
        sd_setImageWithURL:[NSURL URLWithString:group.portraitUri]
          placeholderImage:[UIImage imageNamed:@"icon_person"]];
  }

  cell.delegate = self;
  cell.isJoin = group.isJoin;
  if ([[NSString stringWithFormat:@"%@", group.number] isEqualToString:@""]) {
    cell.lblPersonNumber.text = @"";
  } else {
    cell.lblPersonNumber.text =
        [NSString stringWithFormat:@"%@/%@", group.number, group.maxNumber];
  }
  cell.imvGroupPort.contentMode = UIViewContentModeScaleAspectFill;
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  return cell;
}

- (void)joinGroupCallback:(BOOL)result withGroupId:(NSString *)groupId {
  if (result) {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"加入成功！"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
    [alertView show];
  } else {
    NSString *msg = @"加入失败";
    for (RCDGroupInfo *group in _groups) {
      if ([group.groupId isEqualToString:groupId]) {
        if (group.number == group.maxNumber)
          msg = @"群组人数已满";
      }
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
  }
  [RCDDataSource syncGroups];
  __weak RCDGroupViewController *weakSelf = self;
  [RCDHTTPTOOL getAllGroupsWithCompletion:^(NSMutableArray *result) {
    dispatch_async(dispatch_get_main_queue(), ^{
      _groups = result;
      [weakSelf.tableView reloadData];
    });
  }];
}

- (void)launchGroupChatPageByGroupId:(NSString *)groupId {
  RCDGroupInfo *groupInfo;
  for (RCDGroupInfo *group in _groups) {
    if ([group.groupId isEqualToString:groupId]) {
      groupInfo = group;
    }
  }
  if (groupInfo) {
    RedpacketDemoViewController *temp = [[RedpacketDemoViewController alloc] init];
    temp.targetId = groupInfo.groupId;
    temp.conversationType = ConversationType_GROUP;
    temp.userName = groupInfo.groupName;
    temp.title = groupInfo.groupName;
    [self.navigationController pushViewController:temp animated:YES];
  }
}

- (void)quitGroupCallback:(BOOL)result withGroupId:(NSString *)groupId {
  if (result) {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"退出成功！"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
    [alertView show];

  } else {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"加入失败！"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
    [alertView show];
  }
  [RCDDataSource syncGroups];
}

//-(void)setNoGroupLabel:(NSArray *)groups
//{
//    if ([groups count] == 0) {
//        _noGroup = [[UILabel alloc] init];
//        _noGroup.frame = CGRectMake((self.view.frame.size.width / 2) - 50,
//        (self.view.frame.size.height / 2) - 15 -
//        self.navigationController.navigationBar.frame.size.height, 100, 30);
//        [_noGroup setText:@"暂无群组"];
//        [_noGroup setTextColor:[UIColor grayColor]];
//        _noGroup.textAlignment = UITextAlignmentCenter;
//        [self.view addSubview:_noGroup];
//        _noGroup.hidden = NO;
//        return;
//    }
//}
@end
