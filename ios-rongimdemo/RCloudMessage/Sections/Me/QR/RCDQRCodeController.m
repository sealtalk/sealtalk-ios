//
//  RCDGroupQRCodeController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQRCodeController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDQRCodeManager.h"
#import "RCDUIBarButtonItem.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import "UIView+MBProgressHUD.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDForwardManager.h"
#import "RCDWeChatManager.h"
#import "NormalAlertView.h"
@interface RCDQRCodeController ()
@property (nonatomic, strong) UIView *qrBgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) UIView *shareBgView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *shareSealTalkBtn;
@property (nonatomic, strong) UIButton *shareWechatBtn;

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, strong) RCDGroupInfo *group;
@end

@implementation RCDQRCodeController
#pragma mark - life cycle
- (instancetype)initWithTargetId:(NSString *)targetId conversationType:(RCConversationType)type {
    if (self = [super init]) {
        self.targetId = targetId;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.group = [RCDGroupManager getGroupInfo:self.targetId];
    [self setDataInfo];
    [self setNaviItem];
    [self addSubViews];
}

#pragma mark - helper
- (void)setDataInfo {
    NSString *portraitUri, *name, *countInfo, *info, *qrInfo;
    if (self.type == ConversationType_GROUP) {
        portraitUri = self.group.portraitUri;
        name = self.group.groupName;
        if (!self.group.needCertification) {
            countInfo = [NSString stringWithFormat:@"%@ %@", self.group.number, RCDLocalizedString(@"Person")];
            info = RCDLocalizedString(@"GroupScanQRCodeInfo");
            qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://group/join?g=%@&u=%@", RCDQRCodeContentInfoUrl,
                                                self.targetId, [RCIMClient sharedRCIMClient].currentUserInfo.userId];
            self.countLabel.text = countInfo;
            self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
        }
    } else {
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.targetId];
        portraitUri = user.portraitUri;
        name = user.name;
        info = RCDLocalizedString(@"MyScanQRCodeInfo");
        qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://user/info?u=%@", RCDQRCodeContentInfoUrl,
                                            [RCIMClient sharedRCIMClient].currentUserInfo.userId];
        self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
    }
    if (![portraitUri isEqualToString:@""]) {
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                                  placeholderImage:[UIImage imageNamed:@"contact"]];
    }
    if (!self.portraitImageView.image) {
        self.portraitImageView.image = [DefaultPortraitView portraitView:self.targetId name:name];
    }
    self.nameLabel.text = name;
    self.infoLabel.text = info;
}

- (void)setNaviItem {
    if (self.type == ConversationType_GROUP) {
        self.navigationItem.title = RCDLocalizedString(@"GroupQR");
    } else {
        self.navigationItem.title = RCDLocalizedString(@"My_QR");
    }

    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickSaveAction {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                             message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                      preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self saveImageToPhotos:[self captureCurrentView:self.qrBgView]];
    }
}

- (void)didShareSealTalkAction {
    UIImage *image = [self captureCurrentView:self.qrBgView];
    RCImageMessage *msg = [RCImageMessage messageWithImage:image];
    msg.full = YES;
    RCMessage *message = [[RCMessage alloc] initWithType:self.type
                                                targetId:self.targetId
                                               direction:(MessageDirection_SEND)
                                               messageId:-1
                                                 content:msg];
    [[RCDForwardManager sharedInstance]
        setWillForwardMessageBlock:^(RCConversationType type, NSString *_Nonnull targetId) {
            [[RCIM sharedRCIM] sendMediaMessage:type
                targetId:targetId
                content:msg
                pushContent:nil
                pushData:nil
                progress:^(int progress, long messageId) {

                }
                success:^(long messageId) {

                }
                error:^(RCErrorCode errorCode, long messageId) {

                }
                cancel:^(long messageId){

                }];
        }];
    [RCDForwardManager sharedInstance].isForward = YES;
    [RCDForwardManager sharedInstance].isMultiSelect = NO;
    [RCDForwardManager sharedInstance].selectedMessages = @[ [RCMessageModel modelWithMessage:message] ];
    RCDForwardSelectedViewController *forwardSelectedVC = [[RCDForwardSelectedViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:forwardSelectedVC];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:navi animated:YES completion:nil];
}

- (void)didShareWechatBtnAction {
    if ([RCDWeChatManager weChatCanShared]) {
        UIImage *image = [self captureCurrentView:self.qrBgView];
        [[RCDWeChatManager sharedManager] sendImage:image atScene:WXSceneSession];
    } else {
        // 提示用户安装微信
        [NormalAlertView showAlertWithTitle:nil
                                    message:RCDLocalizedString(@"NotInstalledWeChat")
                              describeTitle:nil
                               confirmTitle:RCDLocalizedString(@"confirm")
                                    confirm:^{

                                    }];
    }
}

- (UIImage *)captureCurrentView:(UIView *)view {
    CGRect frame = view.frame;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)saveImageToPhotos:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoSuccess", @"RongCloudKit", nil)];
    } else {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoFailed", @"RongCloudKit", nil)];
    }
}

- (void)addSubViews {
    [self.view addSubview:self.qrBgView];
    [self.view addSubview:self.shareBgView];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self.view addSubview:lineView];
    [self.qrBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.offset(320);
        make.height.offset(370);
        make.top.equalTo(self.view).offset(45);
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(0.5);
        make.top.equalTo(self.qrBgView.mas_bottom);
    }];
    [self.shareBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.qrBgView);
        make.height.offset(50);
        make.top.equalTo(lineView.mas_bottom);
    }];

    if (self.type == ConversationType_GROUP && self.group.needCertification) {
        UILabel *label = [[UILabel alloc] init];
        label.text = RCDLocalizedString(@"GroupQrCodeCerTip");
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = HEXCOLOR(0x333333);
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.qrBgView).offset(45);
            make.centerX.equalTo(self.qrBgView);
            make.width.equalTo(self.qrBgView);
        }];
    }

    [self addQrBgViewSubviews];
    [self addShareBgViewSubviews];
}

- (void)addShareBgViewSubviews {
    [self.shareBgView addSubview:self.saveButton];
    [self.shareBgView addSubview:self.shareSealTalkBtn];
    [self.shareBgView addSubview:self.shareWechatBtn];
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self.shareBgView addSubview:lineView1];
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self.shareBgView addSubview:lineView2];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.shareBgView);
        make.width.offset(320 / 3);
    }];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.shareBgView);
        make.left.equalTo(self.saveButton.mas_right).offset(-0.5);
        make.width.offset(0.5);
    }];
    [self.shareSealTalkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.shareBgView);
        make.left.equalTo(self.saveButton.mas_right);
        make.right.equalTo(self.shareWechatBtn.mas_left);
    }];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.shareBgView);
        make.left.equalTo(self.shareSealTalkBtn.mas_right).offset(-0.5);
        make.width.offset(0.5);
    }];
    [self.shareWechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.shareBgView);
        make.width.offset(320 / 3);
    }];
}

- (void)addQrBgViewSubviews {
    [self.qrBgView addSubview:self.portraitImageView];
    [self.qrBgView addSubview:self.nameLabel];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self.qrBgView addSubview:lineView];

    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.qrBgView).offset(20);
        make.width.height.offset(50);
    }];

    if (self.type == ConversationType_GROUP) {
        if (self.group.needCertification) {
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(15);
                make.right.equalTo(self.qrBgView.mas_right).offset(-15);
                make.centerY.equalTo(self.portraitImageView);
                make.height.offset(28);
            }];

        } else {
            [self.qrBgView addSubview:self.qrCodeImageView];
            [self.qrBgView addSubview:self.countLabel];
            [self.qrBgView addSubview:self.infoLabel];
            [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(15);
                make.right.equalTo(self.qrBgView.mas_right).offset(-15);
                make.top.equalTo(self.qrBgView).offset(20);
                make.height.offset(28);
            }];

            [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.portraitImageView.mas_right).offset(15);
                make.right.equalTo(self.qrBgView.mas_right).offset(-15);
                make.bottom.equalTo(self.portraitImageView.mas_bottom);
                make.height.offset(20);
            }];
        }
    } else {
        [self.qrBgView addSubview:self.qrCodeImageView];
        [self.qrBgView addSubview:self.infoLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitImageView.mas_right).offset(15);
            make.right.equalTo(self.qrBgView.mas_right).offset(-15);
            make.centerY.equalTo(self.portraitImageView);
            make.height.offset(28);
        }];
    }

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrBgView);
        make.top.equalTo(self.qrBgView).offset(90);
        make.width.offset(280);
        make.height.offset(0.5);
    }];
    if (!self.group.needCertification) {
        [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.qrBgView);
            make.top.equalTo(self.qrBgView).offset(70);
            make.width.height.offset(280);
        }];
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.qrBgView);
            make.bottom.equalTo(self.qrBgView).offset(-21);
            make.height.offset(19);
            make.width.equalTo(self.qrBgView);
        }];
    }
}

#pragma mark - getter
- (UIView *)qrBgView {
    if (!_qrBgView) {
        _qrBgView = [[UIView alloc] init];
        _qrBgView.backgroundColor = [UIColor whiteColor];
    }
    return _qrBgView;
}

- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.layer.cornerRadius = 4;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = HEXCOLOR(0x262626);
        _nameLabel.font = [UIFont systemFontOfSize:20];
    }
    return _nameLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = HEXCOLOR(0x939393);
        _countLabel.font = [UIFont systemFontOfSize:14];
    }
    return _countLabel;
}

- (UIImageView *)qrCodeImageView {
    if (!_qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] init];
    }
    return _qrCodeImageView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = HEXCOLOR(0x939393);
        _infoLabel.font = [UIFont systemFontOfSize:13];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UIView *)shareBgView {
    if (!_shareBgView) {
        _shareBgView = [[UIView alloc] init];
        _shareBgView.backgroundColor = [UIColor whiteColor];
    }
    return _shareBgView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitleColor:HEXCOLOR(0x0099ff) forState:(UIControlStateNormal)];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_saveButton setTitle:RCDLocalizedString(@"SaveImage") forState:(UIControlStateNormal)];
        [_saveButton addTarget:self
                        action:@selector(didClickSaveAction)
              forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _saveButton;
}

- (UIButton *)shareSealTalkBtn {
    if (!_shareSealTalkBtn) {
        _shareSealTalkBtn = [[UIButton alloc] init];
        [_shareSealTalkBtn setTitleColor:HEXCOLOR(0x0099ff) forState:(UIControlStateNormal)];
        _shareSealTalkBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareSealTalkBtn setTitle:RCDLocalizedString(@"ShareToSealTalk") forState:(UIControlStateNormal)];
        [_shareSealTalkBtn addTarget:self
                              action:@selector(didShareSealTalkAction)
                    forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _shareSealTalkBtn;
}

- (UIButton *)shareWechatBtn {
    if (!_shareWechatBtn) {
        _shareWechatBtn = [[UIButton alloc] init];
        [_shareWechatBtn setTitleColor:HEXCOLOR(0x0099ff) forState:(UIControlStateNormal)];
        _shareWechatBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_shareWechatBtn setTitle:RCDLocalizedString(@"ShareToWeChat") forState:(UIControlStateNormal)];
        [_shareWechatBtn addTarget:self
                            action:@selector(didShareWechatBtnAction)
                  forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _shareWechatBtn;
}

@end
