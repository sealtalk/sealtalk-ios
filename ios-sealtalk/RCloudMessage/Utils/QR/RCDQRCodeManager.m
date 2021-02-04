//
//  QRCodeManager.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQRCodeManager.h"
#import <Photos/PHPhotoLibrary.h>
#import <ZXingObjC/ZXingObjC.h>

@implementation RCDQRCodeManager
+ (UIImage *)getQRCodeImage:(NSString *)content {
    NSError *error = nil;
    UIImage *image;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix *result = [writer encode:content format:kBarcodeFormatQRCode width:500 height:500 error:&error];
    if (result) {
        CGImageRef imageRef = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);

        // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"getQRCodeImage:%@", errorMessage);
    }
    return image;
}

+ (NSString *)decodeQRCodeImage:(UIImage *)image {
    CGImageRef imageToDecode = image.CGImage; // Given a CGImage in which we are looking for barcodes
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

    NSError *error = nil;

    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];

    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    NSString *contents;
    if (result) {
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
        contents = result.text;
    } else {
        // ZXingObjC bug：有的图片识别不出，这时在用系统识别一次
        UIImage *pickImage = image;
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                  context:nil
                                                  options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        // 获取选择图片中识别结果
        NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(pickImage)]];
        if (features.count > 0) {
            CIQRCodeFeature *feature = features[0];
            NSString *stringValue = feature.messageString;
            contents = stringValue;
        }
    }
    return contents;
}

/** 校验是否有相机权限 */
+ (void)rcd_checkCameraAuthorizationStatusWithGrand:(void (^)(BOOL granted))permissionGranted {
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (videoAuthStatus) {
    // 已授权
    case AVAuthorizationStatusAuthorized: {
        permissionGranted(YES);
    } break;
    // 未询问用户是否授权
    case AVAuthorizationStatusNotDetermined: {
        // 提示用户授权
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     permissionGranted(granted);
                                 }];
    } break;
    // 用户拒绝授权或权限受限
    case AVAuthorizationStatusRestricted:
    case AVAuthorizationStatusDenied: {
        [self showAlertController:NSLocalizedStringFromTable(@"cameraAccessRight", @"RongCloudKit", nil)
                      cancelTitle:RCDLocalizedString(@"confirm")];
        permissionGranted(NO);
    } break;
    default:
        break;
    }
}

/** 校验是否有相册权限 */
+ (void)rcd_checkAlbumAuthorizationStatusWithGrand:(void (^)(BOOL granted))permissionGranted {

    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthStatus) {
    // 已授权
    case PHAuthorizationStatusAuthorized: {
        permissionGranted(YES);
    } break;
    // 未询问用户是否授权
    case PHAuthorizationStatusNotDetermined: {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            permissionGranted(status == PHAuthorizationStatusAuthorized);
        }];
    } break;
    // 用户拒绝授权或权限受限
    case PHAuthorizationStatusRestricted:
    case PHAuthorizationStatusDenied: {
        [self showAlertController:NSLocalizedStringFromTable(@"PhotoAccessRight", @"RongCloudKit", nil)
                      cancelTitle:RCDLocalizedString(@"confirm")];
        permissionGranted(NO);
    } break;
    default:
        break;
    }
}

+ (void)showAlertController:(NSString *)title cancelTitle:(NSString *)cancelTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:nil]];
        [rootVC presentViewController:alertController animated:YES completion:nil];
    });
}

/** 手电筒开关 */
+ (void)rcd_FlashlightOn:(BOOL)on {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch] && [captureDevice hasFlash]) {
        [captureDevice lockForConfiguration:nil];
        if (on) {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [captureDevice setFlashMode:AVCaptureFlashModeOn];
        } else {
            [captureDevice setTorchMode:AVCaptureTorchModeOff];
            [captureDevice setFlashMode:AVCaptureFlashModeOff];
        }
        [captureDevice unlockForConfiguration];
    }
}

@end
