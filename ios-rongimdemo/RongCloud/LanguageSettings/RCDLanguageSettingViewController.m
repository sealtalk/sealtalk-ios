//
//  RCDLanguageSettingViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/2/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLanguageSettingViewController.h"
#import "AppDelegate.h"
#import "RCDLanguageManager.h"
#import "RCDMainTabBarViewController.h"
#import "RCDNavigationViewController.h"
#import "UIColor+RCColor.h"
#import "RCDLanguageSettingTableViewCell.h"

@interface RCDLanguageSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *currentLanguage;
@property (nonatomic, strong) NSDictionary *languageDic;

@end

@implementation RCDLanguageSettingViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = RCDLocalizedString(@"language");
    self.languageDic = @{@"en":@"English", @"zh-Hans":@"简体中文"};
    [self.view addSubview:self.tableView];
    
    self.language = [RCDLanguageManager sharedRCDLanguageManager].localzableLanguage;
    self.currentLanguage = self.language;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:RCDLocalizedString(@"save") style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    [rightBarButtonItem setTintColor:[UIColor colorWithHexString:@"3A91F3" alpha:0.4]];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void)viewDidLayoutSubviews{
    self.tableView.frame = self.view.bounds;
    [self.tableView reloadData];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"current language %@", self.languageDic.allValues[indexPath.row]);
    
    self.language = self.languageDic.allKeys[indexPath.row];
    
    if ([self.language containsString:self.currentLanguage]) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithHexString:@"3A91F3" alpha:0.4]];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        [self.navigationItem.rightBarButtonItem setTintColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc]init];
    header.contentView.backgroundColor = [UIColor colorWithHexString:@"f0f0f6" alpha:1.f];;
    
    return header;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCELanguageSettingViewControllerCell";
    RCDLanguageSettingTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDLanguageSettingTableViewCell alloc] init];
    }
    NSString * key = self.languageDic.allKeys[indexPath.row];
    cell.leftLabel.text = [self.languageDic valueForKey:key];
    cell.rightImageView.image = [key containsString:self.language] ? [UIImage imageNamed:@"select"] : nil;
    return cell;
}

#pragma mark - Target action
- (void)save {
    //设置当前语言
    [[RCDLanguageManager sharedRCDLanguageManager] setLocalizableLanguage:self.language];
    
    //重置vc堆栈
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RCDMainTabBarViewController *mainTabBarVC = [[RCDMainTabBarViewController alloc] init];
    RCDNavigationViewController *nav = [[RCDNavigationViewController alloc] initWithRootViewController:mainTabBarVC];
    mainTabBarVC.selectedIndex = 3;
    app.window.rootViewController = nav;
}

#pragma mark - Getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
