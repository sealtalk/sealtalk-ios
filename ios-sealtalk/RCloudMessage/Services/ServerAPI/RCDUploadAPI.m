//
//  RCDUploadAPI.m
//  SealTalk
//
//  Created by LiFei on 2019/6/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUploadAPI.h"
#import "RCDHTTPUtility.h"
#import <AFNetworking/AFNetworking.h>

@implementation RCDUploadAPI

+ (void)getImageToken:(void (^)(NSString *domain, NSString *token))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_image_token"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSString *domain = result.content[@"domain"];
                                         NSString *token = result.content[@"token"];
                                         if (completeBlock) {
                                             completeBlock(domain, token);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil, nil);
                                         }
                                     }
                                 }];
}

+ (void)uploadImage:(NSData *)image byUser:(NSString *)userId complete:(void (^)(NSString *))completeBlock {
    [self getImageToken:^(NSString *domain, NSString *token) {
        if (domain.length > 0) {
            [DEFAULTS setObject:domain forKey:@"QiNiuDomain"];
            [DEFAULTS synchronize];
        }
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:token forKey:@"token"];

        //获取系统当前的时间戳
        NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
        NSString *timeString = [NSString stringWithFormat:@"%f", now];
        NSString *key = [NSString stringWithFormat:@"%@%@", userId, timeString];
        //去掉字符串中的.
        NSMutableString *str = [NSMutableString stringWithString:key];
        for (int i = 0; i < str.length; i++) {
            unichar c = [str characterAtIndex:i];
            NSRange range = NSMakeRange(i, 1);
            if (c == '.') { //此处可以是任何字符
                [str deleteCharactersInRange:range];
                --i;
            }
        }
        key = [NSString stringWithString:str];
        [params setValue:key forKey:@"key"];

        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:ret];

        NSString *url = @"https://up.qbox.me";

        NSData *imageData = image;

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager POST:url
            parameters:params
            constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData
                                            name:@"file"
                                        fileName:key
                                        mimeType:@"application/octet-stream"];
            }
            success:^(NSURLSessionDataTask *task, id response) {
                NSString *imageUrl = nil;
                if ([response[@"key"] length] > 0) {
                    NSString *key = response[@"key"];
                    NSString *QiNiuDomain = [DEFAULTS objectForKey:@"QiNiuDomain"];
                    imageUrl = [NSString stringWithFormat:@"http://%@/%@", QiNiuDomain, key];
                } else {
                    NSDictionary *downloadInfo = response[@"rc_url"];
                    if (downloadInfo) {
                        NSString *fileInfo = downloadInfo[@"path"];
                        if ([downloadInfo[@"type"] intValue] == 0) {
                            NSString *url = response[@"domain"];
                            if ([url hasSuffix:@"/"]) {
                                url = [url substringToIndex:url.length - 1];
                            }
                            if ([fileInfo hasPrefix:@"/"]) {
                                imageUrl = [url stringByAppendingString:fileInfo];
                            } else {
                                imageUrl = [url stringByAppendingPathComponent:fileInfo];
                            }
                        }
                    }
                }

                if (completeBlock) {
                    completeBlock(imageUrl);
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"uploadImage 请求失败");
                if (completeBlock) {
                    completeBlock(nil);
                }
            }];
    }];
}

@end
