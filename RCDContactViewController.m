//
//  RCDContactViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "DefaultPortraitView.h"
#import "RCDAddressBookTableViewCell.h"
#import "RCDAddressBookViewController.h"
#import "RCDContactTableViewCell.h"
#import "RCDContactViewController.h"
#import "RCDGroupViewController.h"
#import "RCDHttpTool.h"
#import "RCDPersonDetailViewController.h"
#import "RCDPublicServiceListViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSearchFriendViewController.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"

@interface RCDContactViewController ()
@property(strong, nonatomic) NSMutableArray *matchFriendList;
@property(nonatomic, strong) NSDictionary *allFriendSectionDic;
@property(strong, nonatomic) NSArray *defaultCellsTitle;
@property(strong, nonatomic) NSArray *defaultCellsPortrait;
@property (nonatomic, assign) BOOL hasSyncFriendList;

@end

@implementation RCDContactViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.tabBarItem.image = [[UIImage imageNamed:@"contact_icon"]
      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_icon_hover"]
      imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

  // initial data
  self.matchFriendList = [[NSMutableArray alloc] init];
  self.allFriendSectionDic = [[NSDictionary alloc] init];
  
  self.friendsTabelView.tableFooterView = [UIView new];
  float colorFloat = 249.f / 255.f;
  self.friendsTabelView.backgroundColor =
      [[UIColor alloc] initWithRed:colorFloat
                             green:colorFloat
                              blue:colorFloat
                             alpha:1];

  self.defaultCellsTitle = [NSArray
      arrayWithObjects:@"新朋友", @"群组", @"公众号", @"我", nil];
  self.defaultCellsPortrait = [NSArray
      arrayWithObjects:@"newFriend", @"defaultGroup", @"publicNumber", nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.searchFriendsBar resignFirstResponder];
  if ([self.matchFriendList count] > 0) {
    return;
  } else {
    [self sortAndRefreshWithList:[self getAllFriendList]];
  }
  UIButton *rightBtn =
      [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
  [rightBtn setImage:[UIImage imageNamed:@"add_friend"]
            forState:UIControlStateNormal];
  [rightBtn addTarget:self
                action:@selector(pushAddFriend:)
      forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *rightButton =
      [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
  [rightBtn setTintColor:[UIColor whiteColor]];
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                           target:nil
                           action:nil];
  negativeSpacer.width = -6;
  self.tabBarController.navigationItem.rightBarButtonItems =
      [NSArray arrayWithObjects:negativeSpacer, rightButton, nil];
  self.tabBarController.navigationItem.title = @"通讯录";
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  NSInteger rows = 0;
  if (section == 0) {
    rows = 4;
  } else {
    NSString *letter = [self getFriendClassifiedLetterList][section -1];
    rows = [self.allFriendSectionDic[letter] count];
  }
  return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.allFriendSectionDic count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  NSString *title;
  if (section == 0) {
    title = @"";
  } else {
   title = [self getFriendClassifiedLetterList][section -1];
  }
  return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
  RCDContactTableViewCell *cell = [self.friendsTabelView
      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (cell == nil) {
    cell = [[RCDContactTableViewCell alloc] init];
  }

  if (indexPath.section == 0) {
    cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
    if (indexPath.row != 3) {
      [cell.portraitView
          setImage:[UIImage
                       imageNamed:[NSString
                                      stringWithFormat:
                                          @"%@",
                                          [_defaultCellsPortrait
                                              objectAtIndex:indexPath.row]]]];
    } else {
      [cell.portraitView
          sd_setImageWithURL:
              [NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]]
            placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
  } else {
    NSString *letter = [self getFriendClassifiedLetterList][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];

    RCDUserInfo *userInfo = sectionUserInfoList[indexPath.row];
    if (userInfo) {
      cell.nicknameLabel.text = userInfo.name;
      if ([userInfo.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
            initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.portraitView.image = portrait;
      } else {
        [cell.portraitView
            sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
              placeholderImage:[UIImage imageNamed:@"contact"]];
      }
    }
  }
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    cell.portraitView.layer.masksToBounds = YES;
    cell.portraitView.layer.cornerRadius = 20.f;
  } else {
    cell.portraitView.layer.masksToBounds = YES;
    cell.portraitView.layer.cornerRadius = 6.f;
  }
  //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
  cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 70.0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return [self getFriendClassifiedLetterList];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  RCDUserInfo *user = nil;
  if (indexPath.section == 0) {
    switch (indexPath.row) {
    case 0: {
      UIStoryboard *mainStoryboard =
          [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      RCDAddressBookViewController *addressBookVC =
          [mainStoryboard instantiateViewControllerWithIdentifier:
                              @"RCDAddressBookViewController"];
      [self.navigationController pushViewController:addressBookVC animated:YES];
      return;
    } break;

    case 1: {
      UIStoryboard *mainStoryboard =
          [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      RCDGroupViewController *addressBookVC = [mainStoryboard
          instantiateViewControllerWithIdentifier:@"RCDGroupViewController"];
      [self.navigationController pushViewController:addressBookVC animated:YES];
      return;

    } break;

    case 2: {
      RCDPublicServiceListViewController *publicServiceVC =
          [[RCDPublicServiceListViewController alloc] init];
      [self.navigationController pushViewController:publicServiceVC
                                           animated:YES];
      return;

    } break;

    case 3: {
      UIStoryboard *storyboard =
          [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      RCDPersonDetailViewController *detailViewController =
          [storyboard instantiateViewControllerWithIdentifier:
                          @"RCDPersonDetailViewController"];

      [self.navigationController pushViewController:detailViewController
                                           animated:YES];
      detailViewController.userInfo = [RCIM sharedRCIM].currentUserInfo;
      return;
    }

    default:
      break;
    }
  }
  if ([self.matchFriendList count] > 0) {
    user = self.matchFriendList[indexPath.row];
  } else {
    NSString *letter = [self getFriendClassifiedLetterList][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
    user = sectionUserInfoList[indexPath.row];
    if ([user.status intValue] == 10) {
      return;
    }
  }
  if (user == nil) {
    return;
  }
  RCUserInfo *userInfo = [RCUserInfo new];
  userInfo.userId = user.userId;
  userInfo.portraitUri = user.portraitUri;
  userInfo.name = user.name;

  UIStoryboard *storyboard =
      [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  RCDPersonDetailViewController *detailViewController = [storyboard
      instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];

  [self.navigationController pushViewController:detailViewController
                                       animated:YES];
  detailViewController.userInfo = userInfo;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.searchFriendsBar resignFirstResponder];
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
  [self.matchFriendList removeAllObjects];
  if (searchText.length <= 0) {
    [self sortAndRefreshWithList:[self getAllFriendList]];
  } else {
    for (RCDUserInfo *userInfo in [self getAllFriendList]) {
      //忽略大小写去判断是否包含
      if ([userInfo.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound
          || [[self hanZiToPinYinWithString:userInfo.name] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [self.matchFriendList addObject:userInfo];
      }
    }
    [self sortAndRefreshWithList:self.matchFriendList];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  self.searchFriendsBar.showsCancelButton = NO;
  [self.searchFriendsBar resignFirstResponder];
  self.searchFriendsBar.text = @"";
  [self.matchFriendList removeAllObjects];
  [self sortAndRefreshWithList:[self getAllFriendList]];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  self.searchFriendsBar.showsCancelButton = YES;
  return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

#pragma mark - 获取好友并且排序

- (NSArray *)getAllFriendList {
  NSMutableArray *friendList = [[NSMutableArray alloc] init];
  NSMutableArray *userInfoList = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
  for (RCDUserInfo *user in userInfoList) {
    if ([user.status isEqualToString:@"20"]) {
      [friendList addObject:user];
    }
  }
  
  if (friendList.count <= 0 && !self.hasSyncFriendList) {
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                           self.hasSyncFriendList = YES;
                           [self sortAndRefreshWithList:[self getAllFriendList]];
                         }];
  }
  
  return [friendList copy];
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSDictionary *sortFriendDic = [self getFriendClassifiedDic:friendList];
    dispatch_async(dispatch_get_main_queue(), ^{
      self.allFriendSectionDic = sortFriendDic;
      [self.friendsTabelView reloadData];
    });
  });
}

#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
- (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
  if (!hanZi) {
    return nil;
  }
  NSString *pinYinResult = [NSString string];
  for (int j = 0; j < hanZi.length; j++) {
    NSString *singlePinyinLetter = [[NSString
        stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
        uppercaseString];
    pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
  }
  return pinYinResult;
}

- (NSString *)getFirstUpperLetter:(NSString *)hanzi {
  NSString *pinyin = [self hanZiToPinYinWithString:hanzi];
  NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
  if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
      [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
    return firstUpperLetter;
  } else {
    return @"#";
  }
}

- (NSDictionary *)getFriendClassifiedDic:(NSArray *)allFriends {
  if (!allFriends) {
    return nil;
  }
  
  NSMutableDictionary *friendClassifiedDic = [[NSMutableDictionary alloc] init];
  for (RCDUserInfo *userInfo in allFriends) {
    NSString *firstLetter = [self getFirstUpperLetter:userInfo.name];
    if (!friendClassifiedDic[firstLetter]) {
      [friendClassifiedDic setObject:[[NSMutableArray alloc] init] forKey:firstLetter];
    }
    [friendClassifiedDic[firstLetter] addObject:userInfo];
  }
  
  for (NSMutableArray *oneList in [friendClassifiedDic allValues]) {
    [oneList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
      RCDUserInfo *userInfo1 = (RCDUserInfo *)obj1;
      RCDUserInfo *userInfo2 = (RCDUserInfo *)obj2;
      return [[self getFirstUpperLetter:userInfo1.name]
              compare:[self getFirstUpperLetter:userInfo2.name]];
    }];
  }
  return [friendClassifiedDic copy];
}

- (NSArray *)getFriendClassifiedLetterList {
  NSArray *classifiedLetter = [self.allFriendSectionDic allKeys];
  return [classifiedLetter sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    NSString *letter1 = (NSString *)obj1;
    NSString *letter2 = (NSString *)obj2;
    return [letter1 compare:letter2];
  }];
}

/**
 *  添加好友
 *
 *  @param sender sender description
 */
- (void)pushAddFriend:(id)sender {
  RCDSearchFriendViewController *searchFirendVC =
  [RCDSearchFriendViewController searchFriendViewController];
  [self.navigationController pushViewController:searchFirendVC animated:YES];
}

@end
