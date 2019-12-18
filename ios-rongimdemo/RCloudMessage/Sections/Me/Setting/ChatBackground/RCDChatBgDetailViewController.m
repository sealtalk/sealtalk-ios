//
//  RCDChatBgDetailViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatBgDetailViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDCommonString.h"
#import "UIView+MBProgressHUD.h"

@interface RCDChatBgDetailViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *settingButton;

@property (nonatomic, assign) RCDChatBgDetailType type;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSData *imageData;

@end

@implementation RCDChatBgDetailViewController

- (instancetype)initWithChatBgDetailType:(RCDChatBgDetailType)type imageName:(NSString *)imageName {
    if (self = [super init]) {
        self.type = type;
        self.imageName = imageName;
    }
    return self;
}

- (instancetype)initWithChatBgDetailType:(RCDChatBgDetailType)type image:(UIImage *)image {
    if (self = [super init]) {
        self.type = type;
        self.image = image;
        self.imageData = UIImageJPEGRepresentation(image, 0.8);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self setupSubviews];
    [self setupData];
}

- (void)setupNavi {
    if (self.type == RCDChatBgDetailTypeDefault) {
        self.title = RCDLocalizedString(@"ChatBackground");
    } else {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"settings")
                                                                        style:(UIBarButtonItemStylePlain)
                                                                       target:self
                                                                       action:@selector(settingAction)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

- (void)setupSubviews {
    [self.view addSubview:self.imageView];
    if (self.type == RCDChatBgDetailTypeDefault) {
        [self.view addSubview:self.cancelButton];
        [self.view addSubview:self.settingButton];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-50 - RCDExtraBottomHeight);
        }];

        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.height.offset(50);
            make.top.equalTo(self.imageView.mas_bottom);
            make.right.equalTo(self.settingButton.mas_left);
        }];

        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view);
            make.height.top.equalTo(self.cancelButton);
            make.left.equalTo(self.cancelButton.mas_right);
            make.width.equalTo(self.cancelButton);
        }];
    } else {
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
        }];
    }
}

- (void)setupData {
    UIImage *detailImage = nil;
    if (self.image) {
        detailImage = self.image;
    } else {
        detailImage = [UIImage imageNamed:self.imageName];
    }
    self.imageView.image = detailImage;
}

#pragma mark - Target Action
- (void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)settingAction {
    if (self.image) {
        [DEFAULTS setObject:RCDChatBackgroundFromAlbum forKey:RCDChatBackgroundKey];
        [DEFAULTS setObject:self.imageData forKey:RCDChatBackgroundImageDataKey];
    } else {
        [DEFAULTS setObject:self.imageName forKey:RCDChatBackgroundKey];
        [DEFAULTS removeObjectForKey:RCDChatBackgroundImageDataKey];
    }
    [DEFAULTS synchronize];

    [self.view showHUDMessage:RCDLocalizedString(@"setting_success")];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Setter && Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"999999" alpha:1] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _cancelButton.backgroundColor = RCDDYCOLOR(0xffffff, 0x1a1a1a);
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        [_settingButton setTitle:RCDLocalizedString(@"settings") forState:UIControlStateNormal];
        [_settingButton setTitleColor:RCDDYCOLOR(0x0099FF, 0x007acc) forState:UIControlStateNormal];
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _settingButton.backgroundColor = RCDDYCOLOR(0xffffff, 0x1a1a1a);
        [_settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

@end
