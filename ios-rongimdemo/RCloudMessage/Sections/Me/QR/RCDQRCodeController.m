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

@interface RCDQRCodeController ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *qrCodeImageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, assign) RCConversationType type;
@end

@implementation RCDQRCodeController
#pragma mark - life cycle
- (instancetype)initWithTargetId:(NSString *)targetId conversationType:(RCConversationType)type{
    if (self = [super init]) {
        self.targetId = targetId;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xf2f2f3);
    [self setNaviItem];
    [self addSubViews];
    [self setDataInfo];
}

#pragma mark - helper
- (void)setDataInfo{
    NSString *portraitUri, *name, *countInfo, *info, *qrInfo;
    if (self.type == ConversationType_GROUP) {
        RCDGroupInfo *group = [RCDGroupManager getGroupInfo:self.targetId];
        portraitUri = group.portraitUri;
        name = group.groupName;
        countInfo = [NSString stringWithFormat:@"%@ %@",group.number,RCDLocalizedString(@"Person")];
        info = RCDLocalizedString(@"GroupScanQRCodeInfo");
        qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://group/join?g=%@&u=%@",RCDQRCodeContentInfoUrl,self.targetId,[RCIMClient sharedRCIMClient].currentUserInfo.userId];

    }else{
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:self.targetId];
        portraitUri = user.portraitUri;
        name = user.name;
        info = RCDLocalizedString(@"MyScanQRCodeInfo");
        qrInfo = [NSString stringWithFormat:@"%@?key=sealtalk://user/info?u=%@",RCDQRCodeContentInfoUrl,[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    }
    if (![portraitUri isEqualToString:@""]) {
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
    }
    if (!self.portraitImageView.image) {
        self.portraitImageView.image = [DefaultPortraitView portraitView:self.targetId name:name];
    }
    self.nameLabel.text = name;
    self.countLabel.text = countInfo;
    self.infoLabel.text = info;
    self.qrCodeImageView.image = [RCDQRCodeManager getQRCodeImage:qrInfo];
}

- (void)setNaviItem{
    if (self.type == ConversationType_GROUP) {
        self.navigationItem.title = RCDLocalizedString(@"GroupQR");
    }else{
        self.navigationItem.title = RCDLocalizedString(@"My_QR");
    }
    
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back") target:self action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)clickBackBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickSaveAction{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied){
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil) message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [self saveImageToPhotos:[self captureCurrentView:self.bgView]];
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
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoSuccess", @"RongCloudKit", nil)];
    } else {
        [self.view showHUDMessage:NSLocalizedStringFromTable(@"SavePhotoFailed", @"RongCloudKit", nil)];
    }
}

- (void)addSubViews{
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.saveButton];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.offset(320);
        make.height.offset(370);
        make.top.equalTo(self.view).offset(45);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.offset(19);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuide).offset(-20);
        } else {
            make.bottom.equalTo(self.view).offset(-20);
        }
    }];
    
    [self.bgView addSubview:self.portraitImageView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.qrCodeImageView];
    [self.bgView addSubview:self.infoLabel];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEXCOLOR(0xe5e5e5);
    [self.bgView addSubview:lineView];
    
    [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.bgView).offset(20);
        make.width.height.offset(50);
    }];
    
    if (self.type == ConversationType_GROUP) {
        [self.bgView addSubview:self.countLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitImageView.mas_right).offset(15);
            make.right.equalTo(self.bgView.mas_right).offset(-15);
            make.top.equalTo(self.bgView).offset(20);
            make.height.offset(28);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitImageView.mas_right).offset(15);
            make.right.equalTo(self.bgView.mas_right).offset(-15);
            make.bottom.equalTo(self.portraitImageView.mas_bottom);
            make.height.offset(20);
        }];
    }else{
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.portraitImageView.mas_right).offset(15);
            make.right.equalTo(self.bgView.mas_right).offset(-15);
            make.centerY.equalTo(self.portraitImageView);
            make.height.offset(28);
        }];
    }
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(90);
        make.width.offset(280);
        make.height.offset(0.5);
    }];
    
    [self.qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.top.equalTo(self.bgView).offset(70);
        make.width.height.offset(280);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView);
        make.bottom.equalTo(self.bgView).offset(-21);
        make.height.offset(19);
        make.width.equalTo(self.bgView);
    }];
}

#pragma mark - getter
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

- (UIImageView *)portraitImageView{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.masksToBounds = YES;
        _portraitImageView.layer.cornerRadius = 4;
    }
    return _portraitImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = HEXCOLOR(0x262626);
        _nameLabel.font = [UIFont systemFontOfSize:20];
    }
    return _nameLabel;
}

- (UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = HEXCOLOR(0x939393);
        _countLabel.font = [UIFont systemFontOfSize:14];
    }
    return _countLabel;
}

- (UIImageView *)qrCodeImageView{
    if (!_qrCodeImageView) {
        _qrCodeImageView = [[UIImageView alloc] init];
        
    }
    return _qrCodeImageView;
}

- (UILabel *)infoLabel{
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = HEXCOLOR(0x939393);
        _infoLabel.font = [UIFont systemFontOfSize:13];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _infoLabel;
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton setTitleColor:HEXCOLOR(0x36bae8) forState:(UIControlStateNormal)];
        _saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_saveButton setTitle:RCDLocalizedString(@"SaveToMobile") forState:(UIControlStateNormal)];
        [_saveButton addTarget:self action:@selector(didClickSaveAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _saveButton;
}
@end
