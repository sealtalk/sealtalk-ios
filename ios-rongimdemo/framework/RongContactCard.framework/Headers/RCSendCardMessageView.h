//
//  RCSendCardMessageView.h
//  RCloudMessage
//
//  Created by Jue on 2016/12/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>

@interface RCSendCardMessageView : UIView

@property(nonatomic, strong)RCUserInfo *cardUserInfo;

- (void)setConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId;

@end
