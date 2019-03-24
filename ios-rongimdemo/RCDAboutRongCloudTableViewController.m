//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "RCDBaseSettingTableViewCell.h"
#import "RCDLogoTableViewCell.h"
#import "RCDUIBarButtonItem.h"
#import "RCDVersionCell.h"
#import "UIColor+RCColor.h"
#import "RCDDebugTableViewController.h"

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

    self.navigationItem.title = RCDLocalizedString(@"about_sealtalk")
;

    RCDUIBarButtonItem *leftBtn =
    [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"me")
 target:self action:@selector(clickBackBtn:)];
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
            cell.leftLabel.text = RCDLocalizedString(@"update_log")
;
            return cell;
        } break;

        case 2: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"function_introduce")
;
            return cell;
        } break;

        case 3: {
            [cell setCellStyle:DefaultStyle];
            cell.leftLabel.text = RCDLocalizedString(@"offical_website")
;
            return cell;
        } break;

        case 4: {
            [versionCell setCellStyle:DefaultStyle_RightLabel_WithoutRightArrow];
            versionCell.leftLabel.text = RCDLocalizedString(@"SealTalk_version")
;
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
            cell.leftLabel.text = RCDLocalizedString(@"SDK_version")
;
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
    CGFloat height = 0;
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
    RCDDebugTableViewController *debugVC = [RCDDebugTableViewController new];
    [self.navigationController pushViewController:debugVC animated:YES];
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

@end
