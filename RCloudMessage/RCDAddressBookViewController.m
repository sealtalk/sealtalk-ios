//
//  RCDAddressBookViewController.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDAddressBookViewController.h"
#import "RCDRCIMDataSource.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDAddressBookTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "pinyin.h"
#import "RCDUserInfo.h"
#include <ctype.h>
#import "RCDPersonDetailViewController.h"
#import "RCDataBaseManager.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"

@interface RCDAddressBookViewController ()

//#字符索引对应的user object
@property (nonatomic,strong) NSMutableArray *tempOtherArr;
@property (nonatomic,strong) NSMutableArray *friends;
@property (nonatomic,strong) NSArray *arrayForKey;
@property (nonatomic,strong) NSMutableDictionary *friendsDic;
@property (nonatomic,strong) UILabel *noFriend;

@end

@implementation RCDAddressBookViewController
MBProgressHUD* hud ;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"新朋友";
    
    self.tableView.tableFooterView = [UIView new];
    
    _friendsDic = [[NSMutableDictionary alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _needSyncFriendList = YES;
    [self getAllData];
}

//删除已选中用户
-(void) removeSelectedUsers:(NSArray *) selectedUsers
{
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
-(void) getAllData
{
    _keys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    _allFriends = [NSMutableDictionary new];
    _allKeys = [NSMutableArray new];
    _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance]getAllFriends ] ];
    if ([_friends count] > 0) {
        _noFriend.hidden = YES;
         self.hideSectionHeader = YES;
        _allFriends = [self sortedArrayWithPinYinDic:_friends];
        [self.tableView reloadData];
    }
    if ([_friends count] == 0) {
        _noFriend = [[UILabel alloc] init];
        _noFriend.frame = CGRectMake((self.view.frame.size.width / 2) - 50, (self.view.frame.size.height / 2) - 15 - self.navigationController.navigationBar.frame.size.height, 100, 30);
        [_noFriend setText:@"暂无好友"];
        [_noFriend setTextColor:[UIColor grayColor]];
        _noFriend.textAlignment = UITextAlignmentCenter;
        _noFriend.hidden = NO;
        [self.view addSubview:_noFriend];
//        return;
    }
    if (_needSyncFriendList == YES) {
        _noFriend.hidden = YES;
        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray * result) {
            if (result.count == 0) {
                if (_friends.count < 20) {
                    self.hideSectionHeader = YES;
                }
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    _allFriends = [self sortedArrayWithPinYinDic:_friends];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        
                    });
                });
            }
            _friends=result;
            if (_friends.count < 20) {
                self.hideSectionHeader = YES;
            }
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                _allFriends = [self sortedArrayWithPinYinDic:_friends];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            });
            
        }];
    }
    else if (_friends==nil||_friends.count<1) {
        _noFriend.hidden = YES;
        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray * result) {
            _friends=result;
            if (_friends.count < 20) {
                self.hideSectionHeader = YES;
            }
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                _allFriends = [self sortedArrayWithPinYinDic:_friends];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            });

        }];
    }
    else
    {
        _noFriend.hidden = YES;
        if (_friends.count < 20) {
            self.hideSectionHeader = YES;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            _allFriends = [self sortedArrayWithPinYinDic:_friends];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                
            });
        });
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellWithIdentifier = @"RCDAddressBookCell";
    RCDAddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    cell.tag = indexPath.section + 5000;
    cell.acceptBtn.tag = indexPath.section + 10000;
    NSString *key = [_allKeys objectAtIndex:indexPath.section];
    _arrayForKey = [_allFriends objectForKey:key];

    RCDUserInfo *user = _arrayForKey[indexPath.row];
    [_friendsDic setObject:user forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section + 5000]];
    if(user){
        cell.lblName.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
                UIImage *portrait = [defaultPortrait imageFromView];
                cell.imgvAva.image = portrait;
        }
        else
        {
            [cell.imgvAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
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
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        cell.imgvAva.layer.masksToBounds = YES;
        cell.imgvAva.layer.cornerRadius = 18.f;
    }
    else
    {
        cell.imgvAva.layer.masksToBounds = YES;
        cell.imgvAva.layer.cornerRadius = 6.f;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imgvAva.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_allKeys objectAtIndex:section];
    
    NSArray *arr = [_allFriends objectForKey:key];

    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    return [_allKeys count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

//pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (self.hideSectionHeader) {
        return nil;
    }
    return _allKeys;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.hideSectionHeader) {
        return nil;
    }

    NSString *key = [_allKeys objectAtIndex:section];
    return key;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    NSIndexPath *indexPath = [self.tableView indexPath.];
    NSString *key = [_allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [_allFriends objectForKey:key];
    RCDUserInfo *user = arrayForKey[indexPath.row];
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
//    RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
    
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = userInfo.userId;
    chatViewController.title = userInfo.name;
    [self.navigationController pushViewController:chatViewController animated:YES];

//    [self.navigationController pushViewController:detailViewController animated:YES];
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
-(NSString *) hanZiToPinYinWithString:(NSString *)hanZi
{
    if(!hanZi) return nil;
    NSString *pinYinResult=[NSString string];
    for(int j=0;j<hanZi.length;j++){
        NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        
    }
    
    return pinYinResult;

}


/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */
-(NSMutableDictionary *) sortedArrayWithPinYinDic:(NSArray *) friends
{
    if(!friends) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    _tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (RCDUserInfo *user in friends) {
            
            NSString *pyResult = [self hanZiToPinYinWithString:user.name];
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]){
                [tempArr addObject:user];
            }
            
            if(isReturn) continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if(![tempArr count]) continue;
        [returnDic setObject:tempArr forKey:key];
        
    }
    if([_tempOtherArr count])
        [returnDic setObject:_tempOtherArr forKey:@"#"];
    
    
    _allKeys = [[returnDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    return returnDic;
}

-(void) doAccept:(UIButton*)sender
{
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"添加好友中...";
    [hud show:YES];
    NSInteger tag = sender.tag;
    tag -= 5000;
    RCDAddressBookTableViewCell *cell = (RCDAddressBookTableViewCell*)[self.view viewWithTag:tag];
    
    RCDUserInfo *friend = [_friendsDic objectForKey:[NSString stringWithFormat:@"%ld",(long)tag]];
    
    [RCDHTTPTOOL processInviteFriendRequest:friend.userId
                                   complete:^(BOOL request) {
                                       if (request) {
                                           [RCDHTTPTOOL getFriends:[RCIM sharedRCIM].currentUserInfo.userId
                                                          complete:^(NSMutableArray *result) {
                                                              
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  cell.acceptBtn.hidden = YES;
                                                                  cell.arrow.hidden = NO;
                                                                  cell.rightLabel.hidden = NO;
                                                                  cell.rightLabel.text=@"已接受";
                                                                  cell.selected = YES;
                                                                  [hud hide:YES];
                                                              });
                                                          }];
                                       } else {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [hud hide:YES];
                                               UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"添加失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                               [failAlert show];
                                           });
                                       }
                                   }];
    
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
//    RCDPersonDetailViewController *detailViewController = [segue destinationViewController];
//    detailViewController.userInfo = userInfo;
//    
//}

@end
