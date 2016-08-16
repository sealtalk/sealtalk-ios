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
@property(strong, nonatomic) NSArray *defaultCellsTitle;
@property(strong, nonatomic) NSArray *defaultCellsPortrait;
@property (nonatomic, assign) BOOL hasSyncFriendList;
@property (nonatomic, assign) BOOL isBeginSearch;

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
  self.friendsTabelView.backgroundColor = HEXCOLOR(0xf0f0f6);
  self.friendsTabelView.separatorColor = HEXCOLOR(0xdfdfdf);
  
  self.friendsTabelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.friendsTabelView.bounds.size.width, 0.01f)];
  
  //设置右侧索引
  self.friendsTabelView.sectionIndexBackgroundColor = [UIColor clearColor];
  self.friendsTabelView.sectionIndexColor = HEXCOLOR(0x555555);
  
  if ([self.friendsTabelView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.friendsTabelView setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
  }
  if ([self.friendsTabelView respondsToSelector:@selector(setLayoutMargins:)]) {
    [self.friendsTabelView setLayoutMargins:UIEdgeInsetsMake(0, 14, 0, 0)];
  }

  UIImage* searchBarBg = [self GetImageWithColor:[UIColor clearColor] andHeight:32.0f];
  //设置顶部搜索栏的背景图片
  [self.searchFriendsBar setBackgroundImage:searchBarBg];
  //设置顶部搜索栏的背景色
  [self.searchFriendsBar setBackgroundColor:HEXCOLOR(0xf0f0f6)];
  
  //设置顶部搜索栏输入框的样式
  UITextField *searchField = [self.searchFriendsBar valueForKey:@"_searchField"];
  searchField.layer.borderWidth = 0.5f;
  searchField.layer.borderColor = [HEXCOLOR(0xdfdfdf) CGColor];
  searchField.layer.cornerRadius = 5.f;
  self.searchFriendsBar.placeholder = @"搜索";

  self.defaultCellsTitle = [NSArray
      arrayWithObjects:@"新朋友", @"群组", @"公众号", @"我", nil];
  self.defaultCellsPortrait = [NSArray
      arrayWithObjects:@"newFriend", @"defaultGroup", @"publicNumber",@"contact_me", nil];
  
  self.isBeginSearch = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.searchFriendsBar resignFirstResponder];
  [self sortAndRefreshWithList:[self getAllFriendList]];
  UIButton *rightBtn =
      [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 20)];
  [rightBtn setImage:[UIImage imageNamed:@"add_friend"] forState:UIControlStateNormal];
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

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (_isBeginSearch == YES) {
    [self sortAndRefreshWithList:[self getAllFriendList]];
    _isBeginSearch = NO;
    self.searchFriendsBar.showsCancelButton = NO;
    [self.searchFriendsBar resignFirstResponder];
    self.searchFriendsBar.text = @"";
    [self.matchFriendList removeAllObjects];
    [self.friendsTabelView setContentOffset:CGPointMake(0,0) animated:NO];
  }
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
    if (_isBeginSearch == YES) {
      rows = 0;
    }
    else
    {
      rows = 4;
    }
  } else {
    NSString *letter = [self getFriendClassifiedLetterList][section -1];
    rows = [self.allFriendSectionDic[letter] count];
  }
  return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.allFriendSectionDic count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return 0;
  }
  return 21.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  view.frame = CGRectMake(0, 0, self.view.frame.size.width, 22);
  view.backgroundColor = [UIColor clearColor];
  
  UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
  title.frame = CGRectMake(13, 3, 15, 15);
  title.font = [UIFont systemFontOfSize:15.f];
  title.textColor = HEXCOLOR(0x999999);
  
  [view addSubview:title];
  
  if (section == 0) {
    title.text = nil;
  } else {
    title.text = [self getFriendClassifiedLetterList][section -1];
  }
  
  return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
  static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
  RCDContactTableViewCell *cell = [self.friendsTabelView
      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (cell == nil) {
      cell = [[RCDContactTableViewCell alloc] init];
  }

  if (indexPath.section == 0) {
    cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
    if (indexPath.row == 3) {
      if ([isDisplayID isEqualToString:@"YES"]) {
        cell.userIdLabel.text = [RCIM sharedRCIM].currentUserInfo.userId;
      }
    }

      [cell.portraitView
          setImage:[UIImage
                       imageNamed:[NSString
                                      stringWithFormat:
                                          @"%@",
                                          [_defaultCellsPortrait
                                              objectAtIndex:indexPath.row]]]];
  } else {
    NSString *letter = [self getFriendClassifiedLetterList][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];

    RCDUserInfo *userInfo = sectionUserInfoList[indexPath.row];
    if (userInfo) {
      if ([isDisplayID isEqualToString:@"YES"]) {
        cell.userIdLabel.text = userInfo.userId;
      }
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
    cell.portraitView.layer.cornerRadius = 5.f;
  }
  //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
  cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 55.5;
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
    NSString *letter = [self getFriendClassifiedLetterList][indexPath.section -1];
    NSArray *sectionUserInfoList = self.allFriendSectionDic[letter];
    user = sectionUserInfoList[indexPath.row];
    if ([user.status intValue] == 10) {
      return;
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
  _isBeginSearch = NO;
  [self.friendsTabelView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  if (_isBeginSearch == NO) {
    _isBeginSearch = YES;
    [self.friendsTabelView reloadData];
  }
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


- (UIImage*) GetImageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
  CGRect r= CGRectMake(0.0f, 0.0f, 1.0f, height);
  UIGraphicsBeginImageContext(r.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, r);
  
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return img;
}

@end
