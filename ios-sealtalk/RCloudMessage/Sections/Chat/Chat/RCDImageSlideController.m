//
//  RCDImageSlideController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDImageSlideController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCDQRInfoHandle.h"
#import "RCDQRCodeManager.h"
@interface RCDImageSlideController ()

@end

@implementation RCDImageSlideController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - over method
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        if (![self getCurrentPreviewImageData]) {
            return;
        }
        NSArray *actions = @[RCLocalizedString(@"Save")];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData]]];
        if (info) {
            actions = @[RCLocalizedString(@"Save"), RCDLocalizedString(@"IdentifyQRCode")];
        }
        [RCActionSheetView showActionSheetView:nil cellArray:actions cancelTitle:RCDLocalizedString(@"cancel") selectedBlock:^(NSInteger index) {
            if (index == 0) {
                [self saveImage];
            }else{
                [[RCDQRInfoHandle alloc] identifyQRCode:info base:self];
            }
        } cancelBlock:^{
            
        }];
    }
}

#pragma mark - private
- (void)saveImage {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [RCAlertView showAlertController:RCLocalizedString(@"AccessRightTitle")
                                 message:RCLocalizedString(@"photoAccessRight")
                             cancelTitle:RCLocalizedString(@"OK")
                        inViewController:self];
        return;
    }
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary
        writeImageDataToSavedPhotosAlbum:[self getCurrentPreviewImageData]
                                metadata:nil
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             if (error != NULL) {
                                 [RCAlertView showAlertController:nil
                                                   message:RCLocalizedString(@"SavePhotoFailed")
                                               cancelTitle:RCLocalizedString(@"OK") inViewController:self];
                             } else {
                                 [RCAlertView showAlertController:nil
                                                   message:RCLocalizedString(@"SavePhotoSuccess")
                                               cancelTitle:RCLocalizedString(@"OK") inViewController:self];
                             }
                         }];
}

#pragma mark - helper
- (NSData *)getCurrentPreviewImageData {
    NSData *imageData;
    if (self.currentPreviewImage.localPath.length > 0 &&
        [[NSFileManager defaultManager] fileExistsAtPath:self.currentPreviewImage.localPath]) {
        NSString *path = [RCUtilities getCorrectedFilePath:self.currentPreviewImage.localPath];
        imageData = [[NSData alloc] initWithContentsOfFile:path];
    } else {
        imageData = [RCKitUtility getImageDataForURLString:self.currentPreviewImage.imageUrl];
    }
    return imageData;
}
@end
