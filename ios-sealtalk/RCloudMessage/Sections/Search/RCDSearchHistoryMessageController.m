//
//  RCDSearchHistoryMessageController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/10/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchHistoryMessageController.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "RCDSearchResultViewCell.h"
#import "RCDDBManager.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageManager.h"

@interface RCDSearchHistoryMessageController () <UISearchBarDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *resultArray;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) RCDLabel *emptyLabel;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation RCDSearchHistoryMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLoading = NO;
    self.resultArray = [NSArray array];
    [self loadSearchView];

    self.navigationItem.titleView = self.searchView;
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0x0099ff, 0x000000);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)loadSearchView {
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 44)];
    [self.searchView addSubview:self.searchBar];
    [self.searchView addSubview:self.cancelButton];
}

- (void)cancelButtonClicked {
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    RCDSearchResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[RCDSearchResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.searchString = self.searchBar.text;
    [cell setDataModel:self.resultArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDSearchResultModel *model = self.resultArray[indexPath.row];
    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
    _conversationVC.conversationType = model.conversationType;
    _conversationVC.targetId = model.targetId;
    if (model.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDDBManager getGroup:model.targetId];
        _conversationVC.title = groupInfo.groupName;
    } else {
        _conversationVC.title = model.name;
    }
    int unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType targetId:model.targetId];
    _conversationVC.unReadMessage = unreadCount;
    _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
    _conversationVC.enableUnreadMessageIcon = YES;
    _conversationVC.locatedMessageSentTime = model.time;
    //如果是单聊，不显示发送方昵称
    if (model.conversationType == ConversationType_PRIVATE) {
        _conversationVC.displayUserNameInCell = NO;
    }
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultArray = nil;
    NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:self.conversationType
                                                          targetId:self.targetId
                                                           keyword:searchText
                                                             count:50
                                                         startTime:0];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (RCMessage *message in array) {
        RCDSearchResultModel *messegeModel = [RCDSearchResultModel modelForMessage:message];
        messegeModel.searchType = RCDSearchChatHistory;
        [resultArray addObject:messegeModel];
    }
    self.resultArray = resultArray;
    [self refreshSearchView:searchText];
    if (self.resultArray.count < 50) {
        self.isLoading = NO;
    } else {
        self.isLoading = YES;
    }
}

- (void)searchBarearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)refreshSearchView:(NSString *)searchText {
    [self.tableView reloadData];
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!self.resultArray.count && searchText.length > 0 && searchStr.length > 0) {
        NSString *text = RCDLocalizedString(@"no_search_result");
        NSString *str = [NSString stringWithFormat:text, searchText];
        self.emptyLabel.textColor = HEXCOLOR(0x999999);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        int index = 0;
        NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].currentLanguage;
        if ([currentlanguage isEqualToString:@"en"]) {
            index = 24;
        } else if ([currentlanguage isEqualToString:@"zh-Hans"]) {
            index = 6;
        } else {
            NSLog(@"%s 不支持当前语言的高亮显示", __func__);
        }
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:HEXCOLOR(0x0099ff)
                                 range:NSMakeRange(index, searchText.length)];
        self.emptyLabel.attributedText = attributedString;
        CGFloat height = [self labelAdaptive:str];
        CGRect rect = self.emptyLabel.frame;
        rect.size.height = height;
        self.emptyLabel.frame = rect;
        self.emptyLabel.hidden = NO;
    } else {
        self.emptyLabel.hidden = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < self.tableView.contentSize.height && self.isLoading) {
        [self searchMoreMessage];
    }
}

- (void)searchMoreMessage {
    RCDSearchResultModel *model = self.resultArray[self.resultArray.count - 1];
    NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:self.conversationType
                                                          targetId:self.targetId
                                                           keyword:self.searchBar.text
                                                             count:50
                                                         startTime:model.time];
    if (array.count < 50) {
        self.isLoading = NO;
    } else {
        self.isLoading = YES;
    }
    NSMutableArray *resultArray = self.resultArray.mutableCopy;
    for (RCMessage *message in array) {
        RCDSearchResultModel *messegeModel = [RCDSearchResultModel modelForMessage:message];
        messegeModel.searchType = RCDSearchChatHistory;
        [resultArray addObject:messegeModel];
    }
    self.resultArray = resultArray;
    [self refreshSearchView:nil];
}

- (CGFloat)labelAdaptive:(NSString *)string {
    float maxWidth = self.view.frame.size.width - 20;
    CGRect textRect =
        [string boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                             options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading)
                          attributes:@{
                              NSFontAttributeName : [UIFont systemFontOfSize:14.0]
                          }
                             context:nil];
    textRect.size.height = ceilf(textRect.size.height);
    return textRect.size.height + 5;
}

#pragma mark - getter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.delegate = self;
        _searchBar.tintColor = [UIColor blueColor];
        [_searchBar becomeFirstResponder];
        _searchBar.frame = CGRectMake(0, 0, self.searchView.frame.size.width - 75, 44);
    }
    return _searchBar;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBar.frame) - 3,
                                                                   CGRectGetMinY(self.searchBar.frame), 60, 44)];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:HEXCOLOR(0x0099ff) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.];
        [_cancelButton addTarget:self
                          action:@selector(cancelButtonClicked)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        self.emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width - 20, 16)];
        self.emptyLabel.font = [UIFont systemFontOfSize:14.f];
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.numberOfLines = 0;
        [self.tableView addSubview:self.emptyLabel];
    }
    return _emptyLabel;
}
@end
