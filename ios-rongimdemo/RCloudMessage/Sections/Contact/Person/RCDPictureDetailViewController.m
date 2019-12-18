//
//  RCDPictureDetailViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDPictureDetailViewController.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUIBarButtonItem.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+MBProgressHUD.h"
#import <RongIMKit/RCKitUtility.h>

@interface RCDPictureDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation RCDPictureDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavi];
    [self addSubviews];
    [self updateImageView];
}

- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"ImageDetail");

    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                                target:self
                                                                                action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftButton;

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"More")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(moreAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)addSubviews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.imageView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.width.height.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)updateImageView {
    self.imageView.image = self.image;
    int imageW = self.image.size.width;
    int imageH = self.image.size.height;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.right.equalTo(self.contentView).inset(10);
        make.height.offset((RCDScreenWidth - 20) / imageW * imageH);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)saveImage {
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
        [self saveImageToPhotos:self.image];
    }
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

#pragma mark - Target Action
- (void)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)moreAction {
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"SaveToAlbum")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           [self saveImage];
                                                       }];
    UIAlertAction *deleteAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"DeletePicture")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {

                                   rcd_dispatch_main_async_safe(^{
                                       self.imageView.image = nil;
                                       if (self.deleteImageBlock) {
                                           self.deleteImageBlock();
                                       }
                                       [self.navigationController popViewControllerAnimated:YES];
                                   });
                               }];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];

    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, saveAction, deleteAction ]
                     inViewController:self];
}

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

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

@end
