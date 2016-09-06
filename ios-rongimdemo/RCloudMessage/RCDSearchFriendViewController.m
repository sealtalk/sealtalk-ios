//
//  RCDSearchFriendTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/12.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSearchFriendViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDAddFriendViewController.h"
#import "RCDAddressBookTableViewCell.h"
#import "RCDHttpTool.h"
#import "RCDMeInfoTableViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSearchResultTableViewCell.h"
#import "RCDUserInfo.h"
#import "UIImageView+WebCache.h"
#import "RCDUserInfoManager.h"

@interface RCDSearchFriendViewController () <
    UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
    UISearchControllerDelegate>

@property(strong, nonatomic) NSMutableArray *searchResult;

@end

@implementation RCDSearchFriendViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = @"添加好友";
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

  // initial data
  _searchResult = [[NSMutableArray alloc] init];

  [self setExtraCellLineHidden:self.searchDisplayController
                                   .searchResultsTableView];
}

+ (instancetype)searchFriendViewController {
  UIStoryboard *mainStoryboard =
      [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  RCDSearchFriendViewController *searchController = [mainStoryboard
      instantiateViewControllerWithIdentifier:@"RCDSearchFriendViewController"];
  return searchController;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - searchResultDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.searchDisplayController.searchResultsTableView)
    return _searchResult.count;
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.searchDisplayController.searchResultsTableView)
    return 80.f;
  return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *reusableCellWithIdentifier = @"RCDSearchResultTableViewCell";
  RCDSearchResultTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (tableView == self.searchDisplayController.searchResultsTableView) {

    cell = [[RCDSearchResultTableViewCell alloc]
          initWithStyle:UITableViewCellStyleDefault
        reuseIdentifier:reusableCellWithIdentifier];
    RCDUserInfo *user = _searchResult[indexPath.row];
    if (user) {
      cell.lblName.text = user.name;
      if ([user.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
            initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.ivAva.image = portrait;
      } else {
        [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
      }
    }
  }

  cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

#pragma mark - searchResultDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RCDUserInfo *user = _searchResult[indexPath.row];
  RCUserInfo *userInfo = [RCUserInfo new];
  userInfo.userId = user.userId;
  userInfo.name = user.name;
  userInfo.portraitUri = user.portraitUri;

  if ([userInfo.userId
          isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    //        UIStoryboard *mainStoryboard = [UIStoryboard
    //        storyboardWithName:@"Main" bundle:nil];
    //        RCDMeInfoTableViewController *meInfoViewController =
    //        [mainStoryboard
    //        instantiateViewControllerWithIdentifier:@"RCDMeInfoTableViewController"];
    //        [self.navigationController pushViewController:meInfoViewController
    //        animated:YES];
    //        return;
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"你不能添加自己到通讯录"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
  } else if (user &&
             tableView == self.searchDisplayController.searchResultsTableView) {
    UIStoryboard *mainStoryboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RCDAddFriendViewController *addViewController = [mainStoryboard
        instantiateViewControllerWithIdentifier:@"RCDAddFriendViewController"];
    addViewController.targetUserInfo = userInfo;
    [self.navigationController pushViewController:addViewController
                                         animated:YES];
  }
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
  [_searchResult removeAllObjects];
  if ([searchText length] == 11) {
    [RCDHTTPTOOL searchUserByPhone:searchText
                          complete:^(NSMutableArray *result) {
                            if (result) {
                              for (RCDUserInfo *user in result) {
                                if ([user.userId
                                     isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                                  [[RCDUserInfoManager shareInstance] getUserInfo:user.userId
                                                                       completion:^(RCUserInfo *user) {
                                                                         [_searchResult addObject:user];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self.searchDisplayController
                                                                            .searchResultsTableView reloadData];
                                                                         });
                                                                       }];
                                } else {
                                [[RCDUserInfoManager shareInstance] getFriendInfo:user.userId
                                                                       completion:^(RCUserInfo *user) {
                                                                         [_searchResult addObject:user];
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self.searchDisplayController
                                                                            .searchResultsTableView reloadData];
                                                                         });
                                                                       }];
                                }
                               
                              }
                            }
                          }];
  }
}

//清除多余分割线
- (void)setExtraCellLineHidden:(UITableView *)tableView {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  [tableView setTableFooterView:view];
}

@end
