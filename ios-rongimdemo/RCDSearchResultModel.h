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

@property(nonatomic, assign) RCConversationType conversationType;

@property(nonatomic, assign) RCDSearchType searchType;

@property(nonatomic, strong) NSString *targetId;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSString *portraitUri;

@property(nonatomic, strong) NSString *otherInformation;

@property(nonatomic, assign) int count;

@property(nonatomic, copy) NSString *objectName;

@property(nonatomic, assign) long long time;
@end
