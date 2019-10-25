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
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:nil
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *_Nonnull action){
                                                          }]];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *_Nonnull action) {
                                                 [self saveImage];
                                             }]];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData]]];
        if (info) {
            [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"IdentifyQRCode")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action) {
                                                                  [[RCDQRInfoHandle alloc] identifyQRCode:info
                                                                                                     base:self];
                                                              }]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - private
- (void)saveImage {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil)
                                       message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                             otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary
        writeImageDataToSavedPhotosAlbum:[self getCurrentPreviewImageData]
                                metadata:nil
                         completionBlock:^(NSURL *assetURL, NSError *error) {
                             if (error != NULL) {
                                 UIAlertView *alert = [[UIAlertView alloc]
                                         initWithTitle:nil
                                               message:NSLocalizedStringFromTable(@"SavePhotoFailed", @"RongCloudKit",
                                                                                  nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                     otherButtonTitles:nil];
                                 [alert show];
                             } else {
                                 UIAlertView *alert = [[UIAlertView alloc]
                                         initWithTitle:nil
                                               message:NSLocalizedStringFromTable(@"SavePhotoSuccess", @"RongCloudKit",
                                                                                  nil)
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                     otherButtonTitles:nil];
                                 [alert show];
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
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentPreviewImage.imageUrl]];
    }
    return imageData;
}
@end
