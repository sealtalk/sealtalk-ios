//
//  RCCustomerServiceInfo.h
//  RongIMLib
//
//  Created by litao on 16/5/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCCustomerServiceInfo : NSObject
@property(nonatomic, strong) NSString *userId;      //用户唯一标识
@property(nonatomic, strong) NSString *nickName;    //用户昵称
@property(nonatomic, strong) NSString *loginName;   //用户登录名
@property(nonatomic, strong) NSString *name;        //用户名称
@property(nonatomic, strong) NSString *grade;       //用户等级
@property(nonatomic, strong) NSString *gender;      //用户性别
@property(nonatomic, strong) NSString *birthday;    //用户生日
@property(nonatomic, strong) NSString *age;         //年龄
@property(nonatomic, strong) NSString *profession;  //职业
@property(nonatomic, strong) NSString *portraitUrl; //头像
@property(nonatomic, strong) NSString *province;    //省份
@property(nonatomic, strong) NSString *city;        //城市
@property(nonatomic, strong) NSString *memo;        //备注

@property(nonatomic, strong) NSString *mobileNo; //电话号码
@property(nonatomic, strong) NSString *email;    //邮箱
@property(nonatomic, strong) NSString *address;  //地址
@property(nonatomic, strong) NSString *QQ; // QQ号
@property(nonatomic, strong) NSString *weibo;  //微博
@property(nonatomic, strong) NSString *weixin; //微信

@property(nonatomic, strong) NSString *page;     //页面信息
@property(nonatomic, strong) NSString *referrer; //来源
@property(nonatomic, strong) NSString *enterUrl; //
@property(nonatomic, strong) NSString *skillId;
@property(nonatomic, strong) NSArray *listUrl;
@property(nonatomic, strong) NSString *define; //自定义信息
- (NSData *)encode;
@end
