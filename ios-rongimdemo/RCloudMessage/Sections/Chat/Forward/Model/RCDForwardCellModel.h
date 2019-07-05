//
//  RCDForwardCellModel.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDForwardCellModel : NSObject

@property (nonatomic, copy) NSString *targetId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) RCConversationType conversationType;

+ (instancetype)createModelWith:(RCConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
