//
//  RCDSearchResultModel.h
//  RCloudMessage
//
//  Created by 张改红 on 16/9/12.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchDataManager.h"
#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
@interface RCDSearchResultModel : NSObject
//该字段需要单独设置，不会在 modelForMessage 设置
@property (nonatomic, assign) RCDSearchType searchType;

@property (nonatomic, assign) RCConversationType conversationType;

@property (nonatomic, copy) NSString *targetId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *portraitUri;

@property (nonatomic, copy) NSString *otherInformation;

@property (nonatomic, assign) int count;

@property (nonatomic, copy) NSString *objectName;

@property (nonatomic, assign) long long time;

+ (instancetype)modelForMessage:(RCMessage *)message;
@end
