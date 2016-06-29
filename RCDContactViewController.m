//
//  RCDContactViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactViewController.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "RCDAddressBookTableViewCell.h"
#import "RCDRCIMDataSource.h"
#import "RCDContactTableViewCell.h"
#import "RCDPersonDetailViewController.h"
#import "RCDAddressBookViewController.h"
#import "RCDGroupViewController.h"
#import "RCDSearchFriendViewController.h"
#import "DefaultPortraitView.h"
#import "pinyin.h"
#import "RCDPublicServiceListViewController.h"

@interface RCDContactViewController ()
//#字符索引对应的user object
@property (nonatomic,strong) NSMutableArray *tempOtherArr;
@property (nonatomic,strong) NSMutableArray *friends;
@property (nonatomic,strong) NSArray *arrayForKey;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSMutableArray *friendsArr;
@property (strong, nonatomic) NSArray *defaultCellsTitle;
@property (strong, nonatomic) NSArray *defaultCellsPortrait;

@end

@implementation RCDContactViewController
{
    BOOL isSyncFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_icon_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //initial data
    _searchResult=[[NSMutableArray alloc] init];
    _friendsArr = [[NSMutableArray alloc] init];
    
    self.friendsTabelView.tableFooterView = [UIView new];
    float colorFloat = 249.f / 255.f;
    self.friendsTabelView.backgroundColor = [[UIColor alloc] initWithRed:colorFloat green:colorFloat blue:colorFloat alpha:1];
    
    _defaultCellsTitle      = [NSArray arrayWithObjects:@"新朋友",@"群组",@"公众号",@"我", nil];
    _defaultCellsPortrait   = [NSArray arrayWithObjects:@"newFriend",@"defaultGroup",@"publicNumber", nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    [self.searchFriendsBar resignFirstResponder];
    if ([_searchResult count] > 0) {
        return;
    }
    else
    {
        [_friendsArr removeAllObjects];
        [self getAllData];
    }
//        UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
//        titleView.backgroundColor = [UIColor clearColor];
//        titleView.font = [UIFont boldSystemFontOfSize:19];
//        titleView.textColor = [UIColor whiteColor];
//        titleView.textAlignment = NSTextAlignmentCenter;
//        titleView.text = @"通讯录";
//        self.tabBarController.navigationItem.titleView = titleView;
        self.tabBarController.navigationItem.title = @"通讯录";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 4;
    }
    else
    {
        NSString *key = [_allKeys objectAtIndex:section - 1];
        NSArray *arr = [_allFriends objectForKey:key];
        rows = [arr count];
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_allKeys count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (self.hideSectionHeader) {
//        return nil;
//    }
    NSString *Title;
    if (section == 0) {
        Title = @"";
    }
    else
    {
        Title =[_allKeys objectAtIndex:section - 1];
    }
    return Title;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
    RCDContactTableViewCell *cell = [self.friendsTabelView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDContactTableViewCell alloc] init];
    }
    
    if (indexPath.section == 0) {
        cell.nicknameLabel.text = [_defaultCellsTitle objectAtIndex:indexPath.row];
        if (indexPath.row != 3) {
          [cell.portraitView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_defaultCellsPortrait objectAtIndex:indexPath.row]]]];
        }
        else
        {
            [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }
    }
    else
    {
    NSString *key = [_allKeys objectAtIndex:indexPath.section - 1];
    _arrayForKey = [_allFriends objectForKey:key];
    
    RCDUserInfo *user = _arrayForKey[indexPath.row];
    if(user){
        cell.nicknameLabel.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
                UIImage *portrait = [defaultPortrait imageFromView];
                cell.portraitView.image = portrait;
        }
        else
        {
           [cell.portraitView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
        }
    }
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        cell.portraitView.layer.masksToBounds = YES;
        cell.portraitView.layer.cornerRadius = 20.f;
    }
    else
    {
        cell.portraitView.layer.masksToBounds = YES;
        cell.portraitView.layer.cornerRadius = 6.f;
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;
    cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _allKeys;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    RCDUserInfo *user = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RCDAddressBookViewController *addressBookVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDAddressBookViewController"];
                [self.navigationController pushViewController:addressBookVC animated:YES];
                return;
            }
                break;
                
            case 1:
            {
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RCDGroupViewController *addressBookVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"RCDGroupViewController"];
                [self.navigationController pushViewController:addressBookVC animated:YES];
                return;
                
            }
                break;
                
            case 2:
            {
                RCDPublicServiceListViewController *publicServiceVC = [[RCDPublicServiceListViewController alloc] init];
                [self.navigationController pushViewController:publicServiceVC  animated:YES];
                return;
                
            }
                break;
                
                case 3:
            {
                UIStoryboard *storyboard =
                [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
                
                [self.navigationController pushViewController:detailViewController animated:YES];
                detailViewController.userInfo = [RCIM sharedRCIM].currentUserInfo;
                return;
            }
                
            default:
                break;
        }
    }
    if ([_searchResult count] > 0) {
        user = _searchResult[indexPath.row];
    }
    else
    {
        //    NSIndexPath *indexPath = [self.tableView indexPath.];
        NSString *key = [_allKeys objectAtIndex:indexPath.section - 1];
        NSArray *arrayForKey = [_allFriends objectForKey:key];
        user = arrayForKey[indexPath.row];
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
    RCDPersonDetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"RCDPersonDetailViewController"];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    detailViewController.userInfo = userInfo;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchFriendsBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchResult removeAllObjects];
    if ([searchText length]) {
        for (RCDUserInfo *user in _friends) {
            if ([user.status isEqualToString:@"20"] || [user.name rangeOfString:searchText].location == NSNotFound) {
                //忽略大小写去判断是否包含
                if ([user.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [_searchResult addObject:user];
                }
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _allFriends = [self sortedArrayWithPinYinDic:_searchResult];
                [self.friendsTabelView reloadData];
        });
    }
    if ([searchText length] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _allFriends = [self sortedArrayWithPinYinDic:_friends];
            [self.friendsTabelView reloadData];
        });

    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchFriendsBar.showsCancelButton = NO;
    [self.searchFriendsBar resignFirstResponder];
    self.searchFriendsBar.text = @"";
    [_searchResult removeAllObjects];
    _allFriends = [self sortedArrayWithPinYinDic:_friendsArr];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.friendsTabelView reloadData];
    });
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchFriendsBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - 获取好友并且排序
/**
 *  initial data
 */
-(void) getAllData
{
    _keys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    _allFriends = [NSMutableDictionary new];
    _allKeys = [NSMutableArray new];
    _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance]getAllFriends ] ];
//    if (_friends==nil||_friends.count<1) {
//        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray * result) {
//            _friends=result;
//            for (RCDUserInfo *user in _friends) {
//                if ([user.status isEqualToString:@"20"]) {
//                    [_friendsArr addObject:user];
//                }
//            }
////            if (_friends.count < 20) {
////                self.hideSectionHeader = YES;
////            }
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                _allFriends = [self sortedArrayWithPinYinDic:_friendsArr];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.friendsTabelView reloadData];
//                    
//                });
//            });
//            
//        }];
//    }
    if (_friends.count > 0)
    {
//        if (_friends.count < 20) {
//            self.hideSectionHeader = YES;
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (RCDUserInfo *user in _friends) {
                if ([user.status isEqualToString:@"20"]) {
                    [_friendsArr addObject:user];
                }
            }
            _allFriends = [self sortedArrayWithPinYinDic:_friendsArr];
            [self.friendsTabelView reloadData];
        });
    }
    if ([_friends count] == 0 && isSyncFriends == NO) {
        [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray * result) {
            isSyncFriends = YES;
            [self getAllData];
        }];
    }
//    [RCDDataSource syncFriendList:[RCIM sharedRCIM].currentUserInfo.userId complete:^(NSMutableArray * result) {
//        _friends=result;
//        NSMutableArray *tmpFriends = [[NSMutableArray alloc] init];
//        for (RCDUserInfo *user in _friends) {
//            if ([user.status isEqualToString:@"20"]) {
//                [tmpFriends addObject:user];
//            }
//        }
//        //            if (_friends.count < 20) {
//        //                self.hideSectionHeader = YES;
//        //            }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSMutableDictionary *tmpDict = [self sortedArrayWithPinYinDic:tmpFriends];
//            _allFriends = tmpDict;
//            [self.friendsTabelView reloadData];
//        });
//        
//    }];

    
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
