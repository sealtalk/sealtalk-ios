//
//  RCDForwardSearchViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDForwardSearchViewController.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchMoreController.h"
#import "UIColor+RCColor.h"
#import "RCDForwardManager.h"
#import "RCDForwardSelectedCell.h"
#import "RCDSearchMoreViewCell.h"
#import "RCDSearchResultModel.h"
#import "RCDLanguageManager.h"
#import <Masonry/Masonry.h>
#import "RCDBottomResultView.h"
#import "RCDForwardSearchMoreController.h"
#import "RCDTableView.h"
@interface RCDForwardSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,
                                              UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *resultDictionary;
@property (nonatomic, strong) NSMutableArray *groupTypeArray;
@property (nonatomic, strong) RCDSearchBar *searchBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) RCDTableView *resultTableView;
@property (nonatomic, strong) RCDLabel *emptyLabel;
@property (nonatomic, strong) RCDBottomResultView *bottomResultView;

@end

@implementation RCDForwardSearchViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupTypeArray = [NSMutableArray array];
    self.resultDictionary = [NSMutableDictionary dictionary];

    [self setupSubviews];
    [self addGestureRecognizer];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = RCDDYCOLOR(0x0099ff, 0x000000);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.groupTypeArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.resultDictionary[self.groupTypeArray[section]];
    if (array.count > 3) {
        return 4;
    }
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        RCDSearchMoreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell"];
        if (!cell) {
            cell = [[RCDSearchMoreViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"moreCell"];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.moreLabel.text =
            [NSString stringWithFormat:RCDLocalizedString(@"see_more"), self.groupTypeArray[indexPath.section]];
        return cell;
    } else {
        NSArray *array = self.resultDictionary[self.groupTypeArray[indexPath.section]];
        RCDForwardSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"forwardSelectCell"];
        if (!cell) {
            cell = [[RCDForwardSelectedCell alloc] init];
        }
        RCDSearchResultModel *resultModel = array[indexPath.row];
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 45;
    }
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 - 16 - 7, self.view.frame.size.width, 16)];
    label.font = [UIFont systemFontOfSize:14.];
    label.text = self.groupTypeArray[section];
    label.textColor = RCDDYCOLOR(0x999999, 0x666666);
    [view addSubview:label];
    //添加与cell分割线等宽的session分割线
    CGRect viewFrame = view.frame;
    UIView *separatorLine =
        [[UIView alloc] initWithFrame:CGRectMake(10, viewFrame.size.height - 1, viewFrame.size.width - 10, 1)];
    separatorLine.backgroundColor =
        [RCDUtilities generateDynamicColor:[UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1]
                                 darkColor:HEXCOLOR(0x000000)];
    [view addSubview:separatorLine];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return 0;
    }
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    NSString *type = self.groupTypeArray[indexPath.section];
    NSArray *array = self.resultDictionary[type];
    if (indexPath.row == 3) {
        [self pushToSearchMoreVC:type result:array];
    } else {
        RCDSearchResultModel *model = array[indexPath.row];
        if (model.count > 1) {
            [self pushToSearchMoreMessageVC:model];
            return;
        } else {
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
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.resultDictionary removeAllObjects];
    [self.groupTypeArray removeAllObjects];
    [[RCDSearchDataManager sharedInstance] searchDataWithSearchText:searchText
                                                       bySearchType:RCDSearchAll
                                                           complete:^(NSDictionary *dic, NSArray *array) {
                                                               [self.resultDictionary setDictionary:dic];
                                                               [self.groupTypeArray setArray:array];
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self refreshSearchView:searchText];
                                                               });
                                                           }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Private Method
- (void)setupSubviews {
    self.navigationItem.titleView = self.searchView;
    [self.view addSubview:self.resultTableView];
    [self.resultTableView addSubview:self.emptyLabel];
    [self.searchView addSubview:self.searchBar];
    [self.searchView addSubview:self.cancelButton];

    if (![RCDForwardManager sharedInstance].isMultiSelect) {
        [self.resultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
        }];
    } else {
        [self.view addSubview:self.bottomResultView];
        [self.bottomResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.offset(50 + RCDExtraBottomHeight);
        }];

        [self.resultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.bottomResultView.mas_top);
        }];

        [self updateSelectedResult];
    }

    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.resultTableView).offset(10);
        make.top.equalTo(self.resultTableView).offset(45);
        make.right.equalTo(self.resultTableView).offset(-20);
        make.height.offset(16);
    }];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedResult)
                                                 name:@"ReloadBottomResultView"
                                               object:nil];
}

- (void)addGestureRecognizer {
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSerchBarWhenTapBackground:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)showForwardAlertView:(RCConversation *)conversation {
    [RCDForwardManager sharedInstance].toConversation = conversation;
    [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self];
}

- (void)pushToSearchMoreVC:(NSString *)type result:(NSArray *)results {
    RCDForwardSearchMoreController *viewController = [[RCDForwardSearchMoreController alloc] init];
    viewController.isShowSeachBar = YES;
    viewController.searchString = self.searchBar.text;
    viewController.type = type;
    viewController.resultArray = results;
    __weak typeof(self) weakSelf = self;
    [viewController setCancelBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf cancelButtonClicked];
        });
    }];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)pushToSearchMoreMessageVC:(RCDSearchResultModel *)model {
    RCDForwardSearchMoreController *viewController = [[RCDForwardSearchMoreController alloc] init];
    viewController.searchString = self.searchBar.text;
    viewController.type = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), model.count];
    NSArray *msgArray = [[RCIMClient sharedRCIMClient] searchMessages:model.conversationType
                                                             targetId:model.targetId
                                                              keyword:self.searchBar.text
                                                                count:model.count
                                                            startTime:0];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (RCMessage *message in msgArray) {
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

- (void)refreshSearchView:(NSString *)searchText {
    [self.resultTableView reloadData];
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!self.groupTypeArray.count && searchText.length > 0 && searchStr.length > 0) {
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

- (NSString *)changeString:(NSString *)str appendStr:(NSString *)appendStr {
    if (str.length > 0) {
        str = [NSString stringWithFormat:@"%@,%@", str, appendStr];
    } else {
        str = appendStr;
    }
    return str;
}

- (void)cancelButtonClicked {
    if ([self.delegate respondsToSelector:@selector(forwardSearchViewControllerDidClickCancel)]) {
        [self.delegate forwardSearchViewControllerDidClickCancel];
    }
    [self.searchBar resignFirstResponder];
}

#pragma mark - Target Action
- (void)hideSerchBarWhenTapBackground:(id)sender {
    [self.searchBar resignFirstResponder];
}

- (void)updateSelectedResult {
    [self.bottomResultView updateSelectResult];
}

#pragma mark - getter
- (RCDTableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [[RCDTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
    }
    return _resultTableView;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDScreenWidth, 44)];
    }
    return _searchView;
}

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
        _emptyLabel = [[RCDLabel alloc] init];
        _emptyLabel.font = [UIFont systemFontOfSize:14.f];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
    }
    return _emptyLabel;
}

- (RCDBottomResultView *)bottomResultView {
    if (!_bottomResultView) {
        _bottomResultView = [[RCDBottomResultView alloc] init];
    }
    return _bottomResultView;
}

@end
