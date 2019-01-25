//
//  RCPTTLibDelegate.h
//  RongPTTLib
//
//  Created by LiFei on 2017/1/20.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#ifndef RCPTTLibDelegate_h
#define RCPTTLibDelegate_h

@protocol RCPTTLibDelegate <NSObject>
- (void)sessionDidStart:(RCPTTSession *)session;

- (void)participantsDidChange:(NSArray *)userIds inPTTSession:(RCPTTSession *)session;

- (void)micHolderDidChange:(NSString *)userId inPTTSession:(RCPTTSession *)session;

- (void)sessionDidTerminate:(RCPTTSession *)session;

- (void)speakTimeDidExpire:(RCPTTSession *)session;
@end

#endif /* RCPTTLibDelegate_h */
