//
//  ChangePurseModel.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/16.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChangePurseModel : NSObject

@property (nonatomic, copy) NSString *balance;
@property (nonatomic, copy) NSString *certificationMessage;
/**
 *
 * 0  未验证， 1 已验证， 2 验证失败  3 审核中
 */
@property (nonatomic, assign) int certificationStatus;
@property (nonatomic, assign) BOOL isBindCard;
@property (nonatomic, assign) BOOL isPwd;
@property (nonatomic, assign) BOOL isSha256;

+ (instancetype)configWith:(NSDictionary *)dict;
@end
