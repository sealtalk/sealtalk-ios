//
//  QRCodeManager.m
//  SealTalk
//
//  Created by 张改红 on 2019/6/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQRCodeManager.h"
#import <ZXingObjC/ZXingObjC.h>
@implementation RCDQRCodeManager
+ (UIImage *)getQRCodeImage:(NSString *)content{
    NSError *error = nil;
    UIImage *image;
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:content
                                  format:kBarcodeFormatQRCode
                                   width:500
                                  height:500
                                   error:&error];
    if (result) {
        CGImageRef imageRef = CGImageRetain([[ZXImage imageWithMatrix:result] cgimage]);
        
        // This CGImageRef image can be placed in a UIImage, NSImage, or written to a file.
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    } else {
        NSString *errorMessage = [error localizedDescription];
        NSLog(@"getQRCodeImage:%@",errorMessage);
    }
    return image;
}

+ (NSString *)decodeQRCodeImage:(UIImage *)image{
    CGImageRef imageToDecode = image.CGImage;  // Given a CGImage in which we are looking for barcodes
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    // There are a number of hints we can give to the reader, including
    // possible formats, allowed lengths, and the string encoding.
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    NSString *contents;
    if (result) {
        // The coded result as a string. The raw data can be accessed with
        // result.rawBytes and result.length.
        contents = result.text;

    } else {
        // Use error to determine why we didn't get a result, such as a barcode
        // not being found, an invalid checksum, or a format inconsistency.
    }
    return contents;
}
@end
