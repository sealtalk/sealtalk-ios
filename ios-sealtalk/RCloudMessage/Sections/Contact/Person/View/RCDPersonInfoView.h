//
//  RCDPersonInfoView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/5/29.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCDFriendInfo;
NS_ASSUME_NONNULL_BEGIN

@interface RCDPersonInfoView : UIView

- (void)setUserInfo:(RCDFriendInfo *)userInfo;

- (void)setGroupNickname:(NSString *)groupNickname;
@end

NS_ASSUME_NONNULL_END
