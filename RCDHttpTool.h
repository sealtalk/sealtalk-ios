//
//  RCDHttpTool.h
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDUserInfo.h"
#import <Foundation/Foundation.h>
#import <RongIMLib/RCGroup.h>
#import <RongIMLib/RCUserInfo.h>
#import <UIKit/UIKit.h>
#define RCDHTTPTOOL [RCDHttpTool shareInstance]

@interface RCDHttpTool : NSObject

@property(nonatomic, strong) NSMutableArray *allFriends;
@property(nonatomic, strong) NSMutableArray *allGroups;

+ (RCDHttpTool *)shareInstance;

//查看是否好友
- (void)isMyFriendWithUserInfo:(RCDUserInfo *)userInfo
                    completion:(void (^)(BOOL isFriend))completion;

//获取个人信息
- (void)getUserInfoByUserID:(NSString *)userID
                 completion:(void (^)(RCUserInfo *user))completion;

//设置个人头像地址
- (void)setUserPortraitUri:(NSString *)portraitUri
                  complete:(void (^)(BOOL))result;

//创建群组
- (void)createGroupWithGroupName:(NSString *)groupName
                 GroupMemberList:(NSArray *)groupMemberList
                        complete:(void (^)(NSString *))userId;

//设置群组头像
- (void)setGroupPortraitUri:(NSString *)portraitUri
                    groupId:(NSString *)groupId
                   complete:(void (^)(BOOL))result;

////创建群组
//-(void) setGroupPortrait:(NSString *)groupName
//              GroupMemberList:(NSArray *)groupMemberList
//                     complete:(void (^)(NSString *))userId;

//获取我的群组(新)
- (void)getMyGroupsWithBlock:(void (^)(NSMutableArray *result))block;

//获取群组列表
- (void)getAllGroupsWithCompletion:(void (^)(NSMutableArray *result))completion;

//根据id获取单个群组(新)
- (void)getGroupByID:(NSString *)groupID
   successCompletion:(void (^)(RCDGroupInfo *group))completion;

//获取群组成员列表(新)
- (void)getGroupMembersWithGroupId:(NSString *)groupId
                             Block:(void (^)(NSMutableArray *result))block;

//加入群组(新)
- (void)joinGroupWithGroupId:(NSString *)groupID
                    complete:(void (^)(BOOL))result;

//添加群组成员(新)
- (void)addUsersIntoGroup:(NSString *)groupID
                  usersId:(NSMutableArray *)usersId
                 complete:(void (^)(BOOL))result;

//将用户踢出群组
- (void)kickUsersOutOfGroup:(NSString *)groupID
                    usersId:(NSMutableArray *)usersId
                   complete:(void (^)(BOOL))result;
//退出群组(新)
- (void)quitGroupWithGroupId:(NSString *)groupID
                    complete:(void (^)(BOOL result))quitResult;

//解散群组(新)
- (void)dismissGroupWithGroupId:(NSString *)groupID
                       complete:(void (^)(BOOL result))quitResult;

//修改群组名称
- (void)renameGroupWithGoupId:(NSString *)groupID
                    groupName:(NSString *)groupName
                     complete:(void (^)(BOOL))result;

//加入群组
- (void)joinGroup:(int)groupID
    withGroupName:(NSString *)groupName
         complete:(void (^)(BOOL result))joinResult;

//退出群组
- (void)quitGroup:(int)groupID complete:(void (^)(BOOL result))quitResult;

//更新群组信息
- (void)updateGroupById:(int)groupID
          withGroupName:(NSString *)groupName
           andintroduce:(NSString *)introduce
               complete:(void (^)(BOOL result))result;

//获取广场信息
- (void)getSquareInfoCompletion:(void (^)(NSMutableArray *result))completion;

//获取好友列表
- (void)getFriendscomplete:(void (^)(NSMutableArray *))friendList;

//按昵称搜素好友
- (void)searchFriendListByName:(NSString *)name
                      complete:(void (^)(NSMutableArray *result))friendList;
//按邮箱搜素好友
- (void)searchFriendListByEmail:(NSString *)email
                       complete:(void (^)(NSMutableArray *result))friendList;
//通过手机号搜索好友
- (void)searchUserByPhone:(NSString *)phone
                 complete:(void (^)(NSMutableArray *))userList;

//请求加好友
- (void)requestFriend:(NSString *)userId complete:(void (^)(BOOL result))result;
//处理请求加好友
- (void)processInviteFriendRequest:(NSString *)userId
                          complete:(void (^)(BOOL))result;

- (void)processRequestFriend:(NSString *)userId
                withIsAccess:(BOOL)isAccess
                    complete:(void (^)(BOOL result))result;
//删除好友
- (void)deleteFriend:(NSString *)userId complete:(void (^)(BOOL result))result;

//加入黑名单
- (void)AddToBlacklist:(NSString *)userId
              complete:(void (^)(BOOL result))result;

//从黑名单中移除
- (void)RemoveToBlacklist:(NSString *)userId
                 complete:(void (^)(BOOL result))result;

//获取黑名单列表
- (void)getBlacklistcomplete:(void (^)(NSMutableArray *))blacklist;

//更新自己的用户名
- (void)updateName:(NSString *)userName
           success:(void (^)(id response))success
           failure:(void (^)(NSError *err))failure;

//从demo server 获取用户的信息，更新本地数据库
- (void)updateUserInfo:(NSString *)userID
               success:(void (^)(RCUserInfo *user))success
               failure:(void (^)(NSError *err))failure;

//上传图片到七牛的服务器
- (void)uploadImageToQiNiu:(NSString *)userId
                 ImageData:(NSData *)image
                   success:(void (^)(NSString *url))success
                   failure:(void (^)(NSError *err))failure;

- (void)getVersion:(void (^)(NSDictionary *result))block;

@end
