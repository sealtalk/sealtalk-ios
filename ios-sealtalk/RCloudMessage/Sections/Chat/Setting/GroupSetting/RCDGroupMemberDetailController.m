//
//  RCDMyInfoInGroupController.m
//  SealTalk
//
//  Created by 张改红 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDGroupMemberDetailController.h"
#import "RCDGroupMemberDetailCell.h"
#import <Masonry/Masonry.h>
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDGroupManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDUtilities.h"
@interface RCDGroupMemberDetailController () <RCDGroupMemberDetailCellDelegate>
@property (nonatomic, strong) NSArray *tableTitleArr;
@property (nonatomic, strong) NSArray *inputHolderArr;
@property (nonatomic, strong) NSMutableArray *describeArray;
@property (nonatomic, strong) RCDGroupMemberDetailInfo *memberDetail;
@property (nonatomic, strong) UITextView *editingView;
@property (nonatomic, assign) CGPoint startContentOffset;
@end

@implementation RCDGroupMemberDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCDLocalizedString(@"MyInfoInGroup");
    self.tableView.tableFooterView = [self setFooterView];
    BOOL isCurrentUser = [self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    self.tableTitleArr = @[
        @[
           isCurrentUser ? RCDLocalizedString(@"MyNicknameInGroup") : RCDLocalizedString(@"GroupNickname"),
           RCDLocalizedString(@"mobile_number"),
           RCDLocalizedString(@"WechatAccount"),
           RCDLocalizedString(@"AlipayAccount")
        ],
        @[ RCDLocalizedString(@"Describe") ].mutableCopy
    ];
    self.inputHolderArr = @[
        @[
           RCDLocalizedString(@"InputNicknameInGroup"),
           RCDLocalizedString(@"InputMobile"),
           RCDLocalizedString(@"InputWechatAccount"),
           RCDLocalizedString(@"InputAlipayAccount")
        ],
        @[ RCDLocalizedString(@"InputDescribe") ].mutableCopy
    ];
    UITapGestureRecognizer *resetBottomTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:resetBottomTapGesture];
    [self setNaviItem];
    [self getData];
    [self registerNotification];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableTitleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = self.tableTitleArr[section];
    return sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDGroupMemberDetailCell *cell = [RCDGroupMemberDetailCell cellWithTableView:tableView];
    NSArray *sections = self.tableTitleArr[indexPath.section];
    NSString *title = sections[indexPath.row];
    NSString *placeholder = self.inputHolderArr[indexPath.section][indexPath.row];
    if ([self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [cell setLeftTitle:title placeholder:placeholder];
    } else {
        [cell setLeftTitle:title placeholder:RCDLocalizedString(@"NotSetting")];
        cell.userInteractionEnabled = NO;
    }
    [cell showClearButton:NO];
    cell.textView.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if ([title isEqualToString:RCDLocalizedString(@"mobile_number")]) {
        if (self.memberDetail.region.length == 0) {
            self.memberDetail.region = @"86";
        }
        cell.textView.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPhoneRegionCode:self.memberDetail.region];
        [cell setDetailInfo:self.memberDetail.phone];
    } else if ([title isEqualToString:RCDLocalizedString(@"MyNicknameInGroup")] ||
               [title isEqualToString:RCDLocalizedString(@"GroupNickname")]) {
        [cell setDetailInfo:self.memberDetail.groupNickname];
    } else if ([title isEqualToString:RCDLocalizedString(@"WechatAccount")]) {
        [cell setDetailInfo:self.memberDetail.weChatAccount];
    } else if ([title isEqualToString:RCDLocalizedString(@"AlipayAccount")]) {
        [cell setDetailInfo:self.memberDetail.alipayAccount];
    } else if ([title isEqualToString:RCDLocalizedString(@"Describe")]) {
        if (self.describeArray && self.describeArray.count > indexPath.row) {
            [cell setDetailInfo:self.describeArray[indexPath.row]];
        }
        if ([self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            [cell showClearButton:YES];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = self.tableTitleArr[indexPath.section];
    NSString *title = sections[indexPath.row];
    NSString *text;
    if ([title isEqualToString:RCDLocalizedString(@"mobile_number")]) {
        text = self.memberDetail.phone;
    } else if ([title isEqualToString:RCDLocalizedString(@"MyNicknameInGroup")] ||
               [title isEqualToString:RCDLocalizedString(@"GroupNickname")]) {
        text = self.memberDetail.groupNickname;
    } else if ([title isEqualToString:RCDLocalizedString(@"WechatAccount")]) {
        text = self.memberDetail.weChatAccount;
    } else if ([title isEqualToString:RCDLocalizedString(@"AlipayAccount")]) {
        text = self.memberDetail.alipayAccount;
    } else if ([title isEqualToString:RCDLocalizedString(@"Describe")]) {
        if (self.describeArray && self.describeArray.count > indexPath.row) {
            text = self.describeArray[indexPath.row];
        }
    }
    return [RCDGroupMemberDetailCell getCellHeight:tableView leftTitle:title text:text];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && [self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RCDLocalizedString(@"DescribeRemove");
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *sections = self.tableTitleArr[indexPath.section];
        if (sections.count > 1) {
            [self.tableTitleArr[1] removeObjectAtIndex:indexPath.row];
            [self.inputHolderArr[1] removeObjectAtIndex:indexPath.row];
            [self.describeArray removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        } else {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoDescribeGreaterOne")];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
}

#pragma mark - RCDGroupMyInfoCellDelegate
- (void)textViewWillBeginEditing:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell {
    if (![self.editingView isFirstResponder]) {
        self.startContentOffset = self.tableView.contentOffset;
    }
    self.editingView = textView;
    CGRect textBounds =
        [self.editingView convertRect:self.editingView.frame toView:[UIApplication sharedApplication].keyWindow];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 1) {
        textBounds.size.height = 100;
    }
    CGFloat space = CGRectGetMaxY(textBounds) - ([UIApplication sharedApplication].keyWindow.bounds.size.height - 300);
    if (space > 0) {
        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentOffset.y + space);
    }
}

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text
                     inCell:(RCDGroupMemberDetailCell *)cell {
    //不支持系统表情的输入
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
        [RCDUtilities stringContainsEmoji:text]) {
        [self.view showHUDMessage:RCDLocalizedString(@"NotSupportedEmojiInput")];
        return NO;
    }

    //超出指定长度，输入不生效
    NSString *replacedText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *sections = self.tableTitleArr[indexPath.section];
    NSString *title = sections[indexPath.row];
    if ([title isEqualToString:RCDLocalizedString(@"mobile_number")]) {
        if (replacedText.length > 11) {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoPhoneMaxTip")];
            return NO;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"MyNicknameInGroup")] ||
               [title isEqualToString:RCDLocalizedString(@"GroupNickname")]) {
        if (replacedText.length > 16) {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupNicknameMaxTip")];
            return NO;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"WechatAccount")]) {
        if (replacedText.length > 20) {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoWechatMaxTip")];
            return NO;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"AlipayAccount")]) {
        if (replacedText.length > 20) {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoAlipayMaxTip")];
            return NO;
        }
    } else if ([title isEqualToString:RCDLocalizedString(@"Describe")]) {
        if (replacedText.length > 70) {
            [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoDescribeMaxTip")];
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell {
    if (textView.markedTextRange != nil) {
        NSString *repalceText = [textView textInRange:textView.markedTextRange];
        if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"] ||
            [RCDUtilities stringContainsEmoji:repalceText]) {
            [self.view showHUDMessage:RCDLocalizedString(@"NotSupportedEmojiInput")];
            [textView replaceRange:textView.markedTextRange withText:@""];
            return;
        }
    }
    [self updateMemberDetail:textView inCell:cell];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    // cell 高度随textView输入而变化
    CGRect bounds = textView.bounds;
    BOOL isUpdate = bounds.size.height != textView.contentSize.height;
    if (isUpdate) {
        CGSize newSize = CGSizeMake(textView.frame.size.width, textView.contentSize.height);
        bounds.size = newSize;
        [UIView performWithoutAnimation:^{
            textView.bounds = bounds;
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell {
    [self updateMemberDetail:textView inCell:cell];
}

- (void)onSelectPhoneRegionCode:(RCDGroupMemberDetailCell *)cell {
    if (![self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return;
    }
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.showNavigationBarWhenBack = YES;
    __weak typeof(self) weakSelf = self;
    [countryListVC setSelectCountryResult:^(RCDCountry *_Nonnull country) {
        [cell setPhoneRegionCode:country.phoneCode];
        weakSelf.memberDetail.region = country.phoneCode;
    }];
    [self.navigationController pushViewController:countryListVC animated:YES];
}

#pragma mark - Notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect textBounds =
        [self.editingView convertRect:self.editingView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGFloat space = CGRectGetMaxY(textBounds) - ([UIApplication sharedApplication].keyWindow.bounds.size.height - 300);
    if (space > 0) {
        self.tableView.contentOffset = CGPointMake(0, self.startContentOffset.y + space);
    }
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notif {
    self.tableView.contentOffset = self.startContentOffset;
}

#pragma mark - hepler
- (void)hideKeyboard {
    if ([self.editingView isFirstResponder]) {
        [self.editingView resignFirstResponder];
    }
}

- (void)setNaviItem {
    if (![self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        self.title = RCDLocalizedString(@"Personal_information");
        return;
    }
    //创建rightBarButtonItem
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"done")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(clickDoneBtn)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)clickDoneBtn {
    [self hideKeyboard];
    RCNetworkStatus status = [[RCIMClient sharedRCIMClient] getCurrentNetworkStatus];
    if (RC_NotReachable == status) {
        [self.view showHUDMessage:RCDLocalizedString(@"network_can_not_use_please_check")];
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in self.describeArray) {
        if (str.length > 0) {
            [array addObject:str];
        }
    }
    self.memberDetail.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    self.memberDetail.describeArray = array.copy;
    if (self.memberDetail.phone.length <= 0) {
        self.memberDetail.region = @"";
    }
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [RCDGroupManager
        setGroupMemberDetailInfo:self.memberDetail
                         groupId:self.groupId
                        complete:^(BOOL success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                if (success) {
                                    weakSelf.updateMemberDetail();
                                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"SetGroupMyInfoSuccess")];
                                    [weakSelf.navigationController popViewControllerAnimated:YES];
                                } else {
                                    [weakSelf.view showHUDMessage:RCDLocalizedString(@"Failed")];
                                }
                            });
                        }];
}

- (void)getData {
    self.memberDetail = [RCDGroupManager getGroupMemberDetailInfo:self.userId groupId:self.groupId];
    [self describeArray];
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupMemberDetailInfoFromServer:self.userId
                                                groupId:self.groupId
                                               complete:^(RCDGroupMemberDetailInfo *member) {
                                                   if (member) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           weakSelf.memberDetail = member;
                                                           weakSelf.describeArray = nil;
                                                           [weakSelf describeArray];
                                                           [weakSelf.tableView reloadData];
                                                       });
                                                   }
                                               }];
}

- (void)updateMemberDetail:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *sections = self.tableTitleArr[indexPath.section];
    NSString *title = sections[indexPath.row];
    if ([title isEqualToString:RCDLocalizedString(@"mobile_number")]) {
        self.memberDetail.phone = textView.text;
    } else if ([title isEqualToString:RCDLocalizedString(@"MyNicknameInGroup")] ||
               [title isEqualToString:RCDLocalizedString(@"GroupNickname")]) {
        self.memberDetail.groupNickname = textView.text;
    } else if ([title isEqualToString:RCDLocalizedString(@"WechatAccount")]) {
        self.memberDetail.weChatAccount = textView.text;
    } else if ([title isEqualToString:RCDLocalizedString(@"AlipayAccount")]) {
        self.memberDetail.alipayAccount = textView.text;
    } else if ([title isEqualToString:RCDLocalizedString(@"Describe")]) {
        if (![self.describeArray[indexPath.row] isEqual:textView.text]) {
            [self.describeArray removeObjectAtIndex:indexPath.row];
            [self.describeArray insertObject:textView.text ? textView.text : @"" atIndex:indexPath.row];
        }
    }
}

- (void)didClickAddButton {
    if (((NSArray *)self.tableTitleArr[1]).count < 10) {
        [self.tableTitleArr[1] addObject:RCDLocalizedString(@"Describe")];
        [self.inputHolderArr[1] addObject:RCDLocalizedString(@"InputDescribe")];
        [self.describeArray addObject:@""];
        [self.tableView insertRowsAtIndexPaths:@[
            [NSIndexPath indexPathForRow:((NSArray *)self.tableTitleArr[1]).count - 1 inSection:1]
        ]
                              withRowAnimation:(UITableViewRowAnimationFade)];
    } else {
        [self.view showHUDMessage:RCDLocalizedString(@"GroupMyInfoDescribeCountOver")];
    }
}

- (UIView *)setFooterView {
    if (![self.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        return [UIView new];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    view.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                    darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = RCDDYCOLOR(0xe5e5e5, 0x1a1a1a);
    [view addSubview:lineView];
    UILabel *add = [[UILabel alloc] init];
    add.textColor = HEXCOLOR(0x0099ff);
    add.font = [UIFont systemFontOfSize:30];
    add.textAlignment = NSTextAlignmentRight;
    add.text = RCDLocalizedString(@"+");
    [view addSubview:add];
    UILabel *info = [[UILabel alloc] init];
    info.textColor = HEXCOLOR(0x0099ff);
    info.font = [UIFont systemFontOfSize:15];
    info.text = RCDLocalizedString(@"AddDescribe");
    [view addSubview:info];

    [add mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.height.equalTo(view).offset(-3);
        make.right.equalTo(info.mas_left).offset(-10);
    }];
    [info mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(view);
        make.centerX.equalTo(view).offset(30);
    }];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickAddButton)];
    [view addGestureRecognizer:tap];
    return view;
}

#pragma mark - getter
- (RCDGroupMemberDetailInfo *)memberDetail {
    if (!_memberDetail) {
        _memberDetail = [[RCDGroupMemberDetailInfo alloc] init];
        _memberDetail.region = @"86";
    }
    return _memberDetail;
}

- (NSMutableArray *)describeArray {
    if (!_describeArray) {
        _describeArray = [NSMutableArray arrayWithArray:self.memberDetail.describeArray];
        if (_describeArray.count == 0) {
            [_describeArray addObject:@""];
        }
        NSMutableArray *array = self.tableTitleArr[1];
        while (array.count < _describeArray.count) {
            [array addObject:RCDLocalizedString(@"Describe")];
            [self.inputHolderArr[1] addObject:RCDLocalizedString(@"InputDescribe")];
        }
    }
    return _describeArray;
}
@end
