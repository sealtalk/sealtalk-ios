//
//  RCDDebugMessagePushConfigController.m
//  SealTalk
//
//  Created by 孙浩 on 2020/11/27.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugMessagePushConfigController.h"
#import <Masonry/Masonry.h>

@interface RCDDebugMessagePushConfigController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *disableNotificationBtn;

@property (nonatomic, strong) UIButton *disableTitleBtn;

@property (nonatomic, strong) UIButton *forceShowDetailBtn;

@property (nonatomic, strong) UITextField *notificationIdTF;

@property (nonatomic, strong) UITextField *pushTitleTF;

@property (nonatomic, strong) UITextField *pushContentTF;

@property (nonatomic, strong) UITextField *pushDataTF;

@property (nonatomic, strong) UITextField *templateIdTF;

@property (nonatomic, strong) UITextField *threadIdTF;

@property (nonatomic, strong) UITextField *apnsCollapseIdTF;

@property (nonatomic, strong) UITextField *channelIdMiTF;

@property (nonatomic, strong) UITextField *channelIdHWTF;

@property (nonatomic, strong) UITextField *channelIdOPPOTF;

@property (nonatomic, strong) UITextField *typeVivoTF;

@property (nonatomic, strong) RCMessagePushConfig *pushConfig;

@property (nonatomic, strong) RCMessageConfig *config;

@end

@implementation RCDDebugMessagePushConfigController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setNavi];
    [self addObserver];
    [self getDefaultPushConfig];
    [self setDefaultData];
}

#pragma mark - Private Method
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    
    [self.contentView addSubview:self.disableNotificationBtn];
    [self.contentView addSubview:self.disableTitleBtn];
    [self.contentView addSubview:self.forceShowDetailBtn];
    [self.contentView addSubview:self.notificationIdTF];
    [self.contentView addSubview:self.pushTitleTF];
    [self.contentView addSubview:self.pushContentTF];
    [self.contentView addSubview:self.pushDataTF];
    [self.contentView addSubview:self.templateIdTF];
    [self.contentView addSubview:self.threadIdTF];
    [self.contentView addSubview:self.apnsCollapseIdTF];
    [self.contentView addSubview:self.channelIdMiTF];
    [self.contentView addSubview:self.channelIdHWTF];
    [self.contentView addSubview:self.channelIdOPPOTF];
    [self.contentView addSubview:self.typeVivoTF];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.width.equalTo(self.scrollView);
    }];
    
    [self.disableNotificationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(20);
        make.height.offset(30);
    }];
    
    [self.disableTitleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disableNotificationBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableNotificationBtn);
    }];
    
    [self.forceShowDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.disableTitleBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushTitleTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forceShowDetailBtn.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushContentTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushTitleTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.pushDataTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushContentTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.templateIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pushDataTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.threadIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.templateIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.apnsCollapseIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.threadIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.notificationIdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.apnsCollapseIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdMiTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.notificationIdTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdHWTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdMiTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.channelIdOPPOTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdHWTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
    }];
    
    [self.typeVivoTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.channelIdOPPOTF.mas_bottom).offset(10);
        make.height.left.right.equalTo(self.disableTitleBtn);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setNavi {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
}

- (void)setDefaultData {
    if (self.pushConfig) {
        self.disableTitleBtn.selected = self.pushConfig.disablePushTitle;
        self.forceShowDetailBtn.selected = self.pushConfig.forceShowDetailContent;
        self.notificationIdTF.text = self.pushConfig.androidConfig.notificationId;
        self.pushTitleTF.text = self.pushConfig.pushTitle;
        self.pushContentTF.text = self.pushConfig.pushContent;
        self.pushDataTF.text = self.pushConfig.pushData;
        self.templateIdTF.text = self.pushConfig.templateId;
        self.threadIdTF.text = self.pushConfig.iOSConfig.threadId;
        self.apnsCollapseIdTF.text = self.pushConfig.iOSConfig.apnsCollapseId;
        self.channelIdMiTF.text = self.pushConfig.androidConfig.channelIdMi;
        self.channelIdHWTF.text = self.pushConfig.androidConfig.channelIdHW;
        self.channelIdOPPOTF.text = self.pushConfig.androidConfig.channelIdOPPO;
        self.typeVivoTF.text = self.pushConfig.androidConfig.typeVivo;
    }
    
    if (self.config) {
        self.disableNotificationBtn.selected = self.config.disableNotification;
    }
}

#pragma mark - Action
- (void)disableNotification {
    self.disableNotificationBtn.selected = !self.disableNotificationBtn.selected;
}

- (void)disableTitle {
    self.disableTitleBtn.selected = !self.disableTitleBtn.selected;
}

- (void)forceShowDetail {
    self.forceShowDetailBtn.selected = !self.forceShowDetailBtn.selected;
}

- (void)save {
    
    RCMessagePushConfig *pushConfig = [[RCMessagePushConfig alloc] init];
    pushConfig.disablePushTitle = self.disableTitleBtn.selected;
    pushConfig.pushTitle = self.pushTitleTF.text;
    pushConfig.pushContent = self.pushContentTF.text;
    pushConfig.pushData = self.pushDataTF.text;
    pushConfig.templateId = self.templateIdTF.text;
    pushConfig.iOSConfig.threadId = self.threadIdTF.text;
    pushConfig.iOSConfig.apnsCollapseId = self.apnsCollapseIdTF.text;
    pushConfig.androidConfig.notificationId = self.notificationIdTF.text;
    pushConfig.androidConfig.channelIdMi = self.channelIdMiTF.text;
    pushConfig.androidConfig.channelIdHW = self.channelIdHWTF.text;
    pushConfig.androidConfig.channelIdOPPO = self.channelIdOPPOTF.text;
    pushConfig.androidConfig.typeVivo = self.typeVivoTF.text;
    pushConfig.forceShowDetailContent = self.forceShowDetailBtn.selected;
    
    [self saveToUserDefaults:pushConfig];
    
    RCMessageConfig *config = [[RCMessageConfig alloc] init];
    config.disableNotification = self.disableNotificationBtn.selected;
    
    [self saveConfigToUserDefaults:config];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.view endEditing:YES];
}

- (void)saveToUserDefaults:(RCMessagePushConfig *)pushConfig {
    [[NSUserDefaults standardUserDefaults] setObject:@(pushConfig.disablePushTitle) forKey:@"pushConfig-disablePushTitle"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushTitle forKey:@"pushConfig-title"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushContent forKey:@"pushConfig-content"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.pushData forKey:@"pushConfig-data"];
    [[NSUserDefaults standardUserDefaults] setObject:@(pushConfig.forceShowDetailContent) forKey:@"pushConfig-forceShowDetailContent"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.templateId forKey:@"pushConfig-templateId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.threadId forKey:@"pushConfig-threadId"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.iOSConfig.apnsCollapseId forKey:@"pushConfig-apnsCollapseId"];
    
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.notificationId forKey:@"pushConfig-android-id"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdMi forKey:@"pushConfig-android-mi"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdHW forKey:@"pushConfig-android-hw"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.channelIdOPPO forKey:@"pushConfig-android-oppo"];
    [[NSUserDefaults standardUserDefaults] setObject:pushConfig.androidConfig.typeVivo forKey:@"pushConfig-android-vivo"];
}

- (void)saveConfigToUserDefaults:(RCMessageConfig *)config {
    [[NSUserDefaults standardUserDefaults] setObject:@(config.disableNotification) forKey:@"config-disableNotification"];
}

- (void)getDefaultPushConfig {
    self.pushConfig = [[RCMessagePushConfig alloc] init];
    self.pushConfig.disablePushTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-disablePushTitle"] boolValue];
    self.pushConfig.pushTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-title"];
    self.pushConfig.pushContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-content"];
    self.pushConfig.pushData = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-data"];
    self.pushConfig.forceShowDetailContent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-forceShowDetailContent"] boolValue];
    self.pushConfig.templateId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-templateId"];
    
    self.pushConfig.iOSConfig.threadId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-threadId"];
    self.pushConfig.iOSConfig.apnsCollapseId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-apnsCollapseId"];
    
    self.pushConfig.androidConfig.notificationId = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-id"];
    self.pushConfig.androidConfig.channelIdMi = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-mi"];
    self.pushConfig.androidConfig.channelIdHW = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-hw"];
    self.pushConfig.androidConfig.channelIdOPPO = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-oppo"];
    self.pushConfig.androidConfig.typeVivo = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushConfig-android-vivo"];
    
    self.config = [[RCMessageConfig alloc] init];
    self.config.disableNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:@"config-disableNotification"] boolValue];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect keyboardBounds = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-keyboardBounds.size.height);//.offset(-350)
        }];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
        }];
    } completion:nil];
}

#pragma mark - Setter && Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UIButton *)disableNotificationBtn {
    if (!_disableNotificationBtn) {
        _disableNotificationBtn = [[UIButton alloc] init];
        [_disableNotificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_disableNotificationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_disableNotificationBtn setTitle:@"□ 是否开启静默消息" forState:UIControlStateNormal];
        [_disableNotificationBtn setTitle:@"✅ 是否开启静默消息" forState:UIControlStateSelected];
        [_disableNotificationBtn addTarget:self action:@selector(disableNotification) forControlEvents:UIControlEventTouchUpInside];
        _disableNotificationBtn.layer.borderWidth = 1;
        _disableNotificationBtn.layer.cornerRadius = 8;
    }
    return _disableNotificationBtn;
}

- (UIButton *)disableTitleBtn {
    if (!_disableTitleBtn) {
        _disableTitleBtn = [[UIButton alloc] init];
        [_disableTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_disableTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_disableTitleBtn setTitle:@"□ 是否屏蔽推送标题" forState:UIControlStateNormal];
        [_disableTitleBtn setTitle:@"✅ 是否屏蔽推送标题" forState:UIControlStateSelected];
        [_disableTitleBtn addTarget:self action:@selector(disableTitle) forControlEvents:UIControlEventTouchUpInside];
        _disableTitleBtn.layer.borderWidth = 1;
        _disableTitleBtn.layer.cornerRadius = 8;
    }
    return _disableTitleBtn;
}

- (UIButton *)forceShowDetailBtn {
    if (!_forceShowDetailBtn) {
        _forceShowDetailBtn = [[UIButton alloc] init];
        [_forceShowDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_forceShowDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_forceShowDetailBtn setTitle:@"□ 是否强制显示通知详情" forState:UIControlStateNormal];
        [_forceShowDetailBtn setTitle:@"✅ 是否强制显示通知详情" forState:UIControlStateSelected];
        [_forceShowDetailBtn addTarget:self action:@selector(forceShowDetail) forControlEvents:UIControlEventTouchUpInside];
        _forceShowDetailBtn.layer.borderWidth = 1;
        _forceShowDetailBtn.layer.cornerRadius = 8;
    }
    return _forceShowDetailBtn;
}

- (UITextField *)pushTitleTF {
    if (!_pushTitleTF) {
        _pushTitleTF = [[UITextField alloc] init];
        _pushTitleTF.placeholder = @"推送标题";
        _pushTitleTF.layer.borderWidth = 1;
    }
    return _pushTitleTF;
}

- (UITextField *)pushContentTF {
    if (!_pushContentTF) {
        _pushContentTF = [[UITextField alloc] init];
        _pushContentTF.placeholder = @"推送详情";
        _pushContentTF.layer.borderWidth = 1;
    }
    return _pushContentTF;
}

- (UITextField *)pushDataTF {
    if (!_pushDataTF) {
        _pushDataTF = [[UITextField alloc] init];
        _pushDataTF.placeholder = @"pushData";
        _pushDataTF.layer.borderWidth = 1;
    }
    return _pushDataTF;
}

- (UITextField *)templateIdTF {
    if (!_templateIdTF) {
        _templateIdTF = [[UITextField alloc] init];
        _templateIdTF.placeholder = @"模板 id";
        _templateIdTF.layer.borderWidth = 1;
    }
    return _templateIdTF;
}

- (UITextField *)threadIdTF {
    if (!_threadIdTF) {
        _threadIdTF = [[UITextField alloc] init];
        _threadIdTF.placeholder = @"iOS 分组 id";
        _threadIdTF.layer.borderWidth = 1;
    }
    return _threadIdTF;
}

- (UITextField *)apnsCollapseIdTF {
    if (!_apnsCollapseIdTF) {
        _apnsCollapseIdTF = [[UITextField alloc] init];
        _apnsCollapseIdTF.placeholder = @"iOS 覆盖 id";
        _apnsCollapseIdTF.layer.borderWidth = 1;
    }
    return _apnsCollapseIdTF;
}

- (UITextField *)notificationIdTF {
    if (!_notificationIdTF) {
        _notificationIdTF = [[UITextField alloc] init];
        _notificationIdTF.placeholder = @"推送 Id";
        _notificationIdTF.layer.borderWidth = 1;
    }
    return _notificationIdTF;
}

- (UITextField *)channelIdMiTF {
    if (!_channelIdMiTF) {
        _channelIdMiTF = [[UITextField alloc] init];
        _channelIdMiTF.placeholder = @"小米 channelId";
        _channelIdMiTF.layer.borderWidth = 1;
    }
    return _channelIdMiTF;
}

- (UITextField *)channelIdHWTF {
    if (!_channelIdHWTF) {
        _channelIdHWTF = [[UITextField alloc] init];
        _channelIdHWTF.placeholder = @"华为 channelId";
        _channelIdHWTF.layer.borderWidth = 1;
    }
    return _channelIdHWTF;
}

- (UITextField *)channelIdOPPOTF {
    if (!_channelIdOPPOTF) {
        _channelIdOPPOTF = [[UITextField alloc] init];
        _channelIdOPPOTF.placeholder = @"OPPO channelId";
        _channelIdOPPOTF.layer.borderWidth = 1;
    }
    return _channelIdOPPOTF;
}

- (UITextField *)typeVivoTF {
    if (!_typeVivoTF) {
        _typeVivoTF = [[UITextField alloc] init];
        _typeVivoTF.placeholder = @"vivo type，只能为 0 或者 1";
        _typeVivoTF.layer.borderWidth = 1;
    }
    return _typeVivoTF;
}

@end
