//
//  RCDPokeManager.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface RCDPokeManager : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, assign) BOOL isShowPokeAlert;
@property (nonatomic, assign) BOOL isShowPokeVC;
@property (nonatomic, strong) RCConversation *currentConversation;
- (BOOL)isHoldReceivePokeManager:(RCMessage *)message;
- (void)saveSendPokeTime:(RCConversationType)type targetId:(NSString *)targetId;
- (NSInteger)getLastSendPokeTimeInterval:(RCConversationType)type targetId:(NSString *)targetId;
;
@end
