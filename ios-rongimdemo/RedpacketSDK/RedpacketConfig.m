//
//  RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketConfig.h"
#import <RongIMKit/RongIMKit.h>
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "AppDelegate+RedPacket.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessageModel.h"

@interface RedpacketConfig ()<YZHRedpacketBridgeDelegate>

@property (nonatomic,strong)RedpacketRegisitModel * regisitModel;

@end

@implementation RedpacketConfig

+ (instancetype)sharedConfig
{
    static RedpacketConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[RedpacketConfig alloc] init];
        [[YZHRedpacketBridge sharedBridge] setDataSource:config];
        [[YZHRedpacketBridge sharedBridge] setDelegate:config];
        [[YZHRedpacketBridge sharedBridge] setRedacketURLScheme:@"cn.rongcloud.im"];
        [AppDelegate swizzleRedPacketMethod];
    });
    return config;
}


- (RedpacketUserInfo *)redpacketUserInfo {
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    RCUserInfo *info = [[RCIM sharedRCIM] getUserInfoCache:[RCIM sharedRCIM].currentUserInfo.userId];
    user.userId = info.userId;
    user.userNickname = info.name;
    user.userAvatar = info.portraitUri;
    return user;
}

- (void)redpacketFetchRegisitParam:(FetchRegisitParamBlock)fetchBlock withError:(NSError *)error {
    NSString *userId = [RCIM sharedRCIM].currentUserInfo.userId;
    [YZHRedpacketBridge sharedBridge].isDebug = YES;
    if(userId) {
        // 获取应用自己的签名字段。实际应用中需要开发者自行提供相应在的签名计算服务
        NSString *urlStr = [NSString stringWithFormat:@"https://rpv2.yunzhanghu.com/api/sign?duid=%@&dcode=1101#testrongyun", userId];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                                  NSString *partner = [responseObject valueForKey:@"partner"];
                                                                                  NSString *appUserId = [responseObject valueForKey:@"user_id"];
                                                                                  NSString *timeStamp = [responseObject valueForKey:@"timestamp"];
                                                                                  NSString *sign = [responseObject valueForKey:@"sign"];
                                                                                  RedpacketRegisitModel * regisitModel = [RedpacketRegisitModel signModelWithAppUserId:appUserId signString:sign partner:partner andTimeStamp:timeStamp];
                                                                                  fetchBlock(regisitModel);
                                                                              }
                                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              fetchBlock(nil);
                                                                              NSLog(@"request redpacket sign failed:%@", error);
                                                                          }] start];
    }
}

@end
