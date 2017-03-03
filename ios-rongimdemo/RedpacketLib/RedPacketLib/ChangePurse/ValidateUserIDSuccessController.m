//
//  ValidateUserIDSuccessController.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/6/13.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "ValidateUserIDSuccessController.h"
#import "RedpacketDataRequester.h"
#import "RPRedpacketTool.h"


@interface ValidateUserIDSuccessController ()

@property (nonatomic, strong)   NSDictionary *userInfo;

@end

@implementation ValidateUserIDSuccessController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLable.text = @"验证身份信息";
    self.tableView.tableHeaderView = [self headerView];
    self.cuttingLineHidden = NO;
    [self loadUserValidateInfo];
}

- (void)loadUserValidateInfo
{
    [self.view rp_showHudWaitingView:YZHPromptTypeWating];
    rpWeakSelf;
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        [weakSelf.view rp_removeHudInManaual];
        weakSelf.userInfo = data;
        [weakSelf.tableView reloadData];
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        [weakSelf.view rp_showHudErrorView:error];
    }];
    
    [request fetchUserValidateState];
}

- (UIView *)headerView
{
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 186)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:rpRedpacketBundleImage(@"validate_IDCard_success")];
    [imageView sizeToFit];
    CGFloat y = (view.rp_height - imageView.rp_height ) / 2.0f - 10;
    CGFloat x = (view.rp_width - imageView.rp_width) / 2.0f;
    imageView.rp_top = y;
    imageView.rp_left = x;
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 10, width, 20)];
    label.textColor = [RedpacketColorStore rp_textColorBlack];
    label.font = [UIFont systemFontOfSize:15.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"身份信息已通过验证";
    
    [view addSubview:label];
    
    return view;
}

#pragma mark

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_userInfo) {
        return 2;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.detailTextLabel.textColor = [RedpacketColorStore rp_textColorGray];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"真实姓名";
        cell.detailTextLabel.text = [_userInfo rp_stringForKey:@"RealName"];
        
    }else {
        cell.textLabel.text = @"身份证";
        cell.detailTextLabel.text = [_userInfo rp_stringForKey:@"IDCard"];
    }
    
    return cell;
}

@end
