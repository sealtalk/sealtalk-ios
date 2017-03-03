//
//  ChangePurseModel.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/16.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "ChangePurseModel.h"
#import "NSDictionary+YZHExtern.h"

@implementation ChangePurseModel

+ (instancetype)configWith:(NSDictionary *)dict
{
    return [[self alloc]initWith:dict];
}

- (instancetype)initWith:(NSDictionary *)dict
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _balance = [dict rp_stringFloatForKey:@"Balance"];
    _certificationMessage = [dict rp_stringForKey:@"CertificationMessage"];
    _certificationStatus = [[dict rp_stringIntForKey:@"CertificationStatus"] intValue];
    _isBindCard = [[dict rp_stringIntForKey:@"IsBindCard"] intValue];
    _isPwd = [[dict rp_stringIntForKey:@"IsPwd"] intValue];
    _isSha256 = [[dict rp_stringIntForKey:@"IsSha256"] intValue];
    
    return self;
}

@end
