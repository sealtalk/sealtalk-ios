//
//  RCDSearchFriendController.m
//  SealTalk
//
//  Created by 张改红 on 2019/2/28.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCDSearchFriendController.h"
#import "RCDIndicateTextField.h"
#import "DefaultPortraitView.h"
#import "RCDAddFriendViewController.h"
#import "RCDHttpTool.h"
#import "RCDPersonDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDSearchResultTableViewCell.h"
#import "RCDUserInfoManager.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
@interface RCDSearchFriendController ()<UITableViewDataSource, UITableViewDelegate, RCDCountryListControllerDelegate>
@property (nonatomic, strong) UITableView *resultTableView;
@property (nonatomic, strong) UIView *searchInfoView;
@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong) RCDCountry *currentRegion;
@end

@implementation RCDSearchFriendController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentCountry"]];
    [self addSubviews];
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")
                                                             style:(UIBarButtonItemStylePlain) target:self action:@selector(onCancelAction)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationItem.rightBarButtonItem.enabled = NO;;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLayoutSubviews {
    self.resultTableView.frame = self.view.bounds;
    self.searchInfoView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResult.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableCellWithIdentifier = @"RCDSearchResultTableViewCell";
    RCDSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell == nil) {
        cell = [[RCDSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    cell = [[RCDSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:reusableCellWithIdentifier];
    RCDUserInfo *user = self.searchResult[indexPath.row];
    if (user) {
        cell.lblName.text = user.name;
        if ([user.portraitUri isEqualToString:@""]) {
            DefaultPortraitView *defaultPortrait =
            [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
            UIImage *portrait = [defaultPortrait imageFromView];
            cell.ivAva.image = portrait;
        } else {
            [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                          placeholderImage:[UIImage imageNamed:@"icon_person"]];
        }
    }
    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDUserInfo *user = _searchResult[indexPath.row];
    RCUserInfo *userInfo = [RCUserInfo new];
    userInfo.userId = user.userId;
    userInfo.name = user.name;
    userInfo.portraitUri = user.portraitUri;
    
    if ([userInfo.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:RCDLocalizedString(@"can_not_add_self_to_address_book")
                                                       delegate:nil
                                              cancelButtonTitle:RCDLocalizedString(@"confirm")
                              
                                              otherButtonTitles:nil];
        [alert show];
    } else{
        NSMutableArray *cacheList =
        [[NSMutableArray alloc] initWithArray:[[RCDataBaseManager shareInstance] getAllFriends]];
        BOOL isFriend = NO;
        for (RCDUserInfo *tempInfo in cacheList) {
            if ([tempInfo.userId isEqualToString:user.userId] && [tempInfo.status isEqualToString:@"20"]) {
                isFriend = YES;
                break;
            }
        }
        if (isFriend == YES) {
            RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
            detailViewController.userId = user.userId;
            [self.navigationController pushViewController:detailViewController animated:YES];
        } else {
            RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
            addViewController.targetUserInfo = userInfo;
            [self.navigationController pushViewController:addViewController animated:YES];
        }
    }
}

#pragma mark - RCDCountryListControllerDelegate
- (void)fetchCountryPhoneCode:(RCDCountry *)country{
    self.currentRegion = country;
    self.countryTextField.textField.text = country.countryName;
    self.phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
}

#pragma mark - Target action
- (void)didTapCountryTextField{
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.showNavigationBarWhenBack = YES;
    countryListVC.delegate = self;
    [self.navigationController pushViewController:countryListVC animated:YES];
}

- (void)didSearchFriend{
    [self.searchResult removeAllObjects];
    NSString *searchText = self.phoneTextField.textField.text;
    if ([searchText length] > 0) {
        __weak typeof(self) weakSelf = self;
        [RCDHTTPTOOL
         searchUserByPhone:searchText region:self.currentRegion.phoneCode
         complete:^(NSMutableArray *result) {
             if (result && result.count > 0) {
                 for (RCDUserInfo *user in result) {
                     if ([user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                         [[RCDUserInfoManager shareInstance]
                          getUserInfo:user.userId
                          completion:^(RCUserInfo *user) {
                              [weakSelf.searchResult addObject:user];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [weakSelf showAndReloadResultTableView];
                              });
                          }];
                     } else {
                         [[RCDUserInfoManager shareInstance]
                          getFriendInfo:user.userId
                          completion:^(RCUserInfo *user) {
                              [weakSelf.searchResult addObject:user];
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [weakSelf showAndReloadResultTableView];
                              });
                          }];
                     }
                 }
             }else{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                 message:RCDLocalizedString(@"no_search_Friend")
                                                                delegate:nil
                                                       cancelButtonTitle:RCDLocalizedString(@"confirm")
                                       
                                                       otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
}

- (void)onCancelAction{
    [self hidenAndReloadResultTableView];
}

- (void)showAndReloadResultTableView{
    [self.phoneTextField.textField resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = YES;;
    [UIView animateWithDuration:0.2 animations:^{
        self.resultTableView.hidden = NO;
        self.searchInfoView.hidden = YES;
        [self.searchInfoView sendSubviewToBack:self.resultTableView];
        [self.resultTableView reloadData];
    }];
}

- (void)hidenAndReloadResultTableView{
    self.navigationItem.rightBarButtonItem.enabled = NO;;
    [UIView animateWithDuration:0.2 animations:^{
        self.resultTableView.hidden = YES;
        self.searchInfoView.hidden = NO;
        [self.searchInfoView bringSubviewToFront:self.resultTableView];
        [self.resultTableView reloadData];
    }];
}

#pragma mark - Subviews
- (void)addSubviews{
    [self.view addSubview:self.resultTableView];
    [self.view addSubview:self.searchInfoView];
    
    [self.searchInfoView addSubview:self.countryTextField];
    [self.searchInfoView addSubview:self.phoneTextField];
    UIButton *searchButton = [[UIButton alloc] init];
    [searchButton setTitleColor:HEXCOLOR(0x252525) forState:(UIControlStateNormal)];
    [searchButton setTitle:RCDLocalizedString(@"search") forState:(UIControlStateNormal)];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
    searchButton.layer.masksToBounds = YES;
    searchButton.layer.cornerRadius = 4;
    searchButton.layer.borderColor = [UIColor grayColor].CGColor;
    searchButton.layer.borderWidth = 1;
    [searchButton addTarget:self action:@selector(didSearchFriend) forControlEvents:(UIControlEventTouchUpInside)];
    [self.searchInfoView addSubview:searchButton];
    
    self.countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *view = NSDictionaryOfVariableBindings(_countryTextField,_phoneTextField,searchButton);
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_countryTextField(60)]-10-[_phoneTextField(60)]-20-[searchButton(30)]" options:0 metrics:nil views:view]];
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_countryTextField]-20-|" options:0 metrics:nil views:view]];
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|" options:0 metrics:nil views:view]];
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchButton(80)]-20-|" options:0 metrics:nil views:view]];
}

#pragma mark - Getters and setters
- (UITableView *)resultTableView{
    if (!_resultTableView) {
        _resultTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _resultTableView.backgroundColor= [UIColor whiteColor];
        _resultTableView.tableFooterView = [UIView new];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        _resultTableView.hidden = YES;
    }
    return _resultTableView;
}

- (UIView *)searchInfoView{
    if (!_searchInfoView) {
        _searchInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    }
    return _searchInfoView;
}

-(RCDIndicateTextField *)countryTextField{
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] initWithLineColor:[UIColor grayColor]];
        _countryTextField.indicateIcon.image = [UIImage imageNamed:@"right_arrow"];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.indicateInfoLabel.textColor = HEXCOLOR(0x252525);
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.textColor = HEXCOLOR(0x252525);
        _countryTextField.textField.userInteractionEnabled = NO;
        [_countryTextField indicateIconShow:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryTextField)];
        [_countryTextField addGestureRecognizer:tap];
        _countryTextField.userInteractionEnabled = YES;
    }
    return _countryTextField;
}

- (RCDIndicateTextField *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[RCDIndicateTextField alloc] initWithLineColor:[UIColor grayColor]];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@",self.currentRegion.phoneCode];
        _phoneTextField.indicateInfoLabel.textColor = HEXCOLOR(0x252525);
        _phoneTextField.textField.textColor = HEXCOLOR(0x252525);
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneTextField;
}

-(NSMutableArray *)searchResult{
    if (!_searchResult) {
        _searchResult = [NSMutableArray array];
    }
    return _searchResult;
}
@end
