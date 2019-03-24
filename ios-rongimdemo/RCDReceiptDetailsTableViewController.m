//
//  RCDReceiptDetailsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsTableViewController.h"
#import "RCDAddFriendViewController.h"
#import "RCDCommonDefine.h"
#import "RCDPersonDetailViewController.h"
#import "RCDReceiptDetailsTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"

@interface RCDReceiptDetailsTableViewController () <RCDReceiptDetailsCellDelegate>

@property(nonatomic, strong) UIView *headerView;

@property(nonatomic, strong) UILabel *nameLabel;

@property(nonatomic, strong) UILabel *timeLabel;

@property(nonatomic, strong) UILabel *messageContentLabel;

@property(nonatomic, strong) UIButton *openAndCloseButton;

@property(nonatomic, strong) NSDictionary *headerSubViews;

@property(nonatomic, strong) NSArray *MessageContentLabelConstraints;

@property(nonatomic, assign) CGFloat labelHeight;

@property(nonatomic, strong) NSArray *displayUserList;

@property(nonatomic, strong) NSArray *UnreadUserList;

@property(nonatomic, strong) NSArray *groupMemberList;

@property(nonatomic, assign) BOOL displayHasreadUsers;

@property(nonatomic, assign) CGFloat headerViewHeight;

@property(nonatomic, assign) CGFloat cellHeight;

//避免重复点击同一个按钮导致的重复刷新
@property(nonatomic, assign) NSInteger selectedButton;

@property(nonatomic, strong) RCDUIBarButtonItem *leftBtn;
@end

@implementation RCDReceiptDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = RCDLocalizedString(@"Receipt_details");

    self.leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = self.leftBtn;

    [self setHeaderView];

    self.displayUserList = self.hasReadUserList;
    self.UnreadUserList = [self getUnreadUserList];
    [self.tableView reloadData];

    self.displayHasreadUsers = YES;

    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //默认选中左边的按钮
    self.selectedButton = 0;

    self.cellHeight = 0;

    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellHeight == 0 && self.headerViewHeight > 0) {
        //屏幕的高度 - sectionHeader的高度 - 导航栏的高度 = cell的高度
        self.cellHeight = RCDscreenHeight - self.headerViewHeight - 15 - 64;
    }
    return self.cellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDReceiptDetailsTableViewCell";
    RCDReceiptDetailsTableViewCell *cell =
        [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDReceiptDetailsTableViewCell alloc] init];
    }
    if (self.cellHeight == 0 && self.headerViewHeight > 0) {
        //屏幕的高度 - sectionHeader的高度 - 导航栏的高度 = cell的高度
        self.cellHeight = RCDscreenHeight - self.headerViewHeight - 15 - 64;
    }
    cell.cellHeight = self.cellHeight;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.groupMemberList = self.groupMemberList;
    cell.userList = self.displayUserList;
    cell.displayHasreadUsers = self.displayHasreadUsers;
    cell.hasReadUsersCount = self.hasReadUserList.count;
    cell.unreadUsersCount = self.UnreadUserList.count;
    return cell;
}

#pragma mark setHeaderView
- (void)setHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectZero];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [UIFont systemFontOfSize:16.f];
    self.nameLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];

    self.nameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.nameLabel];

    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.font = [UIFont systemFontOfSize:14.f];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];

    self.timeLabel.text = self.messageSendTime;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.timeLabel];

    self.messageContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageContentLabel.font = [UIFont systemFontOfSize:16.f];
    self.messageContentLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];

    self.messageContentLabel.text = self.messageContent;
    self.messageContentLabel.numberOfLines = 4;
    self.messageContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.messageContentLabel];

    self.openAndCloseButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.openAndCloseButton setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
    [self.openAndCloseButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
    [self.openAndCloseButton addTarget:self
                                action:@selector(openAndCloseMessageContentLabel:)
                      forControlEvents:UIControlEventTouchUpInside];
    self.openAndCloseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.openAndCloseButton];

    self.headerSubViews =
        NSDictionaryOfVariableBindings(_nameLabel, _timeLabel, _messageContentLabel, _openAndCloseButton);

    [self setHeaderViewAutolayout];
}

- (void)setHeaderViewAutolayout {
    self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.headerViewHeight);
    [self.headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9.5-[_nameLabel]-100-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:self.headerSubViews]];

    [self.headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_timeLabel]-10-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:self.headerSubViews]];

    [self.headerView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-9.5-[_messageContentLabel]-10-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.headerSubViews]];
    NSUInteger lines = [self numberOfRowsInLabel:self.messageContentLabel];
    if (lines <= 4) {
        self.openAndCloseButton.hidden = YES;

        self.MessageContentLabelConstraints =
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7.5-[_nameLabel(21)]-7-[_messageContentLabel]"
                                                    options:0
                                                    metrics:nil
                                                      views:self.headerSubViews];

        [self commitSetAutoLayout];

        self.headerViewHeight =
            47 + [self.messageContentLabel sizeThatFits:CGSizeMake(self.messageContentLabel.frame.size.width, MAXFLOAT)]
                     .height;
        self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.headerViewHeight);
        self.tableView.tableHeaderView = self.headerView;
    }
    if (lines > 4) {
        self.MessageContentLabelConstraints = [
            [NSLayoutConstraint constraintsWithVisualFormat:
                                    @"V:|-7.5-[_nameLabel(21)]-7-[_messageContentLabel]-8.5-[_openAndCloseButton(14)]"
                                                    options:0
                                                    metrics:nil
                                                      views:self.headerSubViews]

            arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_openAndCloseButton]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:self.headerSubViews]];
        [self commitSetAutoLayout];
        self.headerViewHeight = 145;
        self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 145);
        self.tableView.tableHeaderView = self.headerView;
    }
    [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:_timeLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_nameLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:0]];
    [self.headerView setNeedsUpdateConstraints];
    [self.headerView updateConstraintsIfNeeded];
    [self.headerView layoutIfNeeded];
}

- (void)openAndCloseMessageContentLabel:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    [self.headerView removeConstraints:self.headerView.constraints];
    [self setHeaderViewAutolayout];
    if (button.selected == YES) {
        self.messageContentLabel.numberOfLines = 0;
        self.headerViewHeight =
        70 + [self.messageContentLabel sizeThatFits:CGSizeMake(self.messageContentLabel.frame.size.width, MAXFLOAT)]
        .height;
        self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width,self.headerViewHeight);
        self.tableView.tableHeaderView = self.headerView;
        self.tableView.scrollEnabled = YES;
    } else {
        self.messageContentLabel.numberOfLines = 4;
        self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 145);
        self.tableView.tableHeaderView = self.headerView;
//        [self.tableView reloadData];
        self.tableView.scrollEnabled = NO;
    }
}

- (NSInteger)numberOfRowsInLabel:(UILabel *)label {
    CGFloat labelWidth = self.tableView.frame.size.width - 20;
    NSDictionary *attrs = @{NSFontAttributeName : label.font};
    CGSize maxSize = CGSizeMake(labelWidth, MAXFLOAT);
    CGFloat textH = [label.text boundingRectWithSize:maxSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attrs
                                             context:nil]
                        .size.height;
    self.labelHeight = textH;
    CGFloat lineHeight = label.font.lineHeight;
    NSInteger lineCount = textH / lineHeight;
    return lineCount;
}

- (void)commitSetAutoLayout {
    [self.headerView addConstraints:self.MessageContentLabelConstraints];
    [self.headerView setNeedsUpdateConstraints];
    [self.headerView updateConstraintsIfNeeded];
    [self.headerView layoutIfNeeded];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickHasReadButton {
    if (self.selectedButton != 0) {
        self.selectedButton = 0;
        self.displayUserList = self.hasReadUserList;
        self.displayHasreadUsers = YES;
        [self refreshCell];
    }
}

- (void)clickUnreadButton {
    if (self.selectedButton != 1) {
        self.selectedButton = 1;
        self.displayUserList = self.UnreadUserList;
        self.displayHasreadUsers = NO;
        [self refreshCell];
    }
}

- (void)clickPortrait:(NSString *)userId {
    RCDUserInfo *user = [[RCDataBaseManager shareInstance] getFriendInfo:userId];
    if (user != nil) {
        RCDPersonDetailViewController *vc = [[RCDPersonDetailViewController alloc] init];
        vc.userId = userId;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        for (RCUserInfo *user in self.groupMemberList) {
            if ([user.userId isEqualToString:userId]) {
                RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
                addViewController.targetUserInfo = user;
                [self.navigationController pushViewController:addViewController animated:YES];
            }
        }
    }
}

- (void)refreshCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (NSArray *)getUnreadUserList {
    NSArray *UserList;
    NSArray *allUsers = [[RCDataBaseManager shareInstance] getGroupMember:self.targetId];
    self.groupMemberList = allUsers;
    NSMutableArray *allUsersId = [NSMutableArray new];
    for (RCUserInfo *user in allUsers) {
        if (![user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [allUsersId addObject:user.userId];
        }
    }
    UserList = allUsersId;
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", self.hasReadUserList];
    UserList = [UserList filteredArrayUsingPredicate:filterPredicate];
    return UserList;
}

@end
