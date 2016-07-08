//
//  RCDAddressBookViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDAddressBookViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDAddressBookTableViewCell.h"
#import "RedpacketDemoViewController.h"
#import "RCDHttpTool.h"
#import "RCDPersonDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "pinyin.h"
#import <RongIMLib/RongIMLib.h>
#include <ctype.h>

@interface RCDAddressBookViewController ()

//#字符索引对应的user object
@property(nonatomic, strong) NSMutableArray *tempOtherArr;
@property(nonatomic, strong) NSMutableArray *friends;
@property(nonatomic, strong) NSArray *arrayForKey;
@property(nonatomic, strong) NSMutableDictionary *friendsDic;
//@property (nonatomic,strong) UILabel *noFriend;

@end

@implementation RCDAddressBookViewController {
  NSInteger tag;
  BOOL isSyncFriends;
}
MBProgressHUD *hud;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  self.navigationItem.title = @"新朋友";

  self.tableView.tableFooterView = [UIView new];

  _friendsDic = [[NSMutableDictionary alloc] init];

  tag = 0;
  isSyncFriends = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _needSyncFriendList = YES;
  [self getAllData];
}

//删除已选中用户
- (void)removeSelectedUsers:(NSArray *)selectedUsers {
  for (RCUserInfo *user in selectedUsers) {

    [_friends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      RCDUserInfo *userInfo = obj;
      if ([user.userId isEqualToString:userInfo.userId]) {
        [_friends removeObject:obj];
      }
    }];
  }
}

/**
 *  initial data
 */
- (void)getAllData {
  //    _keys =
  //    @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
  //    _allFriends = [NSMutableDictionary new];
  //    _allKeys = [NSMutableArray new];
  _friends = [NSMutableArray
      arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
  if ([_friends count] > 0) {
    //        _noFriend.hidden = YES;
    self.hideSectionHeader = YES;
    //        _allFriends = [self sortedArrayWithPinYinDic:_friends];
    _friends = [self sortForFreindList:_friends];
    tag = 0;
    [self.tableView reloadData];
  }
  if (isSyncFriends == NO) {
    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId
                         complete:^(NSMutableArray *result) {
                           isSyncFriends = YES;
                           [self getAllData];
                         }];
  }
  //    if ([_friends count] == 0) {
  //        _noFriend = [[UILabel alloc] init];
  //        _noFriend.frame = CGRectMake((self.view.frame.size.width / 2) - 50,
  //        (self.view.frame.size.height / 2) - 15 -
  //        self.navigationController.navigationBar.frame.size.height, 100, 30);
  //        [_noFriend setText:@"暂无好友"];
  //        [_noFriend setTextColor:[UIColor grayColor]];
  //        _noFriend.textAlignment = UITextAlignmentCenter;
  //        _noFriend.hidden = NO;
  //        [self.view addSubview:_noFriend];
  ////        return;
  //    }
  //    if (_needSyncFriendList == YES) {
  ////        _noFriend.hidden = YES;
  //        [RCDDataSource syncFriendList:[RCIM
  //        sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray *
  //        result) {
  //            if (result.count == 0) {
  //                if (_friends.count < 20) {
  //                    self.hideSectionHeader = YES;
  //                }
  //
  //                dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //                    dispatch_async(dispatch_get_main_queue(), ^{
  //                        _allFriends = [self
  //                        sortedArrayWithPinYinDic:_friends];
  //                        tag = 0;
  //                        [self.tableView reloadData];
  //
  //                    });
  //                });
  //            }
  //            _friends=result;
  //            if (_friends.count < 20) {
  //                self.hideSectionHeader = YES;
  //            }
  //            dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //                dispatch_async(dispatch_get_main_queue(), ^{
  //                    _allFriends = [self sortedArrayWithPinYinDic:_friends];
  //                    tag = 0;
  //                    [self.tableView reloadData];
  //                });
  //            });
  //
  //        }];
  //    }
  //    else if (_friends==nil||_friends.count<1) {
  ////        _noFriend.hidden = YES;
  //        [RCDDataSource syncFriendList:[RCIM
  //        sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray *
  //        result) {
  //            _friends=result;
  //            if (_friends.count < 20) {
  //                self.hideSectionHeader = YES;
  //            }
  //            dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //                dispatch_async(dispatch_get_main_queue(), ^{
  //                     _allFriends = [self sortedArrayWithPinYinDic:_friends];
  //                    _friendsDic = [[NSMutableDictionary alloc] init];
  //                    tag = 0;
  //                    [self.tableView reloadData];
  //
  //                });
  //            });
  //
  //        }];
  //    }
  //    else
  //    {
  ////        _noFriend.hidden = YES;
  //        if (_friends.count < 20) {
  //            self.hideSectionHeader = YES;
  //        }
  //
  //        dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //
  ////            _allFriends = [self sortedArrayWithPinYinDic:_friends];
  //            dispatch_async(dispatch_get_main_queue(), ^{
  //                tag = 0;
  //                [self.tableView reloadData];
  //
  //            });
  //        });
  //    }
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *reusableCellWithIdentifier = @"RCDAddressBookCell";
  RCDAddressBookTableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  cell.tag = tag + 5000;
  cell.acceptBtn.tag = tag + 10000;
  tag++;
  //    NSString *key = [_allKeys objectAtIndex:indexPath.section];
  //    _arrayForKey = [_allFriends objectForKey:key];

  RCDUserInfo *user = _friends[indexPath.row];
  [_friendsDic setObject:user
                  forKey:[NSString stringWithFormat:@"%ld", (long)cell.tag]];
  if (user) {
    cell.lblName.text = user.name;
    if ([user.portraitUri isEqualToString:@""]) {
      DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
          initWithFrame:CGRectMake(0, 0, 100, 100)];
      [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
      UIImage *portrait = [defaultPortrait imageFromView];
      cell.imgvAva.image = portrait;
    } else {
      [cell.imgvAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"contact"]];
    }
  }
  if ([user.status intValue] == 20) {
    cell.rightLabel.text = @"已接受";
    cell.acceptBtn.hidden = YES;
    cell.arrow.hidden = NO;
  }
  if ([user.status intValue] == 10) {
    cell.rightLabel.text = @"已邀请";
    cell.selected = NO;
    cell.arrow.hidden = YES;
    cell.acceptBtn.hidden = YES;
  }
  if ([user.status intValue] == 11) {
    cell.selected = NO;
    cell.acceptBtn.hidden = NO;
    [cell.acceptBtn addTarget:self
                       action:@selector(doAccept:)
             forControlEvents:UIControlEventTouchUpInside];
    cell.arrow.hidden = YES;
  }
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    cell.imgvAva.layer.masksToBounds = YES;
    cell.imgvAva.layer.cornerRadius = 18.f;
  } else {
    cell.imgvAva.layer.masksToBounds = YES;
    cell.imgvAva.layer.cornerRadius = 6.f;
  }
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.imgvAva.contentMode = UIViewContentModeScaleAspectFill;
  return cell;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  //    NSString *key = [_allKeys objectAtIndex:section];
  //
  //    NSArray *arr = [_allFriends objectForKey:key];

  return [_friends count];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//
//
//    return [_allKeys count];
//
//}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 65.f;
}

////pinyin index
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//
//    if (self.hideSectionHeader) {
//        return nil;
//    }
//    return _allKeys;
//
//}

//- (NSString *)tableView:(UITableView *)tableView
//titleForHeaderInSection:(NSInteger)section{
//    if (self.hideSectionHeader) {
//        return nil;
//    }
//
//    NSString *key = [_allKeys objectAtIndex:section];
//    return key;
//
//}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  //    NSIndexPath *indexPath = [self.tableView indexPath.];
  //    NSString *key = [_allKeys objectAtIndex:indexPath.section];
  //    NSArray *arrayForKey = [_allFriends objectForKey:key];
  RCDUserInfo *user = _friends[indexPath.row];
  if ([user.status intValue] == 10 || [user.status intValue] == 11) {
    return;
  }
  RCUserInfo *userInfo = [RCUserInfo new];
  userInfo.userId = user.userId;
  userInfo.portraitUri = user.portraitUri;
  userInfo.name = user.name;
  //
  //    UIStoryboard *storyboard =
  //                    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  //    RCDPersonDetailViewController *detailViewController = [storyboard
  //    instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];

  RedpacketDemoViewController *chatViewController =
      [[RedpacketDemoViewController alloc] init];
  chatViewController.conversationType = ConversationType_PRIVATE;
  chatViewController.targetId = userInfo.userId;
  chatViewController.title = userInfo.name;
  [self.navigationController pushViewController:chatViewController
                                       animated:YES];

  //    [self.navigationController pushViewController:detailViewController
  //    animated:YES];
  //    detailViewController.userInfo = userInfo;
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
  if (!hanZi)
    return nil;
  NSString *pinYinResult = [NSString string];
  for (int j = 0; j < hanZi.length; j++) {
    NSString *singlePinyinLetter = [[NSString
        stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
        uppercaseString];
    pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
  }

  return pinYinResult;
}

///**
// *  根据转换拼音后的字典排序
// *
// *  @param pinyinDic 转换后的字典
// *
// *  @return 对应排序的字典
// */
//-(NSMutableDictionary *) sortedArrayWithPinYinDic:(NSArray *) friends
//{
//    if(!friends) return nil;
//
//    NSMutableDictionary *returnDic = [NSMutableDictionary new];
//    _tempOtherArr = [NSMutableArray new];
//    BOOL isReturn = NO;
//
//    for (NSString *key in _keys) {
//
//        if ([_tempOtherArr count]) {
//            isReturn = YES;
//        }
//
//        NSMutableArray *tempArr = [NSMutableArray new];
//        for (RCDUserInfo *user in friends) {
//
//            NSString *pyResult = [self hanZiToPinYinWithString:user.name];
//            NSString *firstLetter = [pyResult substringToIndex:1];
//            if ([firstLetter isEqualToString:key]){
//                [tempArr addObject:user];
//            }
//
//            if(isReturn) continue;
//            char c = [pyResult characterAtIndex:0];
//            if (isalpha(c) == 0) {
//                [_tempOtherArr addObject:user];
//            }
//        }
//        if(![tempArr count]) continue;
//        [returnDic setObject:tempArr forKey:key];
//
//    }
//    if([_tempOtherArr count])
//        [returnDic setObject:_tempOtherArr forKey:@"#"];
//
//
//    _allKeys = [[returnDic allKeys]
//    sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//
//        return [obj1 compare:obj2 options:NSNumericSearch];
//    }];
//
//    return returnDic;
//}

- (void)doAccept:(UIButton *)sender {
  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.labelText = @"添加好友中...";
  [hud show:YES];
  NSInteger tempTag = sender.tag;
  tempTag -= 5000;
  RCDAddressBookTableViewCell *cell =
      (RCDAddressBookTableViewCell *)[self.view viewWithTag:tempTag];

  RCDUserInfo *friend = [_friendsDic
      objectForKey:[NSString stringWithFormat:@"%ld", (long)tempTag]];

  [RCDHTTPTOOL
      processInviteFriendRequest:friend.userId
                        complete:^(BOOL request) {
                          if (request) {
                            [RCDHTTPTOOL
                                getFriends:[RCIM sharedRCIM]
                                               .currentUserInfo.userId
                                  complete:^(NSMutableArray *result) {

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      cell.acceptBtn.hidden = YES;
                                      cell.arrow.hidden = NO;
                                      cell.rightLabel.hidden = NO;
                                      cell.rightLabel.text = @"已接受";
                                      cell.selected = YES;
                                      [hud hide:YES];
                                    });
                                  }];
                            [RCDHTTPTOOL getFriends:[RCIM sharedRCIM]
                                                        .currentUserInfo.userId
                                           complete:^(NSMutableArray *result){

                                           }];
                          } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                              [hud hide:YES];
                              UIAlertView *failAlert = [[UIAlertView alloc]
                                      initWithTitle:@"添加失败"
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles:nil, nil];
                              [failAlert show];
                            });
                          }
                        }];
}

- (NSMutableArray *)sortForFreindList:(NSMutableArray *)friendList {
  NSMutableDictionary *tempFrinedsDic = [NSMutableDictionary new];
  NSMutableArray *updatedAtList = [NSMutableArray new];
  for (RCDUserInfo *friend in _friends) {
    NSString *key = friend.updatedAt;
    [tempFrinedsDic setObject:friend forKey:key];
    [updatedAtList addObject:key];
  }
  updatedAtList = [self sortForUpdateAt:updatedAtList];
  NSMutableArray *result = [NSMutableArray new];
  for (NSString *key in updatedAtList) {
    for (NSString *k in [tempFrinedsDic allKeys]) {
      if ([key isEqualToString:k]) {
        [result addObject:[tempFrinedsDic objectForKey:k]];
      }
    }
  }
  return result;
}

- (NSMutableArray *)sortForUpdateAt:(NSMutableArray *)updatedAtList {
  NSMutableArray *sortedList = [NSMutableArray new];
  NSMutableDictionary *tempDic = [NSMutableDictionary new];
  for (NSString *updateAt in updatedAtList) {
    NSString *str1 =
        [updateAt stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *str2 =
        [str1 stringByReplacingOccurrencesOfString:@"T" withString:@"/"];
    NSString *str3 =
        [str2 stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    NSMutableString *str = [[NSMutableString alloc] initWithString:str3];
    NSString *point = @".";
    if ([str rangeOfString:point].location != NSNotFound) {
      NSRange rang = [updateAt rangeOfString:point];
      [str deleteCharactersInRange:NSMakeRange(rang.location,
                                               str.length - rang.location)];
      [sortedList addObject:str];
      [tempDic setObject:updateAt forKey:str];
    }
  }
  sortedList = (NSMutableArray *)[sortedList
      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd/hh/mm/ss"];
        if (obj1 == [NSNull null]) {
          obj1 = @"0000/00/00/00/00/00";
        }
        if (obj2 == [NSNull null]) {
          obj2 = @"0000/00/00/00/00/00";
        }
        NSDate *date1 = [formatter dateFromString:obj1];
        NSDate *date2 = [formatter dateFromString:obj2];
        NSComparisonResult result = [date1 compare:date2];
        return result == NSOrderedAscending;
      }];
  NSMutableArray *result = [NSMutableArray new];
  for (NSString *key in sortedList) {
    for (NSString *k in [tempDic allKeys]) {
      if ([key isEqualToString:k]) {
        [result addObject:[tempDic objectForKey:k]];
      }
    }
  }

  return result;
}

//跳转到个人详细资料
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    NSString *key = [_allKeys objectAtIndex:indexPath.section];
//    NSArray *arrayForKey = [_allFriends objectForKey:key];
//    RCDUserInfo *user = arrayForKey[indexPath.row];
//    if ([user.status intValue] == 10) {
//        return;
//    }
//    RCUserInfo *userInfo = [RCUserInfo new];
//    userInfo.userId = user.userId;
//    userInfo.portraitUri = user.portraitUri;
//    userInfo.name = user.name;
//
//
//    RCDPersonDetailViewController *detailViewController = [segue
//    destinationViewController];
//    detailViewController.userInfo = userInfo;
//
//}

@end
