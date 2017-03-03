//
//  RPAdvertisementDetailModel.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/18.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPAdvertisementDetailModel.h"
#import <UIKit/UIKit.h>


@implementation RPAdvertisementDetailModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    //key json key
    //value property key
    return @{
             @"Amount": @"amout",
             @"BackgroundColor": @"colorString",
             @"BannerURL2X": @"bannerURLString",
             @"ID": @"rpID",
             @"LandingPage": @"landingPage",
             @"LogoURL": @"logoURLString",
             @"Message": @"title",
             @"MyAmount": @"myAmount",
             @"OwnerName": @"name",
             @"Status": @"rpState",
             @"TimeLength": @"timeString",
             @"ShareUrl": @"shareURL",
             @"ShareMessage": @"shareMessage"
             };
}

- (NSDictionary *)shareDictionary {
    
    NSMutableDictionary * shareDictionary = self.jsonDictionary.mutableCopy;
    
    return shareDictionary;
}

- (NSString*)bannerURLStringJSONTransformer {
    int point = 2;
    if ([UIScreen mainScreen].bounds.size.width > 375) {
        point = 3;
    }
    NSString * banneerKey = [NSString stringWithFormat:@"BannerURL%dX",point];
    NSString * stringValue = [self.jsonDictionary objectForKey:banneerKey];
    if (stringValue.length) return stringValue;
    point = 3;
    while (point > 0) {
        banneerKey = [NSString stringWithFormat:@"BannerURL%dX",point];
        stringValue = [self.jsonDictionary objectForKey:banneerKey];
        if (stringValue.length) break;
        point --;
    }
    return stringValue;
}

@end
