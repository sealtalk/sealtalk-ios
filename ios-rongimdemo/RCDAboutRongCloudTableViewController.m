//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDDebugViewController.h"
#import "RCDLogoTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDVersionCell.h"
#import "UIColor+RCColor.h"
#import "RCDDebugNoDisturbViewController.h"

@interface RCDAboutRongCloudTableViewController ()
@property(nonatomic, strong) NSArray *urls;

// force crash for test
@property(nonatomic, strong) NSDate *firstClickDate;
@property(nonatomic, assign) NSUInteger clickTimes;
@end

@implementation RCDAboutRongCloudTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.firstClickDate = nil;
        self.clickTimes = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPoweredView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.navigationItem.title = @"关于 SealTalk";

    RCDUIBarButtonItem *leftBtn =
    [[RCDUIBarButtonItem alloc] initWithLeftBarButton:@"我" target:self action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDBaseSettingTableViewCell";
    RCDBaseSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];

    static NSString *logoCellWithIdentifier = @"RCDLogoTableViewCell";
    RCDLogoTableViewCell *logoCell = [self.tableView dequeueReusableCellWithIdentifier:logoCellWithIdentifier];

    static NSString *versionCellWithIdentifier = @"RCDVersionCell";
    RCDVersionCell *versionCell = [self.tableView dequeueReusableCellWithIdentifier:versionCellWithIdentifier];

    if (cell == nil) {
        cell = [[RCDBaseSettingTableViewCell alloc] init];
    }
    if (logoCell == nil) {
        logoCell = [[RCDLogoTableViewCell alloc] init];
    }
    if (versionCell == nil) {
        versionCell = [[RCDVersionCell alloc] init];
    }
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0: {
            return logoCell;
        } break;

        case 1: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = @"更新日志";
            return cell;
        } break;

        case 2: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = @"功能介绍";
            return cell;
        } break;

        case 3: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = @"官方网站";
            return cell;
        } break;

        case 4: {
            [versionCell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
            versionCell.leftLabel.text = @"SealTalk 版本";
            NSString *SealTalkVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SealTalk Version"];
            versionCell.rightLabel.text = SealTalkVersion;
            NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
            if ([isNeedUpdate isEqualToString:@"YES"]) {
                [versionCell addNewImageView];
            }
            return versionCell;
        } break;

        case 5: {
            [cell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
            cell.leftLabel.text = @"SDK 版本";
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            cell.rightLabel.text = version;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        } break;

        default:
            break;
        }
    } break;

    default:
        break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    switch (indexPath.section) {
    case 0: {
        switch (indexPath.row) {
        case 0:
            height = 141.f;
            break;

        default:
            height = 44.f;
            break;
        }
    } break;

    default:
        break;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 取消选中
    NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
    if (indexPath.section == 0 && indexPath.row == 4) {
        if ([isNeedUpdate isEqualToString:@"YES"]) {
            NSString *finalURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"applistURL"];
            NSURL *applistURL = [NSURL URLWithString:finalURL];
            [[UIApplication sharedApplication] openURL:applistURL];
        }
    }
    if (indexPath.section == 0 && indexPath.row < 4) {
        NSURL *url = [self getUrlAt:indexPath];
        if (url) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }

    // force crash for test
    if (indexPath.section == 0 && indexPath.row == 5) {
        if (self.clickTimes == 0) {
            self.firstClickDate = [[NSDate alloc] init];
            self.clickTimes = 1;
        } else if ([self.firstClickDate timeIntervalSinceNow] > -3) {
            self.clickTimes++;
            if (self.clickTimes >= 5) {
                [self gotoDebugModel];
            }
        } else {
            self.clickTimes = 0;
            self.firstClickDate = nil;
        }
    }
}

- (void)gotoDebugModel {
    NSString *isDisplayID = @"显示ID";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"] isEqualToString:@"YES"]) {
        isDisplayID = @"关闭显示ID";
    }
    NSString *isDisplayOnlineStatus = @"显示在线状态";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayOnlineStatus"] isEqualToString:@"YES"]) {
        isDisplayOnlineStatus = @"关闭显示在线状态";
    }

    NSString *stayAfterJoinChatRoomFailed = @"加入聊天室失败仍停留在会话界面";
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"stayAfterJoinChatRoomFailed"] isEqualToString:@"YES"]) {
        stayAfterJoinChatRoomFailed = @"加入聊天室失败自动退出会话界面";
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Debug模式"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:@"强制Crash", isDisplayID, isDisplayOnlineStatus,
                                                            stayAfterJoinChatRoomFailed, @"设置离线消息补偿时间", @"设置全局免打扰时间", nil];
    alert.delegate = self;
    [alert show];
}

// force crash for test
- (void)forceCrash {
    NSMutableDictionary *crashArray = [[NSMutableDictionary alloc] initWithCapacity:0];
    [crashArray setObject:nil forKey:@"forCrash"];
}

- (void)setIsDisplayId {
    NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
    if ([isDisplayID isEqualToString:@"YES"]) {
        [DEFAULTS setObject:nil forKey:@"isDisplayID"];
        [DEFAULTS synchronize];
    } else {
        [DEFAULTS setObject:@"YES" forKey:@"isDisplayID"];
        [DEFAULTS synchronize];
    }
}

- (void)setIsDisplayOnlineStatus {
    NSString *isDisplayOnlineStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayOnlineStatus"];
    if ([isDisplayOnlineStatus isEqualToString:@"YES"]) {
        [DEFAULTS setObject:nil forKey:@"isDisplayOnlineStatus"];
        [DEFAULTS synchronize];
    } else {
        [DEFAULTS setObject:@"YES" forKey:@"isDisplayOnlineStatus"];
        [DEFAULTS synchronize];
    }
}

- (void)setStayAfterJoinChatRoomFailed {
    NSString *stayAfterJoinChatRoomFailed =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"stayAfterJoinChatRoomFailed"];
    if ([stayAfterJoinChatRoomFailed isEqualToString:@"YES"]) {
        [DEFAULTS setObject:nil forKey:@"stayAfterJoinChatRoomFailed"];
        [DEFAULTS synchronize];
    } else {
        [DEFAULTS setObject:@"YES" forKey:@"stayAfterJoinChatRoomFailed"];
        [DEFAULTS synchronize];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
    case 1:
        [self forceCrash];
        break;

    case 2:
        [self setIsDisplayId];
        break;

    case 3:
        [self setIsDisplayOnlineStatus];
        break;

    case 4:
        [self setStayAfterJoinChatRoomFailed];
        break;

    case 5:
        [self pushToDebugVC];
        break;
    case 6:
        [self pushToNoDisturbVC];
        break;
    default:
        break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setPoweredView {
    CGRect screenBounds = self.view.frame;
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.frame = CGRectMake(
        screenBounds.size.width / 2 - 100,
        screenBounds.size.height - 30 - 21 - self.navigationController.navigationBar.frame.size.height, 200, 21);
    footerLabel.text = @"Powered by RongCloud";
    [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
    [footerLabel setTextColor:[UIColor colorWithHexString:@"999999" alpha:1.0]];
    [self.view addSubview:footerLabel];
}

- (NSArray *)urls {
    if (!_urls) {
        NSArray *section0 =
            [NSArray arrayWithObjects:@"http://rongcloud.cn/", @"http://blog.rongcloud.cn/?page_id=1569",
                                      @"http://rongcloud.cn/features", @"http://rongcloud.cn/", nil];
        _urls = [NSArray arrayWithObjects:section0, nil];
    }
    return _urls;
}

- (NSURL *)getUrlAt:(NSIndexPath *)indexPath {
    NSArray *section = self.urls[indexPath.section];
    NSString *urlString = section[indexPath.row];
    if (!urlString.length) {
        return nil;
    }
    return [NSURL URLWithString:urlString];
}

- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewImageView:(RCDBaseSettingTableViewCell *)cell {
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new"]];
    newImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:newImageView];
    UILabel *leftLabel = cell.leftLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(leftLabel, newImageView);
    [cell.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftLabel]-10-[newImageView(50)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[newImageView(23)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:newImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}

- (void)pushToDebugVC {
    RCDDebugViewController *vc = [[RCDDebugViewController alloc] init];
    vc.title = @"设置离线消息补偿时间";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToNoDisturbVC {
    RCDDebugNoDisturbViewController *vc = [[RCDDebugNoDisturbViewController alloc] init];
    vc.title = @"设置全局免打扰";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
