//
//  HeadCollectionView.h
//  LocationSharer
//
//  Created by 岑裕 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>

#pragma mark delegate
@protocol HeadCollectionTouchDelegate <NSObject>
- (void)onUserSelected:(RCUserInfo *)user atIndex:(NSUInteger)index;
@optional
- (BOOL)quitButtonPressed;
- (BOOL)backButtonPressed;
@end

@interface HeadCollectionView : UIView

@property(nonatomic, strong) UIButton *quitButton;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, assign) RCUserAvatarStyle avatarStyle;
@property(nonatomic, weak) id<HeadCollectionTouchDelegate> touchDelegate;

#pragma mark init
- (instancetype)initWithFrame:(CGRect)frame participants:(NSArray *)userIds touchDelegate:touchDelegate;

- (instancetype)initWithFrame:(CGRect)frame
                 participants:(NSArray *)userIds
                touchDelegate:touchDelegate
              userAvatarStyle:(RCUserAvatarStyle)avatarStyle;

#pragma mark user source processing
- (BOOL)participantJoin:(NSString *)userId;
- (BOOL)participantQuit:(NSString *)userId;
- (NSArray *)getParticipantsUserInfo;

@end
