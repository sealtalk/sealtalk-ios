//
//  RPSendRedPacketItem.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketItem.h"
#import "RPRedpacketSetting.h"
#import "RPRedpacketTool.h"

@interface RPSendRedPacketItem()

@property (nonatomic,strong)NSDecimalNumber * cachePacketCount;              //红包个数

@end


@implementation RPSendRedPacketItem
@synthesize messageModel = _messageModel;
@synthesize totalMoney = _totalMoney;
@synthesize price = _price;
@synthesize maxTotalMoney = _maxTotalMoney;
@synthesize minTotalMoney = _minTotalMoney;

- (void)setInputMoney:(NSDecimalNumber *)inputMoney {
    _inputMoney = inputMoney;
    [self caculateTotalMoney];
}

- (void)setCheckChangeWarningTitle:(BOOL)checkChangeWarningTitle {
    _checkChangeWarningTitle = checkChangeWarningTitle;
    [self caculateTotalMoney];
}

- (void)setPacketCount:(NSDecimalNumber *)packetCount {
    if (_packetCount != packetCount) {
        _packetCount = packetCount;
        _cachePacketCount = packetCount;
        [self caculateTotalMoney];
    }
}

- (void)setMemberList:(NSArray<RedpacketUserInfo *> *)memberList {
    if (_memberList != memberList) {
        _memberList = memberList;
        _packetCount = [NSDecimalNumber decimalNumberWithMantissa:memberList?1:_cachePacketCount.integerValue exponent:0 isNegative:NO];
        [self caculateTotalMoney];
    }
}

- (void)setRedPacketType:(RedpacketType)redPacketType {
    if (_redPacketType != redPacketType) {
        _redPacketType = redPacketType;
        _cacheRedPacketType = (redPacketType == RedpacketTypeMember)? _cacheRedPacketType : redPacketType;
        [self caculateTotalMoney];
    }
}

- (NSDecimalNumber *)totalMoney{
    switch (self.redPacketType) {
        case RedpacketTypeAvg: {
            _totalMoney = [self.price decimalNumberByMultiplyingBy:self.packetCount.integerValue>0?self.packetCount:[NSDecimalNumber one]];
            break;
        }
        case RedpacketTypeSingle:
        case RedpacketTypeRand:
        case RedpacketTypeMember: {
            _totalMoney = self.inputMoney;
            break;
        }
        default:
            _totalMoney = [self.price decimalNumberByMultiplyingBy:self.packetCount.integerValue>0?self.packetCount:[NSDecimalNumber one]];
            break;
    }
    return _totalMoney;
}

- (NSDecimalNumber *)price {
    switch (self.redPacketType) {
        case RedpacketTypeRand: {
            NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                               decimalNumberHandlerWithRoundingMode:NSRoundDown
                                               scale:0
                                               raiseOnExactness:NO
                                               raiseOnOverflow:NO
                                               raiseOnUnderflow:NO
                                               raiseOnDivideByZero:YES];
            _price = (self.packetCount.integerValue >0)?[self.inputMoney decimalNumberByDividingBy:self.packetCount withBehavior:roundUp]:[NSDecimalNumber zero];
            break;
        }
        case RedpacketTypeSingle:
        case RedpacketTypeAvg:
        case RedpacketTypeMember: {
            _price = self.inputMoney;
            break;
        }
        default:
            _price = self.inputMoney;
            break;
    }
    return _price;
}

- (NSNumber *)minTotalMoney {
    CGFloat minPrice = [RPRedpacketSetting shareInstance].redpacketMinMoney;
    NSDecimalNumber * mPrice = [NSDecimalNumber decimalNumberWithMantissa:minPrice exponent:0 isNegative:NO];
    switch (self.redPacketType) {
        case RedpacketTypeRand:
        case RedpacketTypeSingle:
        case RedpacketTypeMember: {
            
            _minTotalMoney = (self.packetCount > 0) ? [self.packetCount decimalNumberByMultiplyingBy:mPrice]:mPrice;
            break;
        }
        case RedpacketTypeAvg: {
            _minTotalMoney = @(minPrice);
            break;
        }
        default:
            _minTotalMoney = [self.packetCount decimalNumberByMultiplyingBy:mPrice];
            break;
    }
    return _minTotalMoney;
}
- (NSNumber *)maxTotalMoney {
    CGFloat maxPrice = [RPRedpacketSetting shareInstance].singlePayLimit;
    NSDecimalNumber * mPrice = [NSDecimalNumber decimalNumberWithMantissa:maxPrice exponent:0 isNegative:NO];
    switch (self.redPacketType) {
        case RedpacketTypeRand: {
            _maxTotalMoney = (self.packetCount.integerValue >0)?[self.packetCount decimalNumberByMultiplyingBy:mPrice]:[NSDecimalNumber maximumDecimalNumber];
            break;
        }
        case RedpacketTypeSingle:
        case RedpacketTypeAvg:
        case RedpacketTypeMember: {
            _maxTotalMoney = [NSNumber numberWithFloat:maxPrice];
            break;
        }
        default:
            _maxTotalMoney = [NSNumber numberWithFloat:maxPrice];
            break;
    }
    return _maxTotalMoney;
}

- (void)caculateTotalMoney {
    
    RPRedpacketSetting * manager = [RPRedpacketSetting shareInstance];
    NSNumber * minPrice = [NSNumber numberWithFloat:manager.redpacketMinMoney * 100.0f];
    NSNumber * maxPrice = [NSNumber numberWithFloat:manager.singlePayLimit * 100.0f];
    NSNumber * maxCount = [NSNumber numberWithInteger:manager.maxRedpacketCount];
    _warningTittle = @"";
    _submitEnable = (([self.price compare:minPrice] != NSOrderedAscending) && ([self.price compare:maxPrice] != NSOrderedDescending)) && self.price;
    switch (self.redPacketType) {
        case RedpacketTypeSingle: {
            self.packetCount = [NSDecimalNumber one];
        }
        case RedpacketTypeRand:
        case RedpacketTypeAvg: {
            break;
        }
        case RedpacketTypeMember: {
            _submitEnable = self.memberList.count && self.price;
            break;
        }
        default:
            break;
    }
    
    if ([self.price compare:maxPrice] == NSOrderedDescending) {
        _warningTittle = [NSString stringWithFormat:@"单个红包金额不能超过%@元", @(manager.singlePayLimit)];
        _submitEnable = NO;
    }else if([self.packetCount compare:maxCount] == NSOrderedDescending) {
        _warningTittle = [NSString stringWithFormat:@"一次最多发%@个红包",maxCount];
        _submitEnable = NO;
    }else if(self.packetCount.integerValue < 1){
        _warningTittle = @"请输入红包个数";
        _submitEnable = NO;
    }else if([self.price compare:minPrice] == NSOrderedAscending){
        _submitEnable = NO;
        if (self.inputMoney.integerValue > 0) {
            _warningTittle = [NSString stringWithFormat:@"单个红包金额最少不能少于%.2f元",manager.redpacketMinMoney];
        }else if ([self.inputMoney compare:@(0)] == NSOrderedSame && self.checkChangeWarningTitle) {
            _warningTittle = @"金额输入错误";
        }
    }
}

- (void)alterRedpacketPlayType {

    switch (self.redPacketType) {
        case RedpacketTypeRand: {
            if (self.packetCount) {
                NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                                   decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                   scale:0
                                                   raiseOnExactness:NO
                                                   raiseOnOverflow:NO
                                                   raiseOnUnderflow:NO
                                                   raiseOnDivideByZero:YES];
                _inputMoney = [self.totalMoney decimalNumberByDividingBy:self.packetCount withBehavior:roundUp];
            }
            self.redPacketType = RedpacketTypeAvg;
            break;
        }
        case RedpacketTypeAvg: {
            _inputMoney = self.totalMoney;
            self.redPacketType = RedpacketTypeRand;
            break;
        }
        default:
            break;
    }
}

- (RedpacketMessageModel *)messageModel {
    if (_messageModel == nil) {
        _messageModel = [RedpacketMessageModel new];
        
    }
    NSString *message = [self.congratulateTittle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (self.congratulateTittle > 0) {
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        message = @"恭喜发财，大吉大利！";
    }
    _messageModel.messageType = RedpacketMessageTypeRedpacket;
    _messageModel.redpacket.redpacketMoney = rpString(@"%.2f", self.totalMoney.floatValue/100.0f);
    _messageModel.redpacket.redpacketGreeting = message;
    _messageModel.redpacketSender = _messageModel.currentUser;
    _messageModel.redpacket.redpacketCount = self.packetCount.integerValue;
    _messageModel.redpacketType = self.redPacketType;
    
    if (self.memberList.count) {
        NSMutableString * uids = [NSMutableString string];
        [self.memberList enumerateObjectsUsingBlock:^(RedpacketUserInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [uids appendFormat:@"%@,",obj.userId];
            _messageModel.redpacketReceiver = obj;
        }];
        uids = [[uids substringToIndex:uids.length -1] mutableCopy];
        _messageModel.redpacketReceiver.userId = [uids copy];
    }
    return _messageModel;
}

@end
