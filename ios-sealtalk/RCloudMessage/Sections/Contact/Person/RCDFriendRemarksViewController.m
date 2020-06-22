//
//  RCDFrienfRemarksViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/8/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDFriendRemarksViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDUserInfoManager.h"
#import "RCDUIBarButtonItem.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDSetupRemarkView.h"
#import "RCDDescriptionView.h"
#import "RCDPictureView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NormalAlertView.h"
#import "RCDPictureDetailViewController.h"
#import "RCDCountryListController.h"
#import "RCDCountry.h"
#import "RCDUploadManager.h"
#import "UIView+MBProgressHUD.h"

#define MAX_STARWORDS_LENGTH 16

@interface RCDFriendRemarksViewController () <RCDPictureViewDelegate, UIScrollViewDelegate,
                                              UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) RCDSetupRemarkView *remarksView;
@property (nonatomic, strong) RCDSetupRemarkView *phoneView;
@property (nonatomic, strong) RCDDescriptionView *descriptionView;
@property (nonatomic, strong) RCDPictureView *pictureView;

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) BOOL photoIsChange;
@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, strong) RCDCountry *currentRegion;

@property (nonatomic, strong) RCDFriendDescription *friendDescription;
@property (nonatomic, assign) CGFloat keyboardY;
@property (nonatomic, assign) CGFloat descriptionViewY;

@end

@implementation RCDFriendRemarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self setupSubviews];
    [self setupData];
    [self addObserver];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)setupNavi {
    self.navigationItem.title = RCDLocalizedString(@"SetRemarksAndDescription");
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"done")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(clickRightBtn:)];
    self.navigationItem.rightBarButtonItem = rightButton;

    RCDUIBarButtonItem *leftButton = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                                target:self
                                                                                action:@selector(clickBackBtn:)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.contentView addSubview:self.remarksView];
    [self.contentView addSubview:self.phoneView];
    [self.contentView addSubview:self.descriptionView];
    [self.contentView addSubview:self.pictureView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.height.width.equalTo(self.view);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.remarksView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.offset(70.5);
    }];

    [self.phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remarksView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.offset(70.5);
    }];

    [self.descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phoneView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.height.mas_greaterThanOrEqualTo(70.5);
    }];

    [self.pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

- (void)setupData {
    self.originalFrame = self.view.frame;
    self.friendDescription = [RCDUserInfoManager getFriendDescription:self.friendId];
    if (self.friendDescription.region.length <= 0) {
        self.friendDescription.region = @"86";
    }
    self.remarksView.inputText = self.friendDescription.displayName;
    self.phoneView.btnTitle = self.friendDescription.region;
    self.phoneView.inputText = self.friendDescription.phone;
    self.descriptionView.inputText = self.friendDescription.desc;

    if (self.friendDescription.imageUrl != nil && ![self.friendDescription.imageUrl isEqualToString:@""]) {
        [self.pictureView.imageView sd_setImageWithURL:[NSURL URLWithString:self.friendDescription.imageUrl]
                                      placeholderImage:[UIImage imageNamed:@""]];
        self.pictureView.promptTitle = @"";
    }

    __weak typeof(self) weakSelf = self;
    self.phoneView.tapAreaCodeBlock = ^{
        [weakSelf pushToCountryListVC];
    };
}

- (void)pushToCountryListVC {
    RCDCountryListController *countryListVC = [[RCDCountryListController alloc] init];
    countryListVC.showNavigationBarWhenBack = YES;
    __weak typeof(self) weakSelf = self;
    [countryListVC setSelectCountryResult:^(RCDCountry *_Nonnull country) {
        weakSelf.phoneView.btnTitle = country.phoneCode;
    }];
    [self.navigationController pushViewController:countryListVC animated:YES];
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChanged:)
                                                 name:@"TextViewTextChanged"
                                               object:nil];
}

- (void)alertInfo:(NSString *)infoStr {
    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:nil message:infoStr preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"confirm")
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showActionSheet {
    UIAlertAction *takePictureAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"take_picture")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [self pushImagePickerVCWithType:UIImagePickerControllerSourceTypeCamera];
                               }];

    UIAlertAction *albumsAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"SelectFromAlbum")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [self pushImagePickerVCWithType:UIImagePickerControllerSourceTypePhotoLibrary];
                               }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                         }];
    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, takePictureAction, albumsAction ]
                     inViewController:self];
}

- (void)pushImagePickerVCWithType:(UIImagePickerControllerSourceType)type {
    if (type == UIImagePickerControllerSourceTypeCamera && ![UIImagePickerController isSourceTypeAvailable:type]) {
        NSLog(@"模拟器无法连接相机");
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = type;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (BOOL)judgeIsChange {
    BOOL isChange = NO;
    if (![self.remarksView.inputText isEqualToString:self.friendDescription.displayName] ||
        ![self.phoneView.btnTitle isEqualToString:self.friendDescription.region] ||
        ![self.phoneView.inputText isEqualToString:self.friendDescription.phone] ||
        ![self.descriptionView.inputText isEqualToString:self.friendDescription.desc]) {
        isChange = YES;
    }
    return isChange;
}

- (void)uploadImageIfNeed {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = RCDLocalizedString(@"setting");
    [hud show:YES];

    if (self.photoIsChange) {
        if (self.imageData) {
            [RCDUploadManager uploadImage:self.imageData
                                 complete:^(NSString *url) {
                                     if (url.length > 0) {
                                         [self setRemarksAndDescription:url hud:hud];
                                     } else {
                                         rcd_dispatch_main_async_safe(^{
                                             [hud hide:YES];
                                             [self.view showHUDMessage:RCDLocalizedString(@"PicutreUploadFailed")];
                                         });
                                     }
                                 }];
        } else {
            [self setRemarksAndDescription:@"" hud:hud];
        }
    } else {
        [self setRemarksAndDescription:self.friendDescription.imageUrl hud:hud];
    }
}

- (void)setRemarksAndDescription:(NSString *)imageUrl hud:(MBProgressHUD *)hud {
    [RCDUserInfoManager setDescriptionWithUserId:self.friendId
                                          remark:self.remarksView.inputText
                                          region:self.phoneView.btnTitle
                                           phone:self.phoneView.inputText
                                            desc:self.descriptionView.inputText
                                        imageUrl:imageUrl
                                        complete:^(BOOL success) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [hud hide:YES];
                                                if (success) {
                                                    self.setRemarksSuccess();
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                } else {
                                                    [self alertInfo:RCDLocalizedString(@"set_fail")];
                                                }
                                            });
                                        }];
}

- (CGFloat)getNaviAndStatusHeight {
    CGFloat navHeight = 44.0f;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    return navHeight + statusBarHeight;
}

#pragma mark - Target Action
- (void)clickRightBtn:(id)sender {
    [self.scrollView endEditing:YES];
    if ([self judgeIsChange] || self.photoIsChange) {
        [self uploadImageIfNeed];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickBackBtn:(id)sender {
    [self.scrollView endEditing:YES];
    if ([self judgeIsChange] || self.photoIsChange) {
        [NormalAlertView showAlertWithTitle:RCDLocalizedString(@"WarmPrompt")
            message:RCDLocalizedString(@"SaveTheChanges")
            highlightText:nil
            describeTitle:nil
            leftTitle:RCDLocalizedString(@"cancel")
            rightTitle:RCDLocalizedString(@"Delete_Confirm")
            cancel:^{
                rcd_dispatch_main_async_safe(^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            confirm:^{
                [self uploadImageIfNeed];
            }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.descriptionView.rcdIsFirstResponder) {
        CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect viewFrame = self.originalFrame;
        viewFrame.size.height -= keyboardBounds.size.height;

        self.keyboardY = keyboardBounds.origin.y;
        self.descriptionViewY = self.descriptionView.frame.origin.y;
        self.view.frame = viewFrame;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.view.frame = viewFrame;
                         }
                         completion:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewTextChanged"
                                                            object:self.descriptionView.textView];
    }
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = self.originalFrame;
                         frame.origin.y += [self getNaviAndStatusHeight];
                         self.view.frame = frame;
                     }
                     completion:nil];
}

- (void)textViewDidChanged:(NSNotification *)notification {
    CGFloat descriptionViewBottomY = self.descriptionViewY + self.descriptionView.frame.size.height + 29 + 18;
    if (descriptionViewBottomY >= self.keyboardY) {
        CGFloat offsetY =
            self.scrollView.contentSize.height - self.scrollView.frame.size.height - self.pictureView.frame.size.height;
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark - RCDPictureViewDelegate
- (void)pictureViewDidTap {
    [self.scrollView endEditing:YES];
    if (self.pictureView.imageView.image) {
        RCDPictureDetailViewController *pictureDetailVC = [[RCDPictureDetailViewController alloc] init];
        pictureDetailVC.image = self.pictureView.imageView.image;
        pictureDetailVC.deleteImageBlock = ^{
            self.pictureView.imageView.image = nil;
            self.pictureView.promptTitle = RCDLocalizedString(@"AddCardOrPicture");
            self.imageData = nil;
            self.photoIsChange = YES;
        };
        [self.navigationController pushViewController:pictureDetailVC animated:YES];
    } else {
        [self showActionSheet];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.scrollView endEditing:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.pictureView.imageView.image = originImage;
        self.pictureView.promptTitle = @"";
        self.photoIsChange = YES;
        self.imageData = UIImageJPEGRepresentation(originImage, 1);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setter && Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (RCDSetupRemarkView *)remarksView {
    if (!_remarksView) {
        _remarksView = [[RCDSetupRemarkView alloc] init];
        _remarksView.title = RCDLocalizedString(@"Remarks");
        _remarksView.placeholder = RCDLocalizedString(@"PleaseAddRemarks");
        _remarksView.charMaxCount = 16;
    }
    return _remarksView;
}

- (RCDSetupRemarkView *)phoneView {
    if (!_phoneView) {
        _phoneView = [[RCDSetupRemarkView alloc] init];
        _phoneView.title = RCDLocalizedString(@"mobile_number");
        _phoneView.placeholder = RCDLocalizedString(@"PleaseInputPhoneNumber");
        _phoneView.btnTitle = @"86";
        _phoneView.charMaxCount = 11;
        _phoneView.showCountryBtn = YES;
        _phoneView.isPhoneNumber = YES;
    }
    return _phoneView;
}

- (RCDDescriptionView *)descriptionView {
    if (!_descriptionView) {
        _descriptionView = [[RCDDescriptionView alloc] init];
        _descriptionView.title = RCDLocalizedString(@"MoreDescription");
        _descriptionView.placeholder = RCDLocalizedString(@"PleaseAddDescription");
        _descriptionView.showTextNumber = YES;
        _descriptionView.charMaxCount = 400;
    }
    return _descriptionView;
}

- (RCDPictureView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[RCDPictureView alloc] init];
        _pictureView.title = RCDLocalizedString(@"TakeAPictureAndPhoto");
        _pictureView.promptTitle = RCDLocalizedString(@"AddCardOrPicture");
        _pictureView.delegate = self;
    }
    return _pictureView;
}

@end
