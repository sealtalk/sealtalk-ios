//
//  RCDDebubMessageUIdList.h
//  SealTalk
//
//  Created by 张改红 on 2020/8/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDTableView.h"
#import <RongIMKit/RongIMKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCDDebubMessageUIdListView : RCDTableView
+ (void)showMessageUIdListView:(UIView *)inview conversationType:(RCConversationType)type targetId:(NSString *)targetId selectMessageBlock:(void (^)(RCMessage *message))selectMessageBlock;
@end

NS_ASSUME_NONNULL_END
