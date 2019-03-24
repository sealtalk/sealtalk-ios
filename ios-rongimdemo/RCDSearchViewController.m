//
//  RCDSearchViewController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchViewController.h"
#import "RCDChatViewController.h"
#import "RCDCommonDefine.h"
#import "RCDLabel.h"
#import "RCDSearchBar.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchMoreController.h"
#import "RCDSearchMoreViewCell.h"
#import "RCDSearchResultModel.h"
#import "RCDSearchResultViewCell.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageManager.h"
@interface RCDSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,
                                       UIGestureRecognizerDelegate>
@property(nonatomic, strong) NSMutableDictionary *resultDictionary;
@property(nonatomic, strong) NSMutableArray *groupTypeArray;
@property(nonatomic, strong) RCDSearchBar *searchBars;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIView *searchView;
@property(nonatomic, strong) UITableView *resultTableView;
@property(nonatomic, strong) RCDLabel *emptyLabel;
@property(nonatomic, strong) UIView *searchBackgroundView;
@property(nonatomic, strong) NSDate *searchDate;
@end

@implementation RCDSearchViewController

- (UITableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView =
            [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                         style:UITableViewStylePlain];
        _resultTableView.backgroundColor = [UIColor clearColor];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        _resultTableView.tableFooterView = [UIView new];
        [_resultTableView setSeparatorColor:HEXCOLOR(0xdfdfdf)];
        [self.view addSubview:_resultTableView];
    }
    return _resultTableView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10, 45, self.view.frame.size.width - 20, 16)];
        _emptyLabel.font = [UIFont systemFontOfSize:14.f];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        [self.resultTableView addSubview:_emptyLabel];
    }
    return _emptyLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _groupTypeArray = [NSMutableArray array];
    _resultDictionary = [NSMutableDictionary dictionary];
    [self loadSearchView];
    self.navigationItem.titleView = self.searchView;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSerchBarWhenTapBackground:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([self.resultTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.resultTableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.resultTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.resultTableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = HEXCOLOR(0xf0f0f6);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"0099ff" alpha:1.0f];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)loadSearchView {
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RCDscreenWidth, 44)];

    _searchBars = [[RCDSearchBar alloc] initWithFrame:CGRectZero];
    _searchBars.delegate = self;
    _searchBars.tintColor = [UIColor blueColor];
    [_searchBars becomeFirstResponder];
    _searchBars.frame = CGRectMake(0, 0, self.searchView.frame.size.width - 75, 44);
    [self.searchView addSubview:self.searchBars];

    _cancelButton = [[UIButton alloc]
        initWithFrame:CGRectMake(CGRectGetMaxX(_searchBars.frame) - 3, CGRectGetMinY(self.searchBars.frame), 60, 44)];
    [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
    [_cancelButton setTitleColor:HEXCOLOR(0x0099ff) forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:_cancelButton];
}

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
        cell.moreLabel.text = [NSString stringWithFormat:RCDLocalizedString(@"see_more"), self.groupTypeArray[indexPath.section]];
        return cell;
    } else {
        RCDSearchResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[RCDSearchResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        NSArray *array = self.resultDictionary[self.groupTypeArray[indexPath.section]];
        cell.searchString = self.searchBars.text;
        [cell setDataModel:array[indexPath.row]];
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
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 - 16 - 7, self.view.frame.size.width, 16)];
    label.font = [UIFont systemFontOfSize:14.];
    label.text = _groupTypeArray[section];
    label.textColor = HEXCOLOR(0x999999);
    [view addSubview:label];
    //添加与cell分割线等宽的session分割线
    CGRect viewFrame = view.frame;
    UIView *separatorLine =
        [[UIView alloc] initWithFrame:CGRectMake(10, viewFrame.size.height - 1, viewFrame.size.width - 10, 1)];
    separatorLine.backgroundColor = [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1];
    [view addSubview:separatorLine];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = HEXCOLOR(0xf0f0f6);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.groupTypeArray.count - 1) {
        return 0;
    }
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBars resignFirstResponder];
    if (indexPath.row == 3) {
        RCDSearchMoreController *viewController = [[RCDSearchMoreController alloc] init];
        viewController.searchString = self.searchBars.text;
        viewController.type = _groupTypeArray[indexPath.section];
        viewController.resultArray = _resultDictionary[viewController.type];
        __weak typeof(self) weakSelf = self;
        [viewController setCancelBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf cancelButtonClicked];
            });
        }];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        NSArray *array = self.resultDictionary[self.groupTypeArray[indexPath.section]];
        RCDSearchResultModel *model = array[indexPath.row];
        if (model.count > 1) {
            RCDSearchMoreController *viewController = [[RCDSearchMoreController alloc] init];
            viewController.searchString = self.searchBars.text;
            viewController.type = [NSString stringWithFormat:RCDLocalizedString(@"total_related_message"), model.count];
            NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:model.conversationType
                                                                  targetId:model.targetId
                                                                   keyword:self.searchBars.text
                                                                     count:model.count
                                                                 startTime:0];
            NSMutableArray *resultArray = [NSMutableArray array];
            for (RCMessage *message in array) {
                RCDSearchResultModel *messegeModel = [[RCDSearchResultModel alloc] init];
                messegeModel.conversationType = model.conversationType;
                messegeModel.name = model.name;
                messegeModel.targetId = model.targetId;
                messegeModel.searchType = model.searchType;
                messegeModel.portraitUri = model.portraitUri;
                NSString *string = nil;
                messegeModel.objectName = message.objectName;
                if ([message.content isKindOfClass:[RCRichContentMessage class]]) {
                    RCRichContentMessage *rich = (RCRichContentMessage *)message.content;
                    string = rich.title;
                } else if ([message.content isKindOfClass:[RCFileMessage class]]) {
                    RCFileMessage *file = (RCFileMessage *)message.content;
                    string = file.name;
                } else {
                    string = [RCKitUtility formatMessage:message.content];
                }
                messegeModel.time = message.sentTime;
                messegeModel.otherInformation = string;
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
            return;
        } else {

            RCDChatViewController *_conversationVC = [[RCDChatViewController alloc] init];
            _conversationVC.conversationType = model.conversationType;
            _conversationVC.targetId = model.targetId;
            _conversationVC.userName = model.name;
            NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:model.conversationType
                                                                  targetId:model.targetId
                                                                   keyword:self.searchBars.text
                                                                     count:model.count
                                                                 startTime:0];
            if (array.count != 0) {
                RCMessage *message = [array firstObject];
                _conversationVC.locatedMessageSentTime = message.sentTime;
            }
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
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.resultDictionary removeAllObjects];
    [self.groupTypeArray removeAllObjects];
    //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [[RCDSearchDataManager shareInstance] searchDataWithSearchText:searchText
                                                      bySearchType:RCDSearchAll
                                                          complete:^(NSDictionary *dic, NSArray *array) {
                                                              [self.resultDictionary setDictionary:dic];
                                                              [self.groupTypeArray setArray:array];
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self refreshSearchView:searchText];
                                                              });
                                                          }];
    //  });
}

- (void)refreshSearchView:(NSString *)searchText {
    [self.resultTableView reloadData];
    NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!self.groupTypeArray.count && searchText.length > 0 && searchStr.length > 0) {
        NSString *text = RCDLocalizedString(@"no_search_result");
        NSString *str = [NSString stringWithFormat:text, searchText];
        self.emptyLabel.textColor = HEXCOLOR(0x999999);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        int index;
        NSString *currentlanguage = [RCDLanguageManager sharedRCDLanguageManager].localzableLanguage;
        if ([currentlanguage isEqualToString:@"en"]) {
            index = 24;
        }else if ([currentlanguage isEqualToString:@"zh-Hans"]){
            index = 6;
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBars resignFirstResponder];
}

- (CGFloat)labelAdaptive:(NSString *)string {
    float maxWidth = self.view.frame.size.width - 20;
    CGRect textRect =
        [string boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                             options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading)
                          attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}
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
    if ([self.delegate respondsToSelector:@selector(onSearchCancelClick)]) {
        [self.delegate onSearchCancelClick];
    }
    [self.searchBars resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBars resignFirstResponder];
}

- (void)hideSerchBarWhenTapBackground:(id)sender {
    [self.searchBars resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

@end
