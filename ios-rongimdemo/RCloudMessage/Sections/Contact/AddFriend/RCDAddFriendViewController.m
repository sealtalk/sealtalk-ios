//
//  RCDAddFriendViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAddFriendViewController.h"
#import "DefaultPortraitView.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "RCDUserInfoManager.h"

@interface RCDAddFriendViewController ()
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *portraitImgView;
@property(nonatomic, strong) UIButton *addFriendBtn;
@property(nonatomic, strong) UIButton *startChatBtn;
@end

@implementation RCDAddFriendViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavi];
    [self setupTableView];
    [self setHeaderData];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"add_contacts");
}

- (void)setupTableView {
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.tableView.separatorColor = HEXCOLOR(0xdfdfdf);
    [self setHeaderView];
    [self setFooterView];
}

- (void)setHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 86)];
    headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = headerView;
    
    [headerView addSubview:self.portraitImgView];
    [headerView addSubview:self.nameLabel];
    
    [self.portraitImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerView);
        make.left.equalTo(headerView).offset(10);
        make.height.width.offset(65);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.portraitImgView);
        make.left.equalTo(self.portraitImgView.mas_right).offset(8);
        make.right.equalTo(headerView).offset(-8);
        make.height.offset(20);
    }];
}

- (void)setHeaderData {
    self.nameLabel.text = self.targetUserInfo.name;
    if ([self.targetUserInfo.portraitUri isEqualToString:@""]) {
        UIImage *portrait = [DefaultPortraitView portraitView:self.targetUserInfo.userId name:self.targetUserInfo.name];
        self.portraitImgView.image = portrait;
    } else {
        [self.portraitImgView sd_setImageWithURL:[NSURL URLWithString:self.targetUserInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}

- (void)setFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 500)];
    self.tableView.tableFooterView = footerView;
    [footerView addSubview:self.addFriendBtn];
    [footerView addSubview:self.startChatBtn];
    
    [self.addFriendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(15);
        make.left.right.equalTo(footerView).inset(10);
        make.height.offset(43);
    }];
    
    [self.startChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.left.right.equalTo(self.addFriendBtn);
    }];
    
    NSMutableArray *cacheList = [[NSMutableArray alloc] initWithArray:[RCDUserInfoManager getAllFriends]];
    BOOL isFriend = NO;
    for (RCDFriendInfo *user in cacheList) {
        if ([user.userId isEqualToString:self.targetUserInfo.userId]) {
            isFriend = YES;
            break;
        }
    }
    if (isFriend == YES) {
        self.addFriendBtn.hidden = YES;
    } else {
        self.startChatBtn.hidden = YES;
    }
}

- (void)showAlertViewWith:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:RCDLocalizedString(@"confirm") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Target Action
- (void)addFriendAction:(id)sender {
    if (_targetUserInfo) {
        RCDFriendInfo *friend = [RCDUserInfoManager getFriendInfo:_targetUserInfo.userId];
        
        if (friend && friend.status == RCDFriendStatusRequest) {
            [self showAlertViewWith:RCDLocalizedString(@"friend_invite_had_send")];
        } else {
            [RCDUserInfoManager inviteFriend:_targetUserInfo.userId
                                 withMessage:[NSString stringWithFormat:@"我是%@", [RCIM sharedRCIM].currentUserInfo.name]
                                    complete:^(BOOL success) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (success) {
                                                [self showAlertViewWith:RCDLocalizedString(@"request_had_send")];
                                                [RCDUserInfoManager getFriendListFromServer:nil];
                                            } else {
                                                [self showAlertViewWith:RCDLocalizedString(@"request_fail_retry")];
                                            }
                                        });
                                    }];
        }
    };
}

- (void)startChatAction:(id)sender {
    RCDChatViewController *conversationVC = [[RCDChatViewController alloc] init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = self.targetUserInfo.userId;
    conversationVC.title = self.targetUserInfo.name;
    conversationVC.displayUserNameInCell = NO;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

#pragma mark - Setter && Getter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UIImageView *)portraitImgView {
    if (!_portraitImgView) {
        _portraitImgView = [[UIImageView alloc] init];
        if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
            [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
            _portraitImgView.layer.cornerRadius = 30.f;
        } else {
            _portraitImgView.layer.cornerRadius = 5.f;
        }
        _portraitImgView.clipsToBounds = YES;
        _portraitImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _portraitImgView;
}

- (UIButton *)addFriendBtn {
    if (!_addFriendBtn) {
        _addFriendBtn = [[UIButton alloc] init];
        [_addFriendBtn setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
        _addFriendBtn.layer.masksToBounds = YES;
        _addFriendBtn.layer.cornerRadius = 5.f;
        [_addFriendBtn setTitle:RCDLocalizedString(@"add_contacts") forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(addFriendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addFriendBtn;
}

- (UIButton *)startChatBtn {
    if (!_startChatBtn) {
        _startChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, self.view.bounds.size.width, 86)];
        [_startChatBtn setTitle:RCDLocalizedString(@"start_chat")
                       forState:UIControlStateNormal];
        [_startChatBtn setTintColor:[UIColor blackColor]];
        [_startChatBtn setBackgroundColor:[UIColor colorWithHexString:@"0099ff" alpha:1.0]];
        _startChatBtn.layer.masksToBounds = YES;
        _startChatBtn.layer.cornerRadius = 5.f;
        [_startChatBtn addTarget:self action:@selector(startChatAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startChatBtn;
}

@end
