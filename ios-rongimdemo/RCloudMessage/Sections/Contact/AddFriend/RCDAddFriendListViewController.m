//
//  RCDAddFriendListViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddFriendListViewController.h"
#import "RCDAddFriendListCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDQRCodeController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDWeChatManager.h"
#import "RCDSearchBar.h"
#import "RCDSearchFriendController.h"
#import "RCDScanQRCodeController.h"
#import "RCDSelectAddressBookViewController.h"
#import "RCDAddressBookFriendsViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDMyQRCodeView.h"
#import "RCDForwardSelectedViewController.h"

#define RCDAddFriendListCellIdentifier @"RCDAddFriendListCell"

@interface RCDAddFriendListViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,
                                              RCDWeChatManagerDelegate, UISearchBarDelegate, RCDMyQRCodeViewDelegate>

@property (nonatomic, strong) RCDSearchBar *searchBar;

@property (nonatomic, strong) UIView *myQRCodeView;
@property (nonatomic, strong) UILabel *myQRCodeLabel;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *detailArray;

@property (nonatomic, strong) RCDMyQRCodeView *QRCodeView;

@end

@implementation RCDAddFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self setupUI];
    [self setupData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDAddFriendListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RCDAddFriendListCellIdentifier];
    if (cell == nil) {
        cell = [[RCDAddFriendListCell alloc] init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.headerImgView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.titleLabel.text = RCDLocalizedString(self.titleArray[indexPath.row]);
    cell.detailLabel.text = RCDLocalizedString(self.detailArray[indexPath.row]);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0: {
        RCDAddressBookFriendsViewController *vc = [[RCDAddressBookFriendsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } break;
    case 1: {
        RCDScanQRCodeController *qrcodeVC = [[RCDScanQRCodeController alloc] init];
        [self.navigationController pushViewController:qrcodeVC animated:YES];
    } break;
    case 2: {
        [self showAlert:RCDLocalizedString(@"InviteWeChatFriend")
                   message:RCDLocalizedString(@"ToInviteWeChatFriend")
            cancelBtnTitle:RCDLocalizedString(@"cancel")
             otherBtnTitle:RCDLocalizedString(@"ConfirmBtnTitle")
                       tag:10001];
    } break;
    case 3: {
        RCDSelectAddressBookViewController *vc = [[RCDSelectAddressBookViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } break;
    default:
        break;
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    RCDSearchFriendController *searchFirendVC = [[RCDSearchFriendController alloc] init];
    [self.navigationController pushViewController:searchFirendVC animated:YES];
    return NO;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10001) {
        if (buttonIndex == 1) {
            [self shareUrlToWeChat];
        }
    }
}

#pragma mark - RCDWeChatManagerDelegate
- (void)wxSharedSucceed {
    [self.view showHUDMessage:RCDLocalizedString(@"ShareSuccess")];
}

- (void)wxSharedFailure {
    [self.view showHUDMessage:RCDLocalizedString(@"ShareFailure")];
}

#pragma mark - RCDMyQRCodeViewDelegate
- (void)myQRCodeViewShareSealTalk {
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"F2F2F3" alpha:1];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.myQRCodeView];
    [self.view addSubview:self.tableView];

    [self.myQRCodeView addSubview:self.myQRCodeLabel];
    [self.myQRCodeView addSubview:self.imgView];

    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.right.equalTo(self.view);
        make.height.offset(44);
    }];

    [self.myQRCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.myQRCodeView);
        make.height.offset(20);
    }];

    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.myQRCodeLabel.mas_right).offset(5);
        make.centerY.equalTo(self.myQRCodeLabel);
        make.height.width.offset(12);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(88);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)setupData {
    self.imageArray = @[ @"add_phonebook", @"add_scan", @"add_wechat", @"add_invite_phonebook" ];
    self.titleArray = @[ @"Phonebook_Title", @"Scan_Title", @"Wx_Title", @"Invite_Phonebook_Title" ];
    self.detailArray = @[ @"Phonebook_Detail", @"Scan_Detail", @"Wx_Detail", @"Invite_Phonebook_Detail" ];
    [RCDWeChatManager sharedManager].delegate = self;
}

- (void)showAlert:(NSString *)title
          message:(NSString *)message
   cancelBtnTitle:(NSString *)cBtnTitle
    otherBtnTitle:(NSString *)oBtnTitle
              tag:(int)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cBtnTitle
                                              otherButtonTitles:oBtnTitle, nil];
    if (tag > 0) {
        alertView.tag = tag;
    }
    [alertView show];
}

- (void)shareUrlToWeChat {
    UIImage *logoImage = [UIImage imageNamed:@"57x57_logo"];
    if ([RCDWeChatManager weChatCanShared]) {
        [[RCDWeChatManager sharedManager] sendLinkContent:RCDQRCodeContentInfoUrl
                                                    title:RCDLocalizedString(@"WXShare_RC_Title")
                                              description:RCDLocalizedString(@"WXShare_RC_Detail")
                                               thumbImage:logoImage
                                                  atScene:WXSceneSession];
    } else {
        [self showAlert:nil
                   message:RCDLocalizedString(@"NotInstalledWeChat")
            cancelBtnTitle:nil
             otherBtnTitle:RCDLocalizedString(@"ConfirmBtnTitle")
                       tag:0];
    }
}

#pragma mark - Target Action
- (void)tapMyQRCode {

    [self.QRCodeView show];

    [UIView animateWithDuration:0.2
                     animations:^{
                         self.QRCodeView.hidden = NO;
                     }];
}

#pragma mark - Setter && Getter
- (RCDSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[RCDSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = RCDLocalizedString(@"PhoneOrSealTalkNumber");
    }
    return _searchBar;
}

- (UIView *)myQRCodeView {
    if (!_myQRCodeView) {
        _myQRCodeView = [[UIView alloc] init];
        _myQRCodeView.backgroundColor = [UIColor colorWithHexString:@"F2F2F3" alpha:1];
        _myQRCodeView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyQRCode)];
        [_myQRCodeView addGestureRecognizer:tap];
    }
    return _myQRCodeView;
}

- (UILabel *)myQRCodeLabel {
    if (!_myQRCodeLabel) {
        _myQRCodeLabel = [[UILabel alloc] init];
        _myQRCodeLabel.font = [UIFont systemFontOfSize:14];
        _myQRCodeLabel.textColor = [UIColor colorWithHexString:@"333333" alpha:1];
        _myQRCodeLabel.text = RCDLocalizedString(@"My_QR");
    }
    return _myQRCodeLabel;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"add_qr_code"];
    }
    return _imgView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"FAFAFA" alpha:1];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (RCDMyQRCodeView *)QRCodeView {
    if (!_QRCodeView) {
        _QRCodeView = [[RCDMyQRCodeView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        _QRCodeView.hidden = YES;
        _QRCodeView.delegate = self;
    }
    return _QRCodeView;
}

@end
