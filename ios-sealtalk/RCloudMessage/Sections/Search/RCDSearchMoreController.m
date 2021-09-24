//
//  RCDSearchMoreController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchMoreController.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "RCDSearchResultViewCell.h"
#import "UIColor+RCColor.h"
#import "RCDUIBarButtonItem.h"
#import "RCDLanguageManager.h"

@interface RCDSearchMoreController () <UISearchBarDelegate>
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) RCDLabel *emptyLabel;
@end

@implementation RCDSearchMoreController
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.isShowSeachBar = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isShowSeachBar) {
        [self loadSearchView];
        self.navigationItem.titleView = self.searchView;
        self.searchBar.text = self.searchString;
    }
    [self.navigationItem setLeftBarButtonItems:[RCDUIBarButtonItem getLeftBarButton:nil target:self action:@selector(leftBarButtonBackAction)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 59, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 59, 0, 0)];
    }
}

- (void)leftBarButtonBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadSearchView {
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth - 25, 44)];

    [self.searchView addSubview:self.searchBar];

    [self.searchView addSubview:self.cancelButton];
}

- (void)cancelButtonClicked {
    self.cancelBlock();
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDSearchResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[RCDSearchResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (self.isShowSeachBar) {
        cell.searchString = self.searchBar.text;
    } else {
        cell.searchString = self.searchString;
    }
    [cell setDataModel:self.resultArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [RCDSearchResultViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    RCDSearchResultModel *model = self.resultArray[indexPath.row];
    if (model.count > 1) {
        [self pushToSearchMoreVC:model];
    } else {
        [self pushToChatVC:model];
    }
}

- (void)pushToSearchMoreVC:(RCDSearchResultModel *)model {
    RCDSearchMoreController *viewController = [[RCDSearchMoreController alloc] init];
    viewController.searchString = self.searchBar.text;
    viewController.type = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), model.count];
    NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:model.conversationType
                                                          targetId:model.targetId
                                                           keyword:self.searchBar.text
                                                             count:model.count
                                                         startTime:0];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (RCMessage *message in array) {
        RCDSearchResultModel *messegeModel = [RCDSearchResultModel modelForMessage:message];
        messegeModel.searchType = model.searchType;
        [resultArray addObject:messegeModel];
    }
    viewController.title = model.name;
    viewController.isShowSeachBar = NO;
    viewController.resultArray = resultArray;
    __weak typeof(self) weakSelf = self;
    [viewController setCancelBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelButtonClicked];
        });
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToChatVC:(RCDSearchResultModel *)model {
    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
    _conversationVC.conversationType = model.conversationType;
    _conversationVC.targetId = model.targetId;
    _conversationVC.title = model.name;
    _conversationVC.locatedMessageSentTime = model.time;
    int unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType targetId:model.targetId];
    _conversationVC.unReadMessage = unreadCount;
    _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
    _conversationVC.enableUnreadMessageIcon = YES;
    //如果是单聊，不显示发送方昵称
    if (model.conversationType == ConversationType_PRIVATE) {
        _conversationVC.displayUserNameInCell = NO;
    }
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = nil;
    searchBar.placeholder = self.type;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultArray = nil;
    RCDSearchType type = RCDSearchFriend;
    if ([self.type isEqualToString:RCDLocalizedString(@"all_contacts")]) {
        type = RCDSearchFriend;
    } else if ([self.type isEqualToString:RCDLocalizedString(@"group")]) {
        type = RCDSearchGroup;
    } else if ([self.type isEqualToString:RCDLocalizedString(@"chat_history")]) {
        type = RCDSearchChatHistory;
    }
    __weak typeof(self) weakSelf = self;
    [[RCDSearchDataManager sharedInstance] searchDataWithSearchText:searchText
                                                       bySearchType:type
                                                           complete:^(NSDictionary *dic, NSArray *array) {
                                                               weakSelf.resultArray = [dic objectForKey:weakSelf.type];
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [weakSelf refreshSearchView:searchText];
                                                               });
                                                           }];
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
        self.emptyLabel.textColor = RCDDYCOLOR(0x999999, 0x8b8b8b);
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
        self.tableView.tableHeaderView = nil;
    } else {
        self.emptyLabel.hidden = YES;
        if (self.resultArray.count > 0) {
            self.tableView.tableHeaderView = self.headerView;
        } else {
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (CGFloat)labelAdaptive:(NSString *)string {
    float maxWidth = self.view.frame.size.width - 20;
    CGRect textRect =
        [string boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                             options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading)
                          attributes:@{
                              NSFontAttributeName : self.emptyLabel.font
                          }
                             context:nil];
    textRect.size.height = ceilf(textRect.size.height);
    return textRect.size.height + 5;
}

#pragma mark - getter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectMake(-17, 0, self.searchView.frame.size.width - 75, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = nil;
        _searchBar.tintColor = [UIColor blueColor];
    }
    return _searchBar;
}
- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]
            initWithFrame:CGRectMake(CGRectGetMaxX(_searchBar.frame) - 3, CGRectGetMinY(self.searchBar.frame), 60, 44)];
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
        _emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width - 20, 19)];
        _emptyLabel.font = [UIFont systemFontOfSize:17.f];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        [self.tableView addSubview:_emptyLabel];
    }
    return _emptyLabel;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _headerView.backgroundColor = RCDDYCOLOR(0xffffff, 0x111111);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, self.view.frame.size.width, 19)];
        label.font = [UIFont systemFontOfSize:13.5f];
        label.text = self.type;
        label.textColor = RCDDYCOLOR(0x999999, 0x8B8B8B);
        [_headerView addSubview:label];
    }
    return _headerView;
}
@end
