//
//  RCPTTSession.h
//  RongPTTLib
//
//  Created by LiFei on 2017/1/12.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>

@interface RCPTTSession : NSObject
@property(nonatomic) RCConversationType conversationType;
@property(nonatomic, strong) NSString *targetId;
@property(nonatomic, strong) NSString *micHolder;
@property(nonatomic, strong) NSArray<NSString *> *participants;

- (instancetype)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId;

- (BOOL)isEqual:(id)object;
@end
