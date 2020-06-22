//
//  RCDRecentPictureViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDRecentPictureViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"

@interface RCDRecentPictureViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) UIButton *fullButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation RCDRecentPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.topBgView];
    [self.topBgView addSubview:self.cancelButton];
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.fullButton];
    [self.bottomBgView addSubview:self.sendButton];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.view);
    }];

    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.offset(50);
    }];

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topBgView);
        make.right.equalTo(self.topBgView).offset(-10);
        make.height.offset(24);
    }];

    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.height.offset(50 + self.view.safeAreaInsets.bottom);
        } else {
            make.height.offset(50);
        }
    }];

    [self.fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomBgView).offset(10);
        make.left.equalTo(self.bottomBgView).offset(10);
        make.height.offset(25);
    }];

    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomBgView).offset(10);
        make.right.equalTo(self.bottomBgView).offset(-10);
        make.height.width.equalTo(self.fullButton);
    }];
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fullAction {
    self.fullButton.selected = !self.fullButton.selected;
}

- (void)sendAction {
    if (self.sendBlock) {
        self.sendBlock(self.fullButton.isSelected);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapAction {
    self.topBgView.hidden = !self.topBgView.hidden;
    self.bottomBgView.hidden = !self.bottomBgView.hidden;
}

#pragma mark - Setter && Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[UIView alloc] init];
        _topBgView.backgroundColor = [UIColor colorWithHexString:@"383838" alpha:0.8];
    }
    return _topBgView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] init];
        _bottomBgView.backgroundColor = [UIColor colorWithHexString:@"383838" alpha:0.8];
    }
    return _bottomBgView;
}

- (UIButton *)fullButton {
    if (!_fullButton) {
        _fullButton = [[UIButton alloc] init];
        [_fullButton setTitle:RCDLocalizedString(@"Full") forState:UIControlStateNormal];
        UIImage *unSelectImage = [UIImage imageNamed:@"unselected_full"];
        [_fullButton setImage:unSelectImage forState:UIControlStateNormal];
        UIImage *selectImage = [UIImage imageNamed:@"selected_full"];
        [_fullButton setImage:selectImage forState:UIControlStateSelected];
        [_fullButton setTitleColor:[UIColor colorWithHexString:@"FFFFFF" alpha:1] forState:UIControlStateNormal];
        [_fullButton addTarget:self action:@selector(fullAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        [_sendButton setTitle:RCDLocalizedString(@"send") forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor colorWithHexString:@"0099FF" alpha:1] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end
