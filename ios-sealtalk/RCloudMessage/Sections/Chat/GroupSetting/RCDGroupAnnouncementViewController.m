//
//  RCDGroupAnnouncementViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupAnnouncementViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import "UITextViewAndPlaceholder.h"
#import "RCDGroupManager.h"
#import "Masonry.h"
#import "NormalAlertView.h"
#import "RCDUtilities.h"
#import "UIView+MBProgressHUD.h"
#define AnnouncementMaxCount 100

@interface RCDGroupAnnouncementViewController ()
@property (nonatomic, strong) UITextViewAndPlaceholder *announcementContent;
@property (nonatomic, assign) CGFloat textViewOriginalHeight;
@property (nonatomic, strong) UILabel *guideLabel;
@property (nonatomic, strong) UILabel *updateTime;
@property (nonatomic, strong) RCDGroupAnnouncement *announce;
@end

@implementation RCDGroupAnnouncementViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = RCDLocalizedString(@"group_announcement");

    [self setNaviItem];
    [self registerNotification];
    [self setData];
    [self setupView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > AnnouncementMaxCount) {
        textView.text = [textView.text substringToIndex:AnnouncementMaxCount];
        [self.view showHUDMessage:RCDLocalizedString(@"AnnouncementOverMaxCount")];
    }
    if ([textView.text isEqualToString:self.announce.content]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - helper
- (void)sendAnnouncement {
    //发布中的时候显示转圈的进度
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -46.f;
    hud.minSize = CGSizeMake(120, 120);
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    hud.margin = 0;
    [hud show:YES];
    //发布成功后，使用自定义图片
    NSString *txt = self.announcementContent.text;
    //去除收尾的空格
    txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //去除收尾的换行
    txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [RCDGroupManager
        publishGroupAnnouncement:txt
                         groupId:self.groupId
                        complete:^(BOOL success) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (success) {
                                    hud.mode = MBProgressHUDModeCustomView;
                                    UIImageView *customView =
                                        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete"]];
                                    customView.frame = CGRectMake(0, 0, 80, 80);
                                    hud.customView = customView;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                                                   dispatch_get_main_queue(), ^{
                                                       //显示成功的图片后返回
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                   });
                                } else {
                                    [hud hide:YES];
                                    [NormalAlertView
                                        showAlertWithMessage:RCDLocalizedString(@"Group_announcement_failed_to_be_sent")
                                               highlightText:nil
                                                   leftTitle:nil
                                                  rightTitle:RCDLocalizedString(@"confirm")
                                                      cancel:nil
                                                     confirm:nil];
                                }
                            });
                        }];
}

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

//键盘将要弹出
- (void)keyboardWillShow:(NSNotification *)aNotification {
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    [self.announcementContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.right.equalTo(self.view).offset(-14);
        make.top.equalTo(self.updateTime.mas_bottom).offset(5);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-keyboardRect.size.height);
        } else {
            make.bottom.equalTo(self.view).offset(-keyboardRect.size.height);
        }
    }];
}

//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self.announcementContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.right.equalTo(self.view).offset(-14);
        make.top.equalTo(self.updateTime.mas_bottom).offset(5);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
}

- (void)clickLeftBtn:(id)sender {
    [self.announcementContent resignFirstResponder];
    if (self.announce && ![self.announcementContent.text isEqualToString:self.announce.content]) {
        [NormalAlertView showAlertWithMessage:RCDLocalizedString(@"Exit_this_edit")
            highlightText:nil
            leftTitle:RCDLocalizedString(@"Continue_editing")
            rightTitle:RCDLocalizedString(@"quit")
            cancel:^{

            }
            confirm:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickRightBtn:(id)sender {
    [self.announcementContent resignFirstResponder];
    if (self.announce && self.announce.content && self.announcementContent.text.length == 0) {
        [NormalAlertView showAlertWithMessage:RCDLocalizedString(@"AnnouncementClear")
            highlightText:@""
            leftTitle:RCDLocalizedString(@"cancel")
            rightTitle:RCDLocalizedString(@"confirm")
            cancel:^{

            }
            confirm:^{
                [self sendAnnouncement];
            }];
    } else {
        [NormalAlertView
            showAlertWithMessage:RCDLocalizedString(@"The_announcement_will_notify_all_members_of_the_group")
            highlightText:@""
            leftTitle:RCDLocalizedString(@"cancel")
            rightTitle:RCDLocalizedString(@"Publish")
            cancel:^{

            }
            confirm:^{
                [self sendAnnouncement];
            }];
    }
}

- (void)setNaviItem {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"done")
                                                                    style:(UIBarButtonItemStylePlain)
                                                                   target:self
                                                                   action:@selector(clickRightBtn:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"cancel")
                                                                   style:(UIBarButtonItemStylePlain)
                                                                  target:self
                                                                  action:@selector(clickLeftBtn:)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)didTap {
    [self.announcementContent resignFirstResponder];
}

- (void)setData {
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupAnnouncement:self.groupId
                                 complete:^(RCDGroupAnnouncement *announce) {
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         weakSelf.announce = announce;
                                         if (announce) {
                                             if (announce.content > 0) {
                                                 weakSelf.announcementContent.text = announce.content;
                                             }
                                         }
                                         weakSelf.updateTime.text = [NSString
                                             stringWithFormat:RCDLocalizedString(@"AnnouncementTime"),
                                                              [RCDUtilities getDataString:announce.publishTime]];
                                     });
                                 }];
}

- (void)setupView {
    [self.view addSubview:self.guideLabel];
    [self.view addSubview:self.updateTime];
    [self.view addSubview:self.announcementContent];
    [self.guideLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(18);
        make.right.equalTo(self.view).offset(-18);
        make.top.equalTo(self.view).offset(12);
    }];
    [self.updateTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(18);
        make.right.equalTo(self.view).offset(-18);
        make.top.equalTo(self.guideLabel.mas_bottom).offset(5);
    }];
    [self.announcementContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(14);
        make.right.equalTo(self.view).offset(-14);
        make.top.equalTo(self.updateTime.mas_bottom).offset(5);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    self.textViewOriginalHeight = self.announcementContent.frame.size.height;
}

#pragma mark - geter & setter
- (UITextViewAndPlaceholder *)announcementContent {
    if (!_announcementContent) {
        _announcementContent = [[UITextViewAndPlaceholder alloc] initWithFrame:CGRectZero];
        _announcementContent.delegate = self;
        _announcementContent.font = [UIFont systemFontOfSize:16.f];
        _announcementContent.textColor = RCDDYCOLOR(0x000000, 0xffffff);
        _announcementContent.myPlaceholder = RCDLocalizedString(@"Please_edit_the_group_announcement");
    }
    return _announcementContent;
}

- (UILabel *)guideLabel {
    if (!_guideLabel) {
        _guideLabel = [[UILabel alloc] init];
        _guideLabel.textColor = HEXCOLOR(0x939393);
        _guideLabel.font = [UIFont systemFontOfSize:14];
        _guideLabel.text = RCDLocalizedString(@"AnnouncementGuide");
    }
    return _guideLabel;
}

- (UILabel *)updateTime {
    if (!_updateTime) {
        _updateTime = [[UILabel alloc] init];
        _updateTime.textColor = HEXCOLOR(0x939393);
        _updateTime.font = [UIFont systemFontOfSize:14];
    }
    return _updateTime;
}
@end
