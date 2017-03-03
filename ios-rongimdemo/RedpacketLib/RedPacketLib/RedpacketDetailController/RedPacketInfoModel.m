//
//  RedPacketInfoModel.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/15.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedPacketInfoModel.h"
#import "NSDictionary+YZHExtern.h"

@implementation RedPacketInfoModel

+(instancetype)initWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    _recipientsGroup = [NSMutableArray array];
    
    [self refreshWithDict:dict];
    
    return self;
}

- (void)refreshWithDict:(NSDictionary *)dict
{
    NSDictionary *info = [dict rp_dictionaryForKey:@"Info"];
    //NSDictionary *Recipients = [dict rp_dictionaryForKey:@"RecipientsGroup"];
    NSDictionary *Statistics = [info rp_dictionaryForKey:@"Statistics"];
    if (info) {
        _isInfoDict = YES;
    }
    _timeLength = [Statistics rp_stringForKey:@"TimeLength"];
    _taken = [Statistics rp_stringIntForKey:@"Taken"];
    _total = [Statistics rp_stringIntForKey:@"Total"];
    _takenAmmount = [Statistics rp_stringForKey:@"TakenAmount"];
    _isGetFinish = [_taken intValue] == [_total intValue];
}

@end
