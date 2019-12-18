//
//  RCDMyQRCodeView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDMyQRCodeView.h"
#import <RongIMLib/RongIMLib.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DefaultPortraitView.h"
#import "RCDQRCodeManager.h"
#import "RCDUserInfoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+MBProgressHUD.h"
#import "RCDForwardSelectedViewController.h"
#import "RCDForwardManager.h"
#import "RCDWeChatManager.h"
#import "NormalAlertView.h"
@interface RCDMyQRCodeView ()

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

@end

@implementation RCDMyQRCodeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.targetId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        [self setupSubviews];
        [self setupData];
    }
    return self;
}

- (void)show {
    [[UIApplication sharedApplication].delegate.window addSubview:self];
}

- (void)hide {
    if ([NSThread isMainThread]) {
        [self removeFromSuperview];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}

#pragma mark - Target Action
- (void)tapAction {
    [self hide];
}

- (void)didClickSaveAction {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                             message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                      preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:nil]];
        [rootVC presentViewController:alertController animated:YES completion:nil];
    } else {
        [self saveImageToPhotos:[self captureCurrentView:self.qrBgView]];
    }
}

- (void)didShareSealTalkAction {
    UIImage *image = [self captureCurrentView:self.qrBgView];
    RCImageMessage *msg = [RCImageMessage messageWithImage:image];
    msg.full = YES;
    RCMessage *message = [[RCMessage alloc] initWithType:1
                                                targetId:[RCIM sharedRCIM].currentUserInfo.userId
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

    if ([self.delegate respondsToSelector:@selector(myQRCodeViewShareSealTalk)]) {
        [self.delegate myQRCodeViewShareSealTalk];
        [self hide];
    }
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

#pragma mark - Private Method
- (void)setupData {
    RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.targetId];
    NSString *portraitUri = user.portraitUri;
    NSString *name = user.name;
    NSString *info = RCDLocalizedString(@"MyScanQRCodeInfo");
    NSString *qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://user/info?u=%@", RCDQRCodeContentInfoUrl,
                                                  [RCIMClient sharedRCIMClient].currentUserInfo.userId];
    self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
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

- (void)setupSubviews {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];

    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.qrBgView];
    [self addSubview:self.shareBgView];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self addSubview:lineView];

    [self.qrBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.offset(320);
        make.height.offset(370);
    }];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(self.qrBgView);
        make.height.offset(0.5);
        make.top.equalTo(self.qrBgView.mas_bottom);
    }];

    [self.shareBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(self.qrBgView);
        make.height.offset(50);
        make.top.equalTo(lineView.mas_bottom);
    }];

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

    [self.qrBgView addSubview:self.qrCodeImageView];
    [self.qrBgView addSubview:self.infoLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.portraitImageView.mas_right).offset(15);
        make.right.equalTo(self.qrBgView.mas_right).offset(-15);
        make.centerY.equalTo(self.portraitImageView);
        make.height.offset(28);
    }];

    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.qrBgView);
        make.top.equalTo(self.qrBgView).offset(90);
        make.width.offset(280);
        make.height.offset(0.5);
    }];

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
        [self showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoSuccess", @"RongCloudKit", nil)];
    } else {
        [self showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoFailed", @"RongCloudKit", nil)];
    }
}

#pragma mark - Getter && Setter
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
