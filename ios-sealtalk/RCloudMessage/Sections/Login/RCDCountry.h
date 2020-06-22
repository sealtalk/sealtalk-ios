//
//  RCDCountry.h
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDCountry : NSObject
//国家中文名字
@property (nonatomic, strong, readonly) NSString *countryName;

//国家电话代码
@property (nonatomic, strong) NSString *phoneCode;

/**
 国家初始化方法

 @param dict 传入的字典信息
 @return 国家信息对象
 */
- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSDictionary *)getModelJson;
@end

NS_ASSUME_NONNULL_END
