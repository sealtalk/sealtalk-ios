//
//  RCDImageSlideController.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDImageSlideController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "RCDQRCodeManager.h"
#import "RCDGroupJoinController.h"
#import "RCDGroupManager.h"
#import "RCDChatViewController.h"
#import "RCDUserInfoManager.h"
#import "RCDPersonDetailViewController.h"
#import "RCDAddFriendViewController.h"
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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - over method
- (void)longPressed:(id)sender{
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Save", @"RongCloudKit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self saveImage];
        }]];
        NSString *info = [RCDQRCodeManager decodeQRCodeImage:[UIImage imageWithData:[self getCurrentPreviewImageData]]];
        if (info) {
            [alertController addAction:[UIAlertAction actionWithTitle:RCDLocalizedString(@"IdentifyQRCode") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self identifyQRCode:info];
            }]];
        }
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - private
- (void)saveImage{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied){
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"AccessRightTitle", @"RongCloudKit", nil) message:NSLocalizedStringFromTable(@"photoAccessRight", @"RongCloudKit", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil) otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeImageDataToSavedPhotosAlbum:[self getCurrentPreviewImageData] metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error != NULL) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"SavePhotoFailed",@"RongCloudKit", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"SavePhotoSuccess",@"RongCloudKit", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil) otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)identifyQRCode:(NSString *)info{
    if (info) {
        if([info containsString:@"key=sealtalk://group/join?"]){
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://group/join?"];
            if (array.count >= 2) {
                NSArray *arr = [array[1] componentsSeparatedByString:@"&"];
                if (arr.count >= 2) {
                    NSString *gIdStr = arr[0];
                    NSString *uIdStr = arr[1];
                    if ([gIdStr hasPrefix:@"g="] && gIdStr.length > 2) {
                        gIdStr = [gIdStr substringWithRange:NSMakeRange(2, gIdStr.length-2)];
                    }
                    if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                        uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length-2)];
                    }
                    if (gIdStr.length > 0) {
                        [self handleGroupInfo:gIdStr];
                    }
                }
            }
        }else if ([info containsString:@"key=sealtalk://user/info?"]){
            NSArray *array = [info componentsSeparatedByString:@"key=sealtalk://user/info?"];
            if (array.count >= 2) {
                NSString *uIdStr = array[1];
                if ([uIdStr hasPrefix:@"u="] && uIdStr.length > 2) {
                    uIdStr = [uIdStr substringWithRange:NSMakeRange(2, uIdStr.length-2)];
                }
                if (uIdStr.length > 0) {
                    [self handleUserInfo:uIdStr];
                }
            }
        }else if([info hasPrefix:@"http"]){
            [RCKitUtility openURLInSafariViewOrWebView:info base:self];
        }else{
            [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
        }
    }else{
        [self showAlert:RCDLocalizedString(@"QRIdentifyError")];
    }
}

#pragma mark - helper
- (void)handleUserInfo:(NSString *)userId{
    RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
    RCDFriendInfo *friendInfo = [RCDUserInfoManager getFriendInfo:userId];
    if ((friendInfo != nil && friendInfo.status == RCDFriendStatusAgree) || [user.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]){
        RCDPersonDetailViewController *detailViewController = [[RCDPersonDetailViewController alloc] init];
        [self.navigationController pushViewController:detailViewController animated:YES];
        RCUserInfo *user = [RCDUserInfoManager getUserInfo:userId];
        detailViewController.userId = user.userId;
    } else {
        RCDAddFriendViewController *addViewController = [[RCDAddFriendViewController alloc] init];
        addViewController.targetUserInfo = [RCDUserInfoManager getUserInfo:userId];
        [self.navigationController pushViewController:addViewController animated:YES];
    }
}

- (void)handleGroupInfo:(NSString *)groupId{
    __weak typeof(self) weakSelf = self;
    [RCDGroupManager getGroupInfoFromServer:groupId complete:^(RCDGroupInfo * _Nonnull groupInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (groupInfo) {
                if (!groupInfo.isDismiss) {
                    [RCDGroupManager getGroupMembersFromServer:groupId complete:^(NSArray<NSString *> * _Nonnull memberIdList) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if ([memberIdList containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
                                    [weakSelf pushChatVC:groupId];
                                }else{
                                    [weakSelf pushGroupJoinVC:groupId];
                                }
                            });
                    }];
                }else{
                    [weakSelf pushGroupJoinVC:groupId];
                }
            } else {
                [self showAlert:RCDLocalizedString(@"GroupNoExist")];
            }
        });
    }];
}

- (void)showAlert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:nil
                                          cancelButtonTitle:RCDLocalizedString(@"confirm")
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)pushChatVC:(NSString *)groupId{
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.targetId = groupId;
    chatVC.conversationType = ConversationType_GROUP;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)pushGroupJoinVC:(NSString *)groupId{
    RCDGroupJoinController *groupJoinVC = [[RCDGroupJoinController alloc] init];
    groupJoinVC.groupId = groupId;
    [self.navigationController pushViewController:groupJoinVC animated:YES];
}

- (NSData *)getCurrentPreviewImageData{
    NSData *imageData;
    if (self.currentPreviewImage.localPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:self.currentPreviewImage.localPath]) {
        NSString *path = [RCUtilities getCorrectedFilePath:self.currentPreviewImage.localPath];
        imageData = [[NSData alloc] initWithContentsOfFile:path];
    } else {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.currentPreviewImage.imageUrl]];
    }
    return imageData;
}
@end
