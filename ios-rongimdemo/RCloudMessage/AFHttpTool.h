//
//  AFHttpTool.h
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestMethodType) {
  RequestMethodTypePost = 1,
  RequestMethodTypeGet = 2
};

@interface AFHttpTool : NSObject

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success 请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure 请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

// login
+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
                region:(NSString *)region
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

// check phonenumber available
+ (void)checkPhoneNumberAvailable:(NSString *)region
                      phoneNumber:(NSString *)phoneNumber
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError *err))failure;

// get verification code
+ (void)getVerificationCode:(NSString *)region
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

// verfify verification code
+ (void)verifyVerificationCode:(NSString *)region
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure;

// reg nickname password verficationToken
+ (void)registerWithNickname:(NSString *)nickname
                    password:(NSString *)password
            verficationToken:(NSString *)verficationToken
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

// modify nickname
+ (void)modifyNickname:(NSString *)userId
              nickname:(NSString *)nickname
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

// change password
+ (void)changePassword:(NSString *)oldPwd
                newPwd:(NSString *)newPwd
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

// reset password
+ (void)resetPassword:(NSString *)password
               vToken:(NSString *)verification_token
              success:(void (^)(id response))success
              failure:(void (^)(NSError *err))failure;

// get user info
+ (void)getUserInfo:(NSString *)userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError *err))failure;

// set user portraitUri
+ (void)setUserPortraitUri:(NSString *)portraitUrl
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError *err))failure;

// invite user
+ (void)inviteUser:(NSString *)userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure;

// find user by phone
+ (void)findUserByPhone:(NSString *)Phone
                success:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure;

// get token
+ (void)getTokenSuccess:(void (^)(id response))success
                failure:(void (^)(NSError *err))failure;

// get friends
+ (void)getFriendsSuccess:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

// get upload image token
+ (void)getUploadImageTokensuccess:(void (^)(id response))success
                           failure:(void (^)(NSError *err))failure;

// upload file
+ (void)uploadFile:(NSData *)fileData
            userId:(NSString *)userId
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure;

// get square info
+ (void)getSquareInfoSuccess:(void (^)(id response))success
                     Failure:(void (^)(NSError *err))failure;
// create group
+ (void)createGroupWithGroupName:(NSString *)groupName
                 groupMemberList:(NSArray *)groupMemberList
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError *err))failure;

// get groups
+ (void)getMyGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError *err))failure;

// get group by id
+ (void)getGroupByID:(NSString *)groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError *err))failure;

// set group portraitUri
+ (void)setGroupPortraitUri:(NSString *)portraitUrl
                    groupId:(NSString *)groupId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

// get group members by id
+ (void)getGroupMembersByID:(NSString *)groupID
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

// join group by groupId
+ (void)joinGroupWithGroupId:(NSString *)groupID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

// add users into group
+ (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

// kick users out of group
+ (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

// quit group with groupId
+ (void)quitGroupWithGroupId:(NSString *)groupID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

// dismiss group with groupId
+ (void)dismissGroupWithGroupId:(NSString *)groupID
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError *err))failure;

// rename group with groupId
+ (void)renameGroupWithGroupId:(NSString *)groupID
                     GroupName:(NSString *)groupName
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError *err))failure;

//获取好友列表
+ (void)getFriendListFromServerSuccess:(void (^)(id))success
                               failure:(void (^)(NSError *))failure;

//处理请求加好友
+ (void)processInviteFriendRequest:(NSString *)friendUserId
                           success:(void (^)(id))success
                           failure:(void (^)(NSError *))failure;

+ (void)processInviteFriendRequest:(NSString *)friendUserId
                      currentUseId:(NSString *)currentUserId
                              time:(NSString *)now
                           success:(void (^)(id))success
                           failure:(void (^)(NSError *))failure;

//加入黑名单
+ (void)addToBlacklist:(NSString *)userId
               success:(void (^)(id response))success
               failure:(void (^)(NSError *err))failure;

//从黑名单中移除
+ (void)removeToBlacklist:(NSString *)userId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

//获取黑名单列表
+ (void)getBlacklistsuccess:(void (^)(id response))success
                    failure:(void (^)(NSError *err))failure;

//更新当前用户名称
+ (void)updateName:(NSString *)userName
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure;

//获取版本信息
+ (void)getVersionsuccess:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

//设置好友备注
+ (void)setFriendDisplayName:(NSString *)friendId
                 displayName:(NSString *)displayName
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

//获取用户详细资料
+ (void)getFriendDetailsByID:(NSString *)friendId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError *err))failure;

@end
