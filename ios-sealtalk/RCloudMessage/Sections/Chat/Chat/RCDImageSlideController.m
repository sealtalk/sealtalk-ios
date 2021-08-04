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
        UIAlertAction *cancelAction =
            [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *saveAction =
            [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"RongCloudKit", nil)
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                                       [self saveImage];
                                   }];
        NSArray *actions = @[ cancelAction, saveAction ];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData]]];
        if (info) {
            UIAlertAction *identifyQRCodeAction =
                [UIAlertAction actionWithTitle:RCDLocalizedString(@"IdentifyQRCode")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *_Nonnull action) {
                                           [[RCDQRInfoHandle alloc] identifyQRCode:info base:self];
                                       }];
            actions = @[ cancelAction, saveAction, identifyQRCodeAction ];
        }
        [RCKitUtility showAlertController:nil
                                  message:nil
                           preferredStyle:UIAlertControllerStyleActionSheet
                                  actions:actions
                         inViewController:self];
    }
}

#pragma mark - private
- (void)saveImage {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [self showAlertController:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                          message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                      cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
        return;
    }
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary
        writeImageDataToSavedPhotosAlbum:[self getCurrentPreviewImageData]
                                metadata:nil
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             if (error != NULL) {
                                 [self showAlertController:nil
                                                   message:NSLocalizedStringFromTable(@"SavePhotoFailed",
                                                                                      @"RongCloudKit", nil)
                                               cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
                             } else {
                                 [self showAlertController:nil
                                                   message:NSLocalizedStringFromTable(@"SavePhotoSuccess",
                                                                                      @"RongCloudKit", nil)
                                               cancelTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)];
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

- (void)showAlertController:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
@end
