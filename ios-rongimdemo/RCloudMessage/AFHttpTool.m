
//
//  AFHttpTool.m
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AFHttpTool.h"
#import "AFNetworking.h"
#import "RCDCommonDefine.h"
#import <RongIMKit/RongIMKit.h>

#import "RCDSettingUserDefaults.h"

#define DevDemoServer                                                          \
  @"http://119.254.110.241/" // Beijing SUN-QUAN 测试环境（北京）
#define ProDemoServer                                                          \
  @"http://119.254.110.79:8080/" // Beijing Liu-Bei 线上环境（北京）
#define PrivateCloudDemoServer @"http://139.217.26.223/" //私有云测试

#define DemoServer @"http://api.sealtalk.im/" //线上正式环境
//#define DemoServer @"http://apiqa.rongcloud.net/" //线上非正式环境
//#define DemoServer @"http://api.hitalk.im/" //测试环境

//#define ContentType @"text/plain"
#define ContentType @"application/json"

@implementation AFHttpTool

+ (AFHttpTool *)shareInstance {
  static AFHttpTool *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
    NSURL *baseURL =  nil;
    BOOL isPrivateMode = NO;
#if RCDPrivateCloudManualMode
    isPrivateMode = YES;
#endif
  
    if(isPrivateMode){
        NSString *baseStr = [RCDSettingUserDefaults getRCDemoServer];
        baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",baseStr]];
    }else {
        baseURL = [NSURL URLWithString:DemoServer];
    }
  //获得请求管理者
  AFHTTPRequestOperationManager *mgr =
      [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

#ifdef ContentType
  mgr.responseSerializer.acceptableContentTypes =
      [NSSet setWithObject:ContentType];
#endif
  mgr.requestSerializer.HTTPShouldHandleCookies = YES;

  NSString *cookieString =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCookies"];

  if (cookieString)
    [mgr.requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];

  url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
  switch (methodType) {
  case RequestMethodTypeGet: {
    // GET请求
    [mgr GET:url
        parameters:params
        success:^(AFHTTPRequestOperation *operation,
                  NSDictionary *responseObj) {
          if (success) {

            success(responseObj);
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
            failure(error);
          }
        }];

  } break;

  case RequestMethodTypePost: {
    // POST请求
    [mgr POST:url
        parameters:params
        success:^(AFHTTPRequestOperation *operation,
                  NSDictionary *responseObj) {
          if (success) {
            if ([url isEqualToString:@"user/login"]) {
              NSString *cookieString = [[operation.response allHeaderFields]
                  valueForKey:@"Set-Cookie"];
              NSMutableString *finalCookie = [NSMutableString new];
              //                      NSData *data = [NSKeyedArchiver
              //                      archivedDataWithRootObject:cookieString];
              NSArray *cookieStrings =
                  [cookieString componentsSeparatedByString:@","];
              for (NSString *temp in cookieStrings) {
                NSArray *tempArr = [temp componentsSeparatedByString:@";"];
                [finalCookie
                    appendString:[NSString
                                     stringWithFormat:@"%@;", tempArr[0]]];
              }
              [[NSUserDefaults standardUserDefaults] setObject:finalCookie
                                                        forKey:@"UserCookies"];
              [[NSUserDefaults standardUserDefaults] synchronize];
            }
            success(responseObj);
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
            failure(error);
          }
        }];
  } break;
  default:
    break;
  }
}

// check phone available
+ (void)checkPhoneNumberAvailable:(NSString *)region
                      phoneNumber:(NSString *)phoneNumber
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"region" : region, @"phone" : phoneNumber };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/check_phone_available"
                         params:params
                        success:success
                        failure:failure];
}

// get verification code
+ (void)getVerificationCode:(NSString *)region
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"region" : region, @"phone" : phoneNumber };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/send_code"
                         params:params
                        success:success
                        failure:failure];
}

// verfify verification code
+ (void)verifyVerificationCode:(NSString *)region
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"region" : region,
    @"phone" : phoneNumber,
    @"code" : verificationCode
  };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/verify_code"
                         params:params
                        success:success
                        failure:failure];
}

// reg nickname password verficationToken
+ (void)registerWithNickname:(NSString *)nickname
                    password:(NSString *)password
            verficationToken:(NSString *)verficationToken
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"nickname" : nickname,
    @"password" : password,
    @"verification_token" : verficationToken
  };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/register"
                         params:params
                        success:success
                        failure:failure];
}

// login
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
                region:(NSString *)region
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"region" : region,
    @"phone" : phone,
    @"password" : password
  };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/login"
                         params:params
                        success:success
                        failure:failure];
}

// modify nickname
+ (void)modifyNickname:(NSString *)userId
              nickname:(NSString *)nickname
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"nickname" : nickname };

  [AFHttpTool
      requestWihtMethod:RequestMethodTypePost
                    url:[NSString
                            stringWithFormat:@"/user/set_nickname?userId=%@",
                                             userId]
                 params:params
                success:success
                failure:failure];
}

// change password
+ (void)changePassword:(NSString *)oldPwd
                newPwd:(NSString *)newPwd
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"oldPassword" : oldPwd, @"newPassword" : newPwd };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/change_password"
                         params:params
                        success:success
                        failure:failure];
}

// reset password
+ (void)resetPassword:(NSString *)password
               vToken:(NSString *)verification_token
              success:(void (^)(id response))success
              failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"password" : password,
    @"verification_token" : verification_token
  };

  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/reset_password"
                         params:params
                        success:success
                        failure:failure];
}

// get user info
+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:[NSString stringWithFormat:@"user/%@", userId]
                         params:nil
                        success:success
                        failure:failure];
}

// set user portraitUri
+ (void)setUserPortraitUri:(NSString *)portraitUrl
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"portraitUri" : portraitUrl };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/set_portrait_uri"
                         params:params
                        success:success
                        failure:failure];
}

// invite user
+ (void)inviteUser:(NSString *)userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"friendId" : userId,
    @"message" : [NSString stringWithFormat:@"我是%@",[RCIM sharedRCIM].currentUserInfo.name]};
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"friendship/invite"
                         params:params
                        success:success
                        failure:failure];
}

// find user by phone
+ (void)findUserByPhone:(NSString *)Phone
                success:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure {
  [AFHttpTool
      requestWihtMethod:RequestMethodTypeGet
                    url:[NSString stringWithFormat:@"user/find/86/%@", Phone]
                 params:nil
                success:success
                failure:failure];
}

// get token
+ (void)getTokenSuccess:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"user/get_token"
                         params:nil
                        success:success
                        failure:failure];
}

// get friends
+ (void)getFriendsSuccess:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
  //获取包含自己在内的全部注册用户数据
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"friends"
                         params:nil
                        success:success
                        failure:failure];
}

// get upload image token
+ (void)getUploadImageTokensuccess:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"user/get_image_token"
                         params:nil
                        success:success
                        failure:failure];
}

// upload file
+ (void)uploadFile:(NSData *)fileData
            userId:(NSString *)userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure {
  [AFHttpTool getUploadImageTokensuccess:^(id response) {
    if ([response[@"code"] integerValue] == 200) {
      NSDictionary *result = response[@"result"];
      NSString *defaultDomain = result[@"domain"];
      NSString *uploadUrl = result[@"upload_url"];
      if (uploadUrl.length > 0 && ![uploadUrl hasPrefix:@"http"]) {
        uploadUrl = [NSString stringWithFormat:@"http://%@",uploadUrl];
      }
      [DEFAULTS setObject:defaultDomain forKey:@"QiNiuDomain"];
      [DEFAULTS synchronize];

      //设置七牛的Token
      NSString *token = result[@"token"];
      NSMutableDictionary *params = [NSMutableDictionary new];
      [params setValue:token forKey:@"token"];

      //获取系统当前的时间戳
      NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
      NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
      NSString *timeString = [NSString stringWithFormat:@"%f", now];
      NSString *key = [NSString stringWithFormat:@"%@%@", userId, timeString];
      //去掉字符串中的.
      NSMutableString *str = [NSMutableString stringWithString:key];
      for (int i = 0; i < str.length; i++) {
        unichar c = [str characterAtIndex:i];
        NSRange range = NSMakeRange(i, 1);
        if (c == '.') { //此处可以是任何字符
          [str deleteCharactersInRange:range];
          --i;
        }
      }
      key = [NSString stringWithString:str];
      [params setValue:key forKey:@"key"];

      NSMutableDictionary *ret = [NSMutableDictionary dictionary];
      [params addEntriesFromDictionary:ret];

      NSString *url = uploadUrl.length > 0 ? uploadUrl : @"https://up.qbox.me";

      NSData *imageData = fileData;

      AFHTTPRequestOperationManager *manager =
          [AFHTTPRequestOperationManager manager];
      if (uploadUrl.length > 0) {
        NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
        [contentTypes addObject:@"text/html"];
        manager.responseSerializer.acceptableContentTypes = [contentTypes copy];
      }
      [manager POST:url
          parameters:params
          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData
                                        name:@"file"
                                    fileName:key
                                    mimeType:@"application/octet-stream"];
          }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (uploadUrl.length > 0) {
              NSMutableDictionary* responseDic = [[NSMutableDictionary alloc] initWithDictionary:responseObject];
              [responseDic setValue:defaultDomain forKey:@"domain"];
               success([responseDic copy]);
            }
            else{
              success(responseObject);
            }
           
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败");
          }];
    }
  }
      failure:^(NSError *err){

      }];
}

// get square info
+ (void)getSquareInfoSuccess:(void (^)(id response))success
                     Failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"misc/demo_square"
                         params:nil
                        success:success
                        failure:failure];
}

// create group
+ (void)createGroupWithGroupName:(NSString *)groupName
                 groupMemberList:(NSArray *)groupMemberList
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"name" : groupName,
    @"memberIds" : groupMemberList
  };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/create"
                         params:params
                        success:success
                        failure:failure];
}

+ (void)getMyGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"user/groups"
                         params:nil
                        success:success
                        failure:failure];
}

// get group by id
+ (void)getGroupByID:(NSString *)groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:[NSString stringWithFormat:@"group/%@", groupID]
                         params:nil
                        success:success
                        failure:failure];
}

// set group portraitUri
+ (void)setGroupPortraitUri:(NSString *)portraitUrl
                    groupId:(NSString *)groupId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
    @"groupId" : groupId,
    @"portraitUri" : portraitUrl
  };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/set_portrait_uri"
                         params:params
                        success:success
                        failure:failure];
}

// get group members by id
+ (void)getGroupMembersByID:(NSString *)groupID
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  [AFHttpTool
      requestWihtMethod:RequestMethodTypeGet
                    url:[NSString stringWithFormat:@"group/%@/members", groupID]
                 params:nil
                success:success
                failure:failure];
}

// join group by groupId
+ (void)joinGroupWithGroupId:(NSString *)groupID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/join"
                         params:params
                        success:success
                        failure:failure];
}

// add users into group
+ (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID, @"memberIds" : usersId };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/add"
                         params:params
                        success:success
                        failure:failure];
}

// kick users out of group
+ (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID, @"memberIds" : usersId };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/kick"
                         params:params
                        success:success
                        failure:failure];
}

// quit group with groupId
+ (void)quitGroupWithGroupId:(NSString *)groupID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/quit"
                         params:params
                        success:success
                        failure:failure];
}

// dismiss group with groupId
+ (void)dismissGroupWithGroupId:(NSString *)groupID
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/dismiss"
                         params:params
                        success:success
                        failure:failure];
}

// rename group with groupId
+ (void)renameGroupWithGroupId:(NSString *)groupID
                     GroupName:(NSString *)groupName
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"groupId" : groupID, @"name" : groupName };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"group/rename"
                         params:params
                        success:success
                        failure:failure];
}

+ (void)getFriendListFromServerSuccess:(void (^)(id))success
                        failure:(void (^)(NSError *))failure {
  //获取除自己之外的好友信息
  [AFHttpTool
      requestWihtMethod:RequestMethodTypeGet
                    url:[NSString stringWithFormat:@"friendship/all"]
                 params:nil
                success:success
                failure:failure];
}

+ (void)processInviteFriendRequest:(NSString *)friendUserId
                      currentUseId:(NSString *)currentUserId
                              time:(NSString *)now
                           success:(void (^)(id))success
                           failure:(void (^)(NSError *))failure {
  NSDictionary *params = @{
    @"friendId" : friendUserId,
    @"currentUserId" : currentUserId,
    @"time" : now
  };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"agree"
                         params:params
                        success:success
                        failure:failure];
}

+ (void)processInviteFriendRequest:(NSString *)friendUserId
                           success:(void (^)(id))success
                           failure:(void (^)(NSError *))failure {
  NSDictionary *params = @{ @"friendId" : friendUserId };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"friendship/agree"
                         params:params
                        success:success
                        failure:failure];
}

//加入黑名单
+ (void)addToBlacklist:(NSString *)userId
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"friendId" : userId };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/add_to_blacklist"
                         params:params
                        success:success
                        failure:failure];
}

//从黑名单中移除
+ (void)removeToBlacklist:(NSString *)userId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{ @"friendId" : userId };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"user/remove_from_blacklist"
                         params:params
                        success:success
                        failure:failure];
}

//获取黑名单列表
+ (void)getBlacklistsuccess:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"user/blacklist"
                         params:nil
                        success:success
                        failure:failure];
}

//讨论组接口，暂时保留
+ (void)updateName:(NSString *)userName
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"update_profile"
                         params:@{
                           @"username" : userName
                         }
                        success:success
                        failure:failure];
}

//获取版本信息
+ (void)getVersionsuccess:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                            url:@"/misc/client_version"
                         params:nil
                        success:success
                        failure:failure];
}

//设置好友备注
+ (void)setFriendDisplayName:(NSString *)friendId
                 displayName:(NSString *)displayName
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  NSDictionary *params = @{
                           @"friendId" : friendId,
                           @"displayName" : displayName
                           };
  [AFHttpTool requestWihtMethod:RequestMethodTypePost
                            url:@"friendship/set_display_name"
                         params:params
                        success:success
                        failure:failure];
}

//获取用户详细资料
+ (void)getFriendDetailsByID:(NSString *)friendId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure {
  [AFHttpTool
   requestWihtMethod:RequestMethodTypeGet
   url:[NSString stringWithFormat:@"friendship/%@/profile", friendId]
   params:nil
   success:success
   failure:failure];
}
@end
