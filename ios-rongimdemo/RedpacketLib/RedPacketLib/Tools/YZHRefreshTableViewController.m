//
//  YZHRefreshTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/9.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"
#import "YZHRefresh.h"

@interface YZHRefreshTableViewController ()

@property (nonatomic, readonly) UITableViewStyle style;

@end

@implementation YZHRefreshTableViewController

@synthesize rightItems = _rightItems;


- (void)dealloc
{
    /**
     *  有客户反映，退出零钱页的 红包记录页面时崩溃，崩溃原因是MJRefresh的监听还没有被remove掉
     */
    YZHRefreshComponent *component = self.tableView.rp_footer;
    [component removeFromSuperview];
    self.tableView.rp_footer = nil;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:self.style];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = self.defaultFooterView;
    [self.view addSubview:_tableView];
    
    _page = 0;
    _showRefreshHeader = NO;
    _showRefreshFooter = NO;
    _showTableBlankView = NO;
}

#pragma mark - setter

- (void)setShowRefreshHeader:(BOOL)showRefreshHeader
{
    if (_showRefreshHeader != showRefreshHeader) {
        _showRefreshHeader = showRefreshHeader;
        if (_showRefreshHeader) {
            __weak YZHRefreshTableViewController *weakSelf = self;
            self.tableView.rp_header = [YZHRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerHeaderRefresh];
                [weakSelf.tableView.rp_header beginRefreshing];
            }];
            //            header.updatedTimeHidden = YES;
        }
        else{
            //            [self.tableView removeHeader];
        }
    }
}

- (void)setShowRefreshFooter:(BOOL)showRefreshFooter
{
    if (_showRefreshFooter != showRefreshFooter) {
        _showRefreshFooter = showRefreshFooter;
        if (_showRefreshFooter) {
            __weak YZHRefreshTableViewController *weakSelf = self;
            self.tableView.rp_footer = [YZHRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf tableViewDidTriggerFooterRefresh];
                [weakSelf.tableView.rp_footer beginRefreshing];
            }];
        }
        else{
            [self.tableView.rp_footer removeFromSuperview];
        }
    }
}

- (void)setShowTableBlankView:(BOOL)showTableBlankView
{
    if (_showTableBlankView != showTableBlankView) {
        _showTableBlankView = showTableBlankView;
    }
}

#pragma mark - getter

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (NSMutableDictionary *)dataDictionary
{
    if (_dataDictionary == nil) {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
    
    return _dataDictionary;
}

- (UIView *)defaultFooterView
{
    if (_defaultFooterView == nil) {
        _defaultFooterView = [[UIView alloc] init];
    }
    
    return _defaultFooterView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLDEFAULTHEIGHT;
}

#pragma mark - public refresh

- (void)autoTriggerHeaderRefresh
{
    if (self.showRefreshHeader) {
        [self tableViewDidTriggerHeaderRefresh];
    }
}

/**
 *  下拉刷新事件
 */
- (void)tableViewDidTriggerHeaderRefresh
{
    
}

/**
 *  上拉加载事件
 */
- (void)tableViewDidTriggerFooterRefresh
{
    
}

- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader reload:(BOOL)reload
{
    __weak YZHRefreshTableViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (reload) {
            [weakSelf.tableView reloadData];
        }
        
        if (isHeader) {
            [weakSelf.tableView.rp_header endRefreshing];
        }else{
            [weakSelf.tableView.rp_footer endRefreshing];
        }
    });
}

@end
