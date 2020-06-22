//
//  RCDHaveSelectedViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDHaveSelectedViewController.h"
#import <Masonry/Masonry.h>
#import "RCDHaveSelectedCell.h"
#import "UIColor+RCColor.h"
#import "RCDForwardManager.h"
#import "RCDTableView.h"
static NSString *haveSelectedCellIdentifier = @"RCDHaveSelectedCellIdentifier";

@interface RCDHaveSelectedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RCDTableView *tableView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) NSArray *selectedModelArray;

@end

@implementation RCDHaveSelectedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self setNavi];
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDHaveSelectedCell *cell = [self.tableView dequeueReusableCellWithIdentifier:haveSelectedCellIdentifier];
    if (cell == nil) {
        cell = [[RCDHaveSelectedCell alloc] init];
    }
    RCDForwardCellModel *model = self.selectedModelArray[indexPath.row];
    ;
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    cell.deleteButtonBlock = ^(RCDForwardCellModel *_Nonnull model) {
        rcd_dispatch_main_async_safe(^{
            [[RCDForwardManager sharedInstance] removeForwardModel:model];
            [weakSelf getData];
            [weakSelf.tableView reloadData];
        });
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark - Private Method
- (void)setupSubviews {

    self.title = RCDLocalizedString(@"SelectedContacts");
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
}

- (void)setNavi {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)getData {
    self.selectedModelArray = [[RCDForwardManager sharedInstance] getForwardModelArray];
}

#pragma mark - Target Action
- (void)confirmButtonEvent {
    if (self.confirmButtonBlock) {
        self.confirmButtonBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter && Getter
- (RCDTableView *)tableView {
    if (!_tableView) {
        _tableView = [[RCDTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _tableView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [_confirmButton setTitle:RCDLocalizedString(@"ConfirmBtnTitle") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:@"939393" alpha:1] forState:UIControlStateDisabled];
        [_confirmButton addTarget:self
                           action:@selector(confirmButtonEvent)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
