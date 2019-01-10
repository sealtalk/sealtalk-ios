//
//  RCCustomerServiceInfo.h
//  RongIMLib
//
//  Created by litao on 16/5/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCustomerServiceInfo : NSObject
@property(nonatomic, copy) NSString *userId;      //用户唯一标识
@property(nonatomic, copy) NSString *nickName;    //用户昵称
@property(nonatomic, copy) NSString *loginName;   //用户登录名
@property(nonatomic, copy) NSString *name;        //用户名称
@property(nonatomic, copy) NSString *grade;       //用户等级
@property(nonatomic, copy) NSString *gender;      //用户性别
@property(nonatomic, copy) NSString *birthday;    //用户生日
@property(nonatomic, copy) NSString *age;         //年龄
@property(nonatomic, copy) NSString *profession;  //职业
@property(nonatomic, copy) NSString *portraitUrl; //头像
@property(nonatomic, copy) NSString *province;    //省份
@property(nonatomic, copy) NSString *city;        //城市
@property(nonatomic, copy) NSString *memo;        //备注

@property(nonatomic, copy) NSString *mobileNo; //电话号码
@property(nonatomic, copy) NSString *email;    //邮箱
@property(nonatomic, copy) NSString *address;  //地址
@property(nonatomic, copy) NSString *QQ;       // QQ号
@property(nonatomic, copy) NSString *weibo;    //微博
@property(nonatomic, copy) NSString *weixin;   //微信

@property(nonatomic, copy) NSString *page;     //页面信息
@property(nonatomic, copy) NSString *referrer; //来源
@property(nonatomic, copy) NSString *enterUrl; //
@property(nonatomic, copy) NSString *skillId;
@property(nonatomic, strong) NSArray *listUrl;
@property(nonatomic, copy) NSString *define;    //自定义信息
@property(nonatomic, copy) NSString *productId; //商品id

- (NSData *)encode;
@end
