//
//  RCDIMService.h
//  SealTalk
//
//  Created by 张改红 on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDIMService : NSObject

@property (nonatomic, strong) NSMutableDictionary *userInputStatus;

+ (instancetype)sharedService;
//清理历史消息
- (void)clearHistoryMessage:(RCConversationType)conversationType
                   targetId:(NSString *)targetId
               successBlock:(void (^)(void))successBlock
                 errorBlock:(void (^)(RCErrorCode status))errorBlock;
@end

NS_ASSUME_NONNULL_END
