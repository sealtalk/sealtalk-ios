//
//  RCDSearchHistoryMessageController.m
//  RCloudMessage
//
//  Created by 张改红 on 16/10/13.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchHistoryMessageController.h"
#import "RCDSearchBar.h"
#import "UIColor+RCColor.h"
#import "RCDCommonDefine.h"
#import "RCDSearchDataManager.h"
#import "RCDSearchResultModel.h"
#import "RCDSearchResultViewCell.h"
#import "RCDLabel.h"
#import "RCDataBaseManager.h"
#import "RCDChatViewController.h"
@interface RCDSearchHistoryMessageController ()<UISearchBarDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)NSArray *resultArray;
@property (nonatomic,strong)RCDSearchBar *searchBars;
@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIView *searchView;
@property (nonatomic,strong)RCDLabel *emptyLabel;
@property (nonatomic,assign)BOOL isLoading;
@end

@implementation RCDSearchHistoryMessageController
- (UILabel *)emptyLabel{
  if (!_emptyLabel) {
    self.emptyLabel = [[RCDLabel alloc] initWithFrame:CGRectMake(10,45, self.view.frame.size.width-20, 16)];
    self.emptyLabel.font = [UIFont systemFontOfSize:14.f];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    [self.tableView addSubview:self.emptyLabel];
    
  }
  return _emptyLabel;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.isLoading = NO;
  self.view.backgroundColor = [UIColor whiteColor];
  self.resultArray = [NSArray array];
  [self loadSearchView];
  self.navigationItem.titleView = self.searchView;
  self.tableView.tableFooterView = [UIView new];
  self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillLayoutSubviews{
  [super viewWillLayoutSubviews];
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,10, 0, 0)];
    
  }
  if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
    [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
  }
  
}

- (void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.barTintColor = HEXCOLOR(0xf0f0f6);
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
  [super viewWillDisappear:animated];
  self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"0099ff" alpha:1.0f];
  [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void)loadSearchView{
  self.searchView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, RCDscreenWidth, 44)];
  _searchBars = [[RCDSearchBar alloc] initWithFrame:CGRectZero];
  _searchBars.delegate = self;
  _searchBars.tintColor=[UIColor blueColor];
  [_searchBars becomeFirstResponder];
  _searchBars.frame = CGRectMake( 0, 0,self.searchView.frame.size.width-55, 44);
  [self.searchView addSubview:self.searchBars];
  
  _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_searchBars.frame)-3, CGRectGetMinY(self.searchBars.frame),55, 44)];
  [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
  [_cancelButton setTitleColor:HEXCOLOR(0x0099ff) forState:UIControlStateNormal];
  _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.];
  [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
  [self.searchView addSubview:_cancelButton];
}

- (void)cancelButtonClicked{
  [self.searchBars resignFirstResponder];
  [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  RCDSearchResultViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if (!cell) {
    cell = [[RCDSearchResultViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  }
  cell.searchString = self.searchBars.text;
  [cell setDataModel:_resultArray[indexPath.row]];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  RCDSearchResultModel *model = self.resultArray[indexPath.row];
  RCDChatViewController *_conversationVC =
  [[RCDChatViewController alloc] init];
  _conversationVC.conversationType = model.conversationType;
  _conversationVC.targetId = model.targetId;
  if (model.conversationType == ConversationType_GROUP) {
    RCDGroupInfo *groupInfo = [[RCDataBaseManager shareInstance] getGroupByGroupId:model.targetId];
    _conversationVC.title = groupInfo.groupName;
  }else {
    _conversationVC.title = model.name;
  }
  int unreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType targetId:model.targetId];
  _conversationVC.unReadMessage = unreadCount;
  _conversationVC.enableNewComingMessageIcon = YES; //开启消息提醒
  _conversationVC.enableUnreadMessageIcon = YES;
  //如果是单聊，不显示发送方昵称
  if (model.conversationType == ConversationType_PRIVATE) {
    _conversationVC.displayUserNameInCell = NO;
  }
  [self.navigationController pushViewController:_conversationVC
                                       animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
  self.resultArray = nil;
  NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:self.conversationType targetId:self.targetId keyword:searchText count:50 startTime:0];
  NSMutableArray *resultArray = [NSMutableArray array];
  for (RCMessage *message in array) {
    RCDSearchResultModel *messegeModel = [[RCDSearchResultModel alloc] init];
    messegeModel.conversationType = self.conversationType;
    messegeModel.targetId = self.targetId;
    messegeModel.otherInformation = [RCKitUtility formatMessage:message.content];
    messegeModel.time = message.sentTime;
    messegeModel.searchType = RCDSearchChatHistory;
    
    if (self.conversationType == ConversationType_GROUP) {
      RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:message.senderUserId];
      messegeModel.name = user.name;
      messegeModel.portraitUri = user.portraitUri;
    }else if(self.conversationType == ConversationType_PRIVATE){
      RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:self.targetId];
      messegeModel.name = user.name;
      messegeModel.portraitUri = user.portraitUri;
    }
    [resultArray addObject:messegeModel];
  }
  self.resultArray = resultArray;
  [self refreshSearchView:searchText];
  if (self.resultArray.count < 50) {
    self.isLoading = NO;
  }else{
    self.isLoading = YES;
  }
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
  [self.searchBars resignFirstResponder];
}


- (void)refreshSearchView:(NSString *)searchText{
  [self.tableView reloadData];
  NSString *searchStr = [searchText stringByReplacingOccurrencesOfString:@" "  withString:@""];
  if (!self.resultArray.count && searchText.length>0 && searchStr.length > 0) {
    NSString *str =[NSString stringWithFormat:@"没有搜索到“%@”相关的内容",searchText];
    self.emptyLabel.textColor = HEXCOLOR(0x999999);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString addAttribute:NSForegroundColorAttributeName value:HEXCOLOR(0x0099ff) range:NSMakeRange(6, searchText.length)];
    self.emptyLabel.attributedText = attributedString;
    CGFloat height = [self labelAdaptive:str];
    CGRect rect = self.emptyLabel.frame;
    rect.size.height = height;
    self.emptyLabel.frame = rect;
    self.emptyLabel.hidden = NO;
  }else{
    self.emptyLabel.hidden = YES;
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
  if (scrollView.contentOffset.y < self.tableView.contentSize.height && self.isLoading) {
    [self searchMoreMessage];
  }
}

- (void)searchMoreMessage{
  RCDSearchResultModel *model = self.resultArray[self.resultArray.count-1];
  NSArray *array = [[RCIMClient sharedRCIMClient] searchMessages:self.conversationType targetId:self.targetId keyword:self.searchBars.text count:50 startTime:model.time];
  if (array.count < 50) {
    self.isLoading = NO;
  }else{
    self.isLoading = YES;
  }
  NSMutableArray *resultArray = self.resultArray.mutableCopy;
  for (RCMessage *message in array) {
    RCDSearchResultModel *messegeModel = [[RCDSearchResultModel alloc] init];
    messegeModel.conversationType = self.conversationType;
    messegeModel.targetId = self.targetId;
    messegeModel.otherInformation = [RCKitUtility formatMessage:message.content];
    messegeModel.time = message.sentTime;
    messegeModel.searchType = RCDSearchChatHistory;
    
    if (self.conversationType == ConversationType_GROUP) {
      RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:message.senderUserId];
      messegeModel.name = user.name;
      messegeModel.portraitUri = user.portraitUri;
    }else if(self.conversationType == ConversationType_PRIVATE){
      RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:self.targetId];
      messegeModel.name = user.name;
      messegeModel.portraitUri = user.portraitUri;
    }
    [resultArray addObject:messegeModel];
  }
  self.resultArray = resultArray;
  [self refreshSearchView:nil];
}

- (CGFloat)labelAdaptive:(NSString *)string{
  float maxWidth = self.view.frame.size.width-20;
  CGRect textRect = [string
                     boundingRectWithSize:CGSizeMake(maxWidth, 8000)
                     options:(NSStringDrawingTruncatesLastVisibleLine |
                              NSStringDrawingUsesLineFragmentOrigin |
                              NSStringDrawingUsesFontLeading)
                     attributes:@{
                                  NSFontAttributeName :
                                    [UIFont systemFontOfSize:14.0]
                                  }
                     context:nil];
  textRect.size.height = ceilf(textRect.size.height);
  return textRect.size.height + 5;
}

@end
