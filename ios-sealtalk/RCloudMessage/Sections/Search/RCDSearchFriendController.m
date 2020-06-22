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
#import "RCDPersonDetailViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDUserInfoManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDCommonString.h"
#import "RCDUtilities.h"
@interface RCDSearchFriendController ()
@property (nonatomic, strong) UIView *searchInfoView;
@property (nonatomic, strong) RCDIndicateTextField *countryTextField;
@property (nonatomic, strong) RCDIndicateTextField *phoneTextField;
@property (nonatomic, strong) RCDCountry *currentRegion;
@end

@implementation RCDSearchFriendController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentRegion = [[RCDCountry alloc] initWithDict:[DEFAULTS objectForKey:RCDCurrentCountryKey]];
    [self addSubviews];
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutSubview:size];
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context){

        }];
}

- (void)layoutSubview:(CGSize)size {
    self.searchInfoView.frame = CGRectMake(0, 0, size.width, 200);
}

#pragma mark - Target action
- (void)didTapCountryTextField {
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.showNavigationBarWhenBack = YES;
    __weak typeof(self) weakSelf = self;
    [countryListVC setSelectCountryResult:^(RCDCountry *_Nonnull country) {
        weakSelf.currentRegion = country;
        weakSelf.countryTextField.textField.text = country.countryName;
        weakSelf.phoneTextField.indicateInfoLabel.text =
            [NSString stringWithFormat:@"+%@", weakSelf.currentRegion.phoneCode];
    }];
    [self.navigationController pushViewController:countryListVC animated:YES];
}

- (void)didSearchFriend {
    NSString *searchText = self.phoneTextField.textField.text;
    if ([searchText length] > 0) {

        NSString *currentPhoneNumber = [DEFAULTS objectForKey:RCDUserNameKey];
        NSString *currentSTAccount = [DEFAULTS objectForKey:RCDSealTalkNumberKey];

        if ([searchText isEqualToString:currentPhoneNumber] || [searchText isEqualToString:currentSTAccount]) {
            [self showAlertWithMessage:RCDLocalizedString(@"SearchUserIsCurrentUser")];
        } else {
            __weak typeof(self) weakSelf = self;
            if ([RCDUtilities isLowerLetter:searchText]) {
                [RCDUserInfoManager findUserByPhone:nil
                                             region:nil
                                        orStAccount:searchText
                                           complete:^(RCDUserInfo *userInfo) {
                                               [weakSelf pushVCWithUser:userInfo];
                                           }];
            } else {
                [RCDUserInfoManager findUserByPhone:searchText
                                             region:self.currentRegion.phoneCode
                                        orStAccount:nil
                                           complete:^(RCDUserInfo *userInfo) {
                                               [weakSelf pushVCWithUser:userInfo];
                                           }];
            }
        }
    } else {
        [self showAlertWithMessage:RCDLocalizedString(@"SearchEmptyHint")];
    }
}

- (void)pushVCWithUser:(RCDUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo) {
            RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:userInfo.userId];
            if (friend != nil && (friend.status == RCDFriendStatusAgree || friend.status == RCDFriendStatusBlock)) {
                RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
                detailViewController.userId = userInfo.userId;
                [self.navigationController pushViewController:detailViewController animated:YES];
            } else {
                [self pushAddFriendVC:userInfo];
            }
        } else {
            [self showAlertWithMessage:RCDLocalizedString(@"no_search_Friend")];
        }
    });
}

- (void)showAlertWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)pushAddFriendVC:(RCDUserInfo *)user {
    if ([user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        [self showAlertWithMessage:RCDLocalizedString(@"can_not_add_self_to_address_book")];
    } else {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserId = user.userId;
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

#pragma mark - Subviews
- (void)addSubviews {
    [self.view addSubview:self.searchInfoView];

    [self.searchInfoView addSubview:self.countryTextField];
    [self.searchInfoView addSubview:self.phoneTextField];
    UIButton *searchButton = [[UIButton alloc] init];
    [searchButton setTitleColor:RCDDYCOLOR(0x252525, 0x999999) forState:(UIControlStateNormal)];
    [searchButton setTitle:RCDLocalizedString(@"search") forState:(UIControlStateNormal)];
    searchButton.titleLabel.font = [UIFont systemFontOfSize:15];
    searchButton.layer.masksToBounds = YES;
    searchButton.layer.cornerRadius = 4;
    searchButton.layer.borderColor =
        [RCDUtilities generateDynamicColor:[UIColor grayColor]
                                 darkColor:[HEXCOLOR(0x808080) colorWithAlphaComponent:0.3]]
            .CGColor;
    searchButton.layer.borderWidth = 1;
    [searchButton addTarget:self action:@selector(didSearchFriend) forControlEvents:(UIControlEventTouchUpInside)];
    [self.searchInfoView addSubview:searchButton];

    self.countryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
    searchButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *view = NSDictionaryOfVariableBindings(_countryTextField, _phoneTextField, searchButton);
    [self.searchInfoView
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:
                               @"V:|-20-[_countryTextField(60)]-10-[_phoneTextField(60)]-20-[searchButton(30)]"
                                               options:0
                                               metrics:nil
                                                 views:view]];
    [self.searchInfoView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_countryTextField]-20-|"
                                                               options:0
                                                               metrics:nil
                                                                 views:view]];
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_phoneTextField]-20-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:view]];
    [self.searchInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[searchButton(80)]-20-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:view]];
}

#pragma mark - Getters and setters
- (UIView *)searchInfoView {
    if (!_searchInfoView) {
        _searchInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    }
    return _searchInfoView;
}

- (RCDIndicateTextField *)countryTextField {
    if (!_countryTextField) {
        _countryTextField = [[RCDIndicateTextField alloc] initWithLineColor:[UIColor grayColor]];
        _countryTextField.indicateIcon.image = [UIImage imageNamed:@"right_arrow"];
        _countryTextField.indicateInfoLabel.text = RCDLocalizedString(@"country");
        _countryTextField.indicateInfoLabel.textColor = RCDDYCOLOR(0x252525, 0x999999);
        _countryTextField.textField.text = self.currentRegion.countryName;
        _countryTextField.textField.textColor = RCDDYCOLOR(0x252525, 0x999999);
        _countryTextField.textField.userInteractionEnabled = NO;
        [_countryTextField indicateIconShow:YES];
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCountryTextField)];
        [_countryTextField addGestureRecognizer:tap];
        _countryTextField.userInteractionEnabled = YES;
    }
    return _countryTextField;
}

- (RCDIndicateTextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[RCDIndicateTextField alloc] initWithLineColor:[UIColor grayColor]];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.indicateInfoLabel.text = [NSString stringWithFormat:@"+%@", self.currentRegion.phoneCode];
        _phoneTextField.indicateInfoLabel.textColor = RCDDYCOLOR(0x252525, 0x999999);
        _phoneTextField.textField.textColor = RCDDYCOLOR(0x252525, 0x999999);
        _phoneTextField.userInteractionEnabled = YES;
        _phoneTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _phoneTextField.textField.adjustsFontSizeToFitWidth = YES;
        _phoneTextField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTextField.textField.textAlignment = NSTextAlignmentLeft;
        _phoneTextField.textField.placeholder = RCDLocalizedString(@"PhoneOrSealTalkNumber");
    }
    return _phoneTextField;
}

@end
