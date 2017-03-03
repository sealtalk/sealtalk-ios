//
//  SearchViewController.m
//  FriendSearch
//
//  Created by Caoyq on 16/3/28.
//  Copyright © 2016年 Caoyq. All rights reserved.
//

#import "SearchMemberViewController.h"
#import "YZHZYPinYinSearch.h"
#import "YZHChineseString.h"
#import "UIImageView+YZHWebCache.h"
#import "RedpacketColorStore.h"
#import "RedpacketErrorView.h"
#import "SeachMemberCell.h"
#import "NSBundle+RedpacketBundle.h"
#import "RPRedpacketUser.h"

@interface SearchMemberViewController ()
{
    NSArray *_userInfoArray;
}
@property (strong, nonatomic) NSMutableArray *tempArray;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *dataSource;/**<排序前的整个数据源*/
@property (strong, nonatomic) NSArray *allDataSource;/**<排序后的整个数据源*/
@property (strong, nonatomic) NSMutableArray *searchDataSource;/**<搜索结果数据源*/
@property (strong, nonatomic) NSArray *indexDataSource;/**<索引数据源*/
@property (nonatomic) RedpacketErrorView *retryViw;
//@property (nonatomic) UIImage *clearColorImage;
@end

@implementation SearchMemberViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    self.tableView.frame = self.view.bounds;
    self.titleLable.text = @"谁可以领";
    [self setNavgationBarBackgroundColor:[RedpacketColorStore rp_textColorRed] titleColor:[RedpacketColorStore rp_textcolorYellow] leftButtonTitle:nil rightButtonTitle:nil];
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    _searchController = nil;
    self.tableView = nil;
    _tempArray = nil;
}

#pragma mark - Init
- (void)initData {
    if ([self.delegate respondsToSelector:@selector(getGroupMemberListCompletionHandle:)]) {
        [self.view rp_showHudWaitingView:@"正在加载...."];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate getGroupMemberListCompletionHandle:^(NSArray<RedpacketUserInfo *> *groupMemberList) {
                _userInfoArray = groupMemberList;
                if (_userInfoArray) {
                    if (_userInfoArray.count > 0) {
                        [self.retryViw removeFromSuperview];
                        _retryViw = nil;
                        [self.tableView setTableHeaderView:[self addHeadView]];
                    }else
                    {
                        [self.tableView addSubview:self.retryViw];
                        self.tableView.frame = self.view.bounds;
                        self.retryViw.frame = self.tableView.bounds;
                        [self.tableView setTableHeaderView:nil];
                    }
                }
                
                [self performSelector:@selector(removeHud) withObject:nil afterDelay:.5];
                _dataSource = [NSMutableArray new];
                for (RedpacketUserInfo *userInfo in _userInfoArray) {
                    if (![userInfo.userId isEqualToString:[RPRedpacketUser currentUser].currentUserInfo.userId]) {
                        [_dataSource addObject:[NSString stringWithFormat:@"%@%@%@",userInfo.userNickname,@"-=sorting=-",userInfo.userId]];
                    }
                }
                _searchDataSource = [NSMutableArray new];
                //获取索引的首字母
                _indexDataSource = [YZHChineseString yzh_IndexArray:_dataSource];
                //对原数据进行排序重新分组
                _allDataSource = [YZHChineseString yzh_LetterSortArray:_dataSource];
                [self.tableView reloadData];
            }];
        });
    }
}

- (void)removeHud
{
    [self.view rp_removeHudInManaual];
}

- (UIView *)addHeadView
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 62)];

    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 18, [UIScreen mainScreen].bounds.size.width, 46)];
    backView.backgroundColor = [UIColor whiteColor];
    [headView addSubview:backView];
    
    UIImageView *anybodyView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 1.5, 41, 41)];
    [anybodyView setImage:rpRedpacketBundleImage(@"redpacket_searchMemberVC_anyone")];
    [backView addSubview:anybodyView];
    
    UILabel *anybodyLable = [[UILabel alloc]initWithFrame:CGRectMake(83, 15, headView.bounds.size.width, 16)];
    anybodyLable.text = @"任何人";
    anybodyLable.font = [UIFont systemFontOfSize:15.0];
    anybodyLable.textColor = [RedpacketColorStore rp_textColorBlack];

    [backView  addSubview:anybodyLable];
    
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, headView.bounds.size.width, 61)];
    [btn addTarget:self action:@selector(clickAnybodys) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];
    
    return headView;
}

- (void)clickAnybodys
{
    if ([self.delegate respondsToSelector:@selector(receiverInfos:)]) {
        [self.delegate receiverInfos:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.searchController.active) {
        return _indexDataSource.count;
    }else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.searchController.active) {
        return [_allDataSource[section] count];
    }else {
        return _searchDataSource.count;
    }
}
//头部索引标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.searchController.active) {
        if ([_indexDataSource[section] isEqualToString:@"{"]) {
            return  @"#";
        }
        return _indexDataSource[section];
    }else {
        return nil;
    }
}
//右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.searchController.active) {
        NSMutableArray *mArray = [[NSMutableArray alloc]init];
        for (NSString *firstStr in _indexDataSource) {
            if ([firstStr isEqualToString:@"{"]) {
                [mArray addObject:@"#"];
            }else{
            [mArray addObject:firstStr];
            }
        }
        return mArray;
    }else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    SeachMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SeachMemberCell"];
    if (!cell) {
        cell = [[SeachMemberCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SeachMemberCell"];
    }
    NSString *nameAndUid;
    NSString *nikename;
    NSString *userAvatar;
    NSString *userId;
    if (!self.searchController.active) {
        nameAndUid = _allDataSource[indexPath.section][indexPath.row];
    }else{
        nameAndUid = _searchDataSource[indexPath.row];
    }
    for (RedpacketUserInfo *userInfo in _userInfoArray) {
        
        NSRange range;
        range = [nameAndUid rangeOfString:@"-=sorting=-"];
        if (range.location != NSNotFound) {
            userId = [nameAndUid substringFromIndex:range.location + range.length];
        }
        
        if ([userId isEqualToString:userInfo.userId]){
            userAvatar = userInfo.userAvatar;
            userId     = userInfo.userId;
            nikename   = userInfo.userNickname;
        }
    }
    if ([userAvatar isKindOfClass:[NSNull class]]) {
        userAvatar = @"";
    }
    cell.nameLabel.text = nikename;
    [cell.headImageView rp_setImageWithURL:[NSURL URLWithString:userAvatar] placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

//索引点击事件
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return index;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *nameAndUid;
    NSString *userId;
    if (!self.searchController.active) {
        nameAndUid = _allDataSource[indexPath.section][indexPath.row];
    }else{
        nameAndUid = _searchDataSource[indexPath.row];
    }
    for (RedpacketUserInfo *userInfo in _userInfoArray) {
        
        NSRange range;
        range = [nameAndUid rangeOfString:@"-=sorting=-"];
        if (range.location != NSNotFound) {
            userId = [nameAndUid substringFromIndex:range.location + range.length];
        }
        
        if ([userId isEqualToString:userInfo.userId]){
            
            if ([self.delegate respondsToSelector:@selector(receiverInfos:)]) {
                [self.delegate receiverInfos:@[userInfo]];
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)tempArray
{
    if (!_tempArray) {
        _tempArray = [NSMutableArray new];
    }
    return _tempArray;
}

- (RedpacketErrorView *)retryViw
{
    rpWeakSelf;
    if (!_retryViw) {
        _retryViw = [RedpacketErrorView viewWithWith:self.view.bounds.size.width];
        [_retryViw setButtonClickBlock:^{
            [weakSelf initData];
        }];
    }
    return _retryViw;
}

//- (UIImage *)clearColorImage
//{
//    if (!_clearColorImage) {
//        CGSize highLightImageSize = CGSizeMake(100, 100);
//        UIGraphicsBeginImageContextWithOptions(highLightImageSize, 0, [UIScreen mainScreen].scale);
//        [[UIColor clearColor] set];
//        UIRectFill(CGRectMake(0, 0, highLightImageSize.width, highLightImageSize.height));
//        _clearColorImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    return _clearColorImage;
//}
@end
