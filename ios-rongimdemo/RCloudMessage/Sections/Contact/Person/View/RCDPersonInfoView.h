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

@protocol RCDPersonInfoViewDelegate <NSObject>

- (void)personInfoViewDidTapPhoneNumber:(NSString *)phoneNumber;

@end

@interface RCDPersonInfoView : UIView

@property (nonatomic, weak) id<RCDPersonInfoViewDelegate> delegate;

- (void)setUserInfo:(RCDFriendInfo *)userInfo;
- (void)setUserPhoneNumer:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
