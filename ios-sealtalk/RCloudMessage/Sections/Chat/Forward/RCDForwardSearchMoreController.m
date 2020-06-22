//
//  RCDForwardSearchMoreController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDForwardSearchMoreController.h"
#import "RCDCommonDefine.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "UIColor+RCColor.h"
#import "RCDUIBarButtonItem.h"
#import "RCDLanguageManager.h"
#import "RCDForwardSelectedCell.h"
#import "RCDBottomResultView.h"
#import <Masonry/Masonry.h>
#import "RCDForwardManager.h"
#import "RCDTableView.h"
@interface RCDForwardSearchMoreController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) RCDLabel *emptyLabel;
@property (nonatomic, strong) RCDBottomResultView *bottomResultView;
@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) UIViewController *superViewController;

@end

@implementation RCDForwardSearchMoreController

- (instancetype)initWithSuperViewController:(UIViewController *)superViewController {
    if (self = [super init]) {
        self.superViewController = superViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isShowSeachBar) {
        [self setupSubViews];
        self.navigationItem.titleView = self.searchView;
        self.searchBar.text = self.searchString;
    }
    [self setupNavi];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = self.headerView;
    if (self.isShowSeachBar) {
        self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0x0099ff, 0x000000);
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    RCDForwardSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forwardSelectCell"];
    if (!cell) {
        cell = [[RCDForwardSelectedCell alloc] init];
    }
    RCDSearchResultModel *resultModel = self.resultArray[indexPath.row];
    RCDForwardCellModel *model = [[RCDForwardCellModel alloc] init];
    model.conversationType = resultModel.conversationType;
    model.targetId = resultModel.targetId;
    [cell setModel:model];
    if ([RCDForwardManager sharedInstance].isMultiSelect) {
        cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
        if ([[RCDForwardManager sharedInstance] modelIsContains:model.targetId]) {
            cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
        }
    } else {
        cell.selectStatus = RCDForwardSelectedStatusSingleSelect;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    RCDSearchResultModel *model = self.resultArray[indexPath.row];

    RCConversation *conversation = [[RCConversation alloc] init];
    conversation.conversationType = model.conversationType;
    conversation.targetId = model.targetId;
    RCDForwardCellModel *forwardModel = [RCDForwardCellModel createModelWith:conversation];
    if ([RCDForwardManager sharedInstance].isMultiSelect) {
        RCDForwardSelectedCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectStatus == RCDForwardSelectedStatusMultiUnSelected) {
            [[RCDForwardManager sharedInstance] addForwardModel:forwardModel];
            cell.selectStatus = RCDForwardSelectedStatusMultiSelected;
        } else {
            [[RCDForwardManager sharedInstance] removeForwardModel:forwardModel];
            cell.selectStatus = RCDForwardSelectedStatusMultiUnSelected;
        }
        [self updateSelectedResult];
    } else {
        [self showForwardAlertView:conversation];
    }
}

#pragma mark - UISearchBarDelegate
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

#pragma mark - Private Method
- (void)setupSubViews {
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth - 25, 44)];
    [self.searchView addSubview:self.searchBar];
    [self.searchView addSubview:self.cancelButton];
    [self.view addSubview:self.tableView];

    if (![RCDForwardManager sharedInstance].isMultiSelect) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
        }];
    } else {
        [self.view addSubview:self.bottomResultView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.bottomResultView.mas_top);
        }];

        [self.bottomResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.offset(50 + RCDExtraBottomHeight);
        }];

        [self updateSelectedResult];
    }
}

- (void)setupNavi {
    NSString *imageStr = nil;
    if (self.isShowSeachBar) {
        imageStr = @"searchBack";
    } else {
        imageStr = @"navigator_btn_back";
    }
    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initContainImage:[UIImage imageNamed:imageStr]
                                                                   imageViewFrame:CGRectMake(0, 4, 10, 17)
                                                                      buttonTitle:nil
                                                                       titleColor:nil
                                                                       titleFrame:CGRectZero
                                                                      buttonFrame:CGRectMake(-6, 0, 30, 23)
                                                                           target:self
                                                                           action:@selector(leftBarButtonBackAction)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedResult)
                                                 name:@"ReloadBottomResultView"
                                               object:nil];
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

- (void)showForwardAlertView:(RCConversation *)conversation {
    [RCDForwardManager sharedInstance].toConversation = conversation;
    [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self.superViewController];
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

#pragma mark - Target Action
- (void)leftBarButtonBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonClicked {
    self.cancelBlock();
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateSelectedResult {
    [self.bottomResultView updateSelectResult];
}

#pragma mark - getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] initWithFrame:CGRectZero];
        _searchBar.delegate = self;
        _searchBar.placeholder = nil;
        _searchBar.tintColor = [UIColor blueColor];
        _searchBar.frame = CGRectMake(-17, 0, self.searchView.frame.size.width - 75, 44);
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
        self.emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width - 20, 16)];
        self.emptyLabel.font = [UIFont systemFontOfSize:14.f];
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.numberOfLines = 0;
        [self.tableView addSubview:self.emptyLabel];
    }
    return _emptyLabel;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _headerView.backgroundColor = RCDDYCOLOR(0xffffff, 0x000000);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 - 16 - 7, self.view.frame.size.width, 16)];
        label.font = [UIFont systemFontOfSize:14.];
        label.text = self.type;
        label.textColor = RCDDYCOLOR(0x999999, 0x666666);
        [_headerView addSubview:label];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 39.5, self.view.frame.size.width - 10, 0.5)];
        view.backgroundColor = RCDDYCOLOR(0xdfdfdf, 0x000000);
        [self.headerView addSubview:view];
    }
    return _headerView;
}

- (RCDBottomResultView *)bottomResultView {
    if (!_bottomResultView) {
        _bottomResultView = [[RCDBottomResultView alloc] init];
    }
    return _bottomResultView;
}

@end
