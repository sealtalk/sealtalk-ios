//
//  RCDSearchFriendTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/12.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSearchFriendViewController.h"
#import "DefaultPortraitView.h"
#import "RCDAddFriendViewController.h"
#import "RCDHttpTool.h"
#import "RCDPersonDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSearchResultTableViewCell.h"
#import "RCDUserInfoManager.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"

@interface RCDSearchFriendViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                                             UISearchDisplayDelegate, UISearchControllerDelegate>

@property(strong, nonatomic) NSMutableArray *searchResult;
@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchDisplayController *searchDisplayController;

@end

@implementation RCDSearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];

    UIColor *color = self.navigationController.navigationBar.barTintColor;
    [self.navigationController.view setBackgroundColor:color];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.tableFooterView = [UIView new];
    self.searchBar.placeholder = RCDLocalizedString(@"add_friend_placeholder");
    self.searchDisplayController =
        [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [self setSearchDisplayController:self.searchDisplayController];
    [self.searchDisplayController setDelegate:self];
    [self.searchDisplayController setSearchResultsDataSource:self];
    [self.searchDisplayController setSearchResultsDelegate:self];

    self.navigationItem.title = RCDLocalizedString(@"add_contacts")
;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // initial data
    _searchResult = [[NSMutableArray alloc] init];

    [self setExtraCellLineHidden:self.searchDisplayController.searchResultsTableView];
}

+ (instancetype)searchFriendViewController {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:244 / 255.0 alpha:1];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - searchResultDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
    return _searchResult.count;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 80.f;
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *reusableCellWithIdentifier = @"RCDSearchResultTableViewCell";
    RCDSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {

        cell = [[RCDSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:reusableCellWithIdentifier];
        RCDUserInfo *user = _searchResult[indexPath.row];
        if (user) {
            cell.lblName.text = user.name;
            if ([user.portraitUri isEqualToString:@""]) {
                DefaultPortraitView *defaultPortrait =
                    [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserInfo *user = _searchResult[indexPath.row];
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.name = user.name;
    userInfo.portraitUri = user.portraitUri;

    if ([userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:RCDLocalizedString(@"can_not_add_self_to_address_book")
                                                       delegate:nil
                                              cancelButtonTitle:RCDLocalizedString(@"confirm")

                                              otherButtonTitles:nil];
        [alert show];
    } else if (user && tableView == self.searchDisplayController.searchResultsTableView) {
        NSMutableArray *cacheList =
            [[NSMutableArray alloc] initWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
        BOOL isFriend = NO;
        for (RCDUserInfo *tempInfo in cacheList) {
            if ([tempInfo.userId isEqualToString:user.userId] && [tempInfo.status isEqualToString:@"20"]) {
                isFriend = YES;
                break;
            }
        }
        if (isFriend == YES) {
            RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
            detailViewController.userId = user.userId;
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
            addViewController.targetUserInfo = userInfo;
            [self.navigationController pushViewController:addViewController animated:YES];
        }
    }
}

#pragma mark - UISearchBarDelegate
/**
 *  执行delegate搜索好友
 *
 *  @param searchBar  searchBar description
 *  @param searchText searchText description
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(searchFriend:) withObject:searchText afterDelay:0.3];
    
}

- (void)searchFriend:(NSString *)searchText{
    NSLog(@"============searchFriend");
    [_searchResult removeAllObjects];
    if ([searchText length] > 0) {
        NSString *region, *phone;
        if ([searchText containsString:@")"] && [searchText hasPrefix:@"("] && searchText.length > 2) {
            NSArray *array = [[searchText stringByReplacingOccurrencesOfString:@"(" withString:@""] componentsSeparatedByString:@")"];
            if (array.count == 2) {
                region = array[0];
                phone = array[1];
            }else{
                region = @"86";
                phone = searchText;
            }
        }else if([searchText hasPrefix:@"（"] && [searchText containsString:@"）"] && searchText.length > 2){
            NSArray *array = [[searchText stringByReplacingOccurrencesOfString:@"（" withString:@""] componentsSeparatedByString:@"）"];
            if (array.count == 2) {
                region = array[0];
                phone = array[1];
            }else{
                region = @"86";
                phone = searchText;
            }
        } else{
            region = @"86";
            phone = searchText;
        }
        if (phone.length == 0) {
           [self.searchDisplayController.searchResultsTableView reloadData];
        }
        [RCDHTTPTOOL
         searchUserByPhone:phone region:region
         complete:^(NSMutableArray *result) {
             if (result) {
                 for (RCDUserInfo *user in result) {
                     if ([user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                         [[RCDUserInfoManager shareInstance]
                          getUserInfo:user.userId
                          completion:^(RCUserInfo *user) {
                              [_searchResult addObject:user];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.searchDisplayController.searchResultsTableView reloadData];
                              });
                          }];
                     } else {
                         [[RCDUserInfoManager shareInstance]
                          getFriendInfo:user.userId
                          completion:^(RCUserInfo *user) {
                              [_searchResult addObject:user];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.searchDisplayController.searchResultsTableView reloadData];
                              });
                          }];
                     }
                 }
             }
         }];
    }
}

//每次searchDisplayController消失的时候都会调用searchDisplayControllerDidEndSearch两次
//正常情况下两次self.searchDisplayController.searchBar的superview都会是tableView
//但是如果你快速点击，那么第二次的superview会是一个UIView，这应该是iOS的系统bug
//参考http://stackoverflow.com/questions/18965713/troubles-with-uisearchbar-uisearchdisplayviewcontroller
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    if (self.tableView != self.searchDisplayController.searchBar.superview) {
        [self.searchDisplayController.searchBar removeFromSuperview];
        [self.tableView insertSubview:self.searchDisplayController.searchBar aboveSubview:self.tableView];
    }
}

//清除多余分割线
- (void)setExtraCellLineHidden:(UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
