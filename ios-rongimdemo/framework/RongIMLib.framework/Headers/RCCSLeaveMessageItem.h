//
//  RCCSLeaveMessageItem.h
//  RongIMLib
//
//  Created by 张改红 on 2016/12/6.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
//客服留言配置model
@interface RCCSLeaveMessageItem : NSObject
//信息名
@property(nonatomic, copy) NSString *title;
//信息名对应的key值，在用户填了信息之后，需要把信息和此key对应构成字典
@property(nonatomic, copy) NSString *name;
//输入区域是单行还是多行：@"text" 单行；@"textarea":多行
@property(nonatomic, copy) NSString *type;
//输入区域默认提示信息
@property(nonatomic, copy) NSString *defaultText;
//是否是必填项
@property(nonatomic, assign) BOOL required;
//需要验证的类型
@property(nonatomic, copy) NSString *verification;
//验证后提示信息
@property(nonatomic, strong) NSArray *message;
//最大字数限制
@property(nonatomic, assign) int max;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
- (instancetype)initWithDic:(NSDictionary *)dic;
@end
