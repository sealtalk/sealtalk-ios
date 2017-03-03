//
//  RPAdvertisementDetailModel.h
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/18.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedpacketMessageModel.h"
#import "RedpacketBaseModel.h"

@interface RPAdvertisementDetailModel : RedpacketBaseModel

@property (nonatomic,copy)NSString * amout;
@property (nonatomic,copy)NSString * myAmount;
@property (nonatomic,copy)NSString * colorString;
@property (nonatomic,copy)NSString * bannerURLString;
@property (nonatomic,copy)NSString * rpID;
@property (nonatomic,copy)NSString * landingPage;
@property (nonatomic,copy)NSString * logoURLString;
@property (nonatomic,copy)NSString * title;
@property (nonatomic,copy)NSString * name;
@property (nonatomic,copy)NSString * shareMessage;
@property (nonatomic,copy)NSString * shareURL;
@property (nonatomic,assign)RedpacketStatusType rpState;
@property (nonatomic,copy)NSString * timeString;

- (NSDictionary *)shareDictionary;
@end
