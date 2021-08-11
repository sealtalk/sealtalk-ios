//
//  HeadCollectionView.m
//  LocationSharer
//
//  Created by 岑裕 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "HeadCollectionView.h"
#import "RTLUtilities.h"
#import "RealTimeLocationDefine.h"

@interface HeadCollectionView ()

@property (nonatomic) CGRect headViewRect;
@property (nonatomic) CGFloat headViewSize;
@property (nonatomic) CGFloat headViewSpace;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *headsView;
@property (nonatomic, strong) NSMutableArray *rcUserInfos;

@end

@implementation HeadCollectionView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame participants:(NSArray *)userIds touchDelegate:touchDelegate {
    self = [[HeadCollectionView alloc] initWithFrame:frame
                                        participants:userIds
                                       touchDelegate:touchDelegate
                                     userAvatarStyle:RC_USER_AVATAR_CYCLE];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                 participants:(NSArray *)userIds
                touchDelegate:touchDelegate
              userAvatarStyle:(RCUserAvatarStyle)avatarStyle {
    self = [super initWithFrame:frame];

    if (self) {
        self.touchDelegate = touchDelegate;
        self.avatarStyle = avatarStyle;

        [self setupSubviews];

        for (NSString *userId in userIds) {
            [self addUser:userId showChange:NO];
        }
    }

    return self;
}

- (void)layoutSubviews {
    if ([RTLUtilities isRTL]) {
        self.quitButton.frame = CGRectMake(self.bounds.size.width - 12 - 24, [RCKitUtility getWindowSafeAreaInsets].top+10, 24, 24);
        self.backButton.frame = CGRectMake(8, [RCKitUtility getWindowSafeAreaInsets].top+10, 26, 26);
    } else {
        self.backButton.frame = CGRectMake(self.bounds.size.width - 12 - 24, [RCKitUtility getWindowSafeAreaInsets].top+10, 24, 24);
        self.quitButton.frame = CGRectMake(8, [RCKitUtility getWindowSafeAreaInsets].top+10, 26, 26);
    }
//    self.tipLabel.frame = CGRectMake(0, 24 + self.headViewSize + 12, self.headViewRect.size.width, 13);
    self.tipLabel.frame = CGRectMake(self.headViewRect.origin.x, CGRectGetMaxY(self.headViewRect) + 10,
    self.headViewRect.size.width, 15);
    CGPoint tipLabelCenter = self.tipLabel.center;
    tipLabelCenter.x = self.center.x;
    self.tipLabel.center = tipLabelCenter;

    CGPoint scrollViewCenter = self.scrollView.center;
    scrollViewCenter.x = self.center.x;
    self.scrollView.center = scrollViewCenter;
}

- (BOOL)addUserInfoIfNeed:(RCUserInfo *)userInfo {
    for (RCUserInfo *user in self.rcUserInfos) {
        if ([userInfo.userId isEqualToString:user.userId]) {
            return NO;
        }
    }
    [self.rcUserInfos addObject:userInfo];
    return YES;
}

#pragma mark - public api（user source processing）
- (BOOL)participantJoin:(NSString *)userId {
    return [self addUser:userId showChange:YES];
}

- (BOOL)participantQuit:(NSString *)userId {
    return [self removeUser:userId showChange:YES];
}

- (NSArray *)getParticipantsUserInfo {
    return [self.rcUserInfos copy];
}

#pragma mark - taget action
- (void)onUserSelected:(UITapGestureRecognizer *)tap {
    UIImageView *selectUserHead = (UIImageView *)tap.view;
    NSUInteger index = [self.headsView indexOfObject:selectUserHead];
    RCUserInfo *user = self.rcUserInfos[index];

    if (self.touchDelegate) {
        [self.touchDelegate onUserSelected:user atIndex:index];
    }
}

- (void)onQuitButtonPressed:(id)sender {
    if (self.touchDelegate) {
        [self.touchDelegate quitButtonPressed];
    }
}
- (void)onBackButtonPressed:(id)sender {
    if (self.touchDelegate) {
        [self.touchDelegate backButtonPressed];
    }
}
#pragma mark - helper
- (BOOL)addUser:(NSString *)userId showChange:(BOOL)show {
    if (userId && [self getUserIndex:userId] < 0) {
        if ([RCIM sharedRCIM].userInfoDataSource &&
            [[RCIM sharedRCIM].userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
            [[RCIM sharedRCIM]
                    .userInfoDataSource
                getUserInfoWithUserId:userId
                           completion:^(RCUserInfo *user) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   RCUserInfo *userInfo = user;
                                   if (!userInfo) {
                                       userInfo = [[RCUserInfo alloc]
                                           initWithUserId:userId
                                                     name:[NSString stringWithFormat:@"user<%@>", userId]
                                                 portrait:nil];
                                   }
                                   if ([self addUserInfoIfNeed:userInfo]) {
                                       [self addHeadViewUser:userInfo];
                                       if (show) {
                                           [self showUserChangeInfo:[NSString stringWithFormat:RTLLocalizedString(@"join_share_location"), [RCKitUtility getDisplayName:user]]];
                                       } else {
                                           self.tipLabel.text = [NSString stringWithFormat:RTLLocalizedString(@"share_location_people_count"), (unsigned long)self.rcUserInfos.count];
                                       }
                                   }
                               });
                           }];
        } else {
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:userId portrait:nil];
            if ([self addUserInfoIfNeed:userInfo]) {
                [self addHeadViewUser:userInfo];
                if (show) {
                    [self showUserChangeInfo:[NSString stringWithFormat:RTLLocalizedString(@"join_share_location"), [RCKitUtility getDisplayName:userInfo]]];
                } else {
                    self.tipLabel.text = [NSString stringWithFormat:RTLLocalizedString(@"share_location_people_count"), (unsigned long)self.rcUserInfos.count];
                }
            }
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)removeUser:(NSString *)userId showChange:(BOOL)show {
    if (userId) {
        NSInteger index = [self getUserIndex:userId];
        if (index >= 0) {
            RCUserInfo *userInfo = self.rcUserInfos[index];
            [self.rcUserInfos removeObjectAtIndex:index];
            [self removeHeadViewUser:index];
            if (show) {
                [self showUserChangeInfo:[NSString stringWithFormat:@"%@退出...", [RCKitUtility getDisplayName:userInfo]]];
            } else {
                self.tipLabel.text = [NSString stringWithFormat:RTLLocalizedString(@"share_location_people_count"),
                                                                (unsigned long)self.rcUserInfos.count];
            }
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)showUserChangeInfo:(NSString *)changInfo {
    self.tipLabel.text = changInfo;
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(showUserShareInfo)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)showUserShareInfo {
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.text = [NSString
        stringWithFormat:RTLLocalizedString(@"share_location_people_count"), (unsigned long)self.rcUserInfos.count];
}

- (void)addHeadViewUser:(RCUserInfo *)user {
    {
        CGFloat scrollViewWidth = [self getScrollViewWidth];
        UIImageView *userHead = [[UIImageView alloc] init];
        [RTLUtilities setImageWithURL:[NSURL URLWithString:user.portraitUri]
                     placeholderImage:RCResourceImage(@"default_portrait_msg")
                            imageView:userHead];
        [userHead setFrame:CGRectMake(scrollViewWidth - self.headViewSize, 0, self.headViewSize, self.headViewSize)];

        if (self.avatarStyle == RC_USER_AVATAR_CYCLE) {
            userHead.layer.cornerRadius = self.headViewSize / 2;
            userHead.layer.masksToBounds = YES;
        }
        userHead.layer.borderWidth = 1.0f;
        userHead.layer.borderColor = [UIColor whiteColor].CGColor;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserSelected:)];
        [userHead addGestureRecognizer:tap];
        userHead.userInteractionEnabled = YES;

        [self.headsView addObject:userHead];
        [self.scrollView addSubview:userHead];
        if (scrollViewWidth < self.headViewRect.size.width) {
            [self.scrollView
                setFrame:CGRectMake((self.frame.size.width - scrollViewWidth) / 2, self.headViewRect.origin.y,
                                    scrollViewWidth, self.headViewRect.size.height)];
        } else {
            [self.scrollView setFrame:self.headViewRect];
        }
        [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.frame.size.height)];
    }
}

- (void)removeHeadViewUser:(NSUInteger)index {
    CGFloat scrollViewWidth = [self getScrollViewWidth];
    UIImageView *removeUserHead = [self.headsView objectAtIndex:index];

    for (NSUInteger i = index + 1; i < [self.headsView count]; i++) {
        UIImageView *userHead = self.headsView[i];
        [userHead setFrame:CGRectMake(userHead.frame.origin.x - self.headViewSize - self.headViewSpace, 0,
                                      self.headViewSize, self.headViewSize)];
    }

    [self.headsView removeObject:removeUserHead];
    [removeUserHead removeFromSuperview];
    if (scrollViewWidth < self.headViewRect.size.width) {
        [self.scrollView setFrame:CGRectMake((self.frame.size.width - scrollViewWidth) / 2, self.headViewRect.origin.y,
                                             scrollViewWidth, self.headViewRect.size.height)];
    } else {
        [self.scrollView setFrame:self.headViewRect];
    }
    [self.scrollView setContentSize:CGSizeMake(scrollViewWidth, self.scrollView.frame.size.height)];
}

- (NSInteger)getUserIndex:(NSString *)userId {
    for (NSUInteger index = 0; index < self.rcUserInfos.count; index++) {
        RCUserInfo *user = self.rcUserInfos[index];
        if ([userId isEqualToString:user.userId]) {
            return index;
        }
    }

    return -1;
}

- (CGFloat)getScrollViewWidth {
    if (self.rcUserInfos && self.rcUserInfos.count > 0) {
        return self.rcUserInfos.count * self.headViewSize + (self.rcUserInfos.count - 1) * self.headViewSpace;
    } else {
        return 0.0f;
    }
}

// copy from IMKit because of none head view interface
- (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
    UIImage *image = nil;
    NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];

    image = [[UIImage alloc] initWithContentsOfFile:image_path];

    return image;
}

- (void)setupSubviews {
    self.headsView = [[NSMutableArray alloc] init];
    self.rcUserInfos = [[NSMutableArray alloc] init];
    [self setBackgroundColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.6]];
    self.headViewSize = 34;
    self.headViewSpace = 8;
    self.headViewRect = CGRectMake(8 + 26 + 8, [RCKitUtility getWindowSafeAreaInsets].top+10 , self.frame.size.width - (8 + 26 + 8) * 2, self.headViewSize);

    UIButton *quitButton = [[UIButton alloc] initWithFrame:CGRectMake(12, [RCKitUtility getWindowSafeAreaInsets].top+10, 24, 24)];
    [quitButton setImage:[UIImage imageNamed:@"quit_location_share"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(onQuitButtonPressed:) forControlEvents:UIControlEventTouchDown];
    self.quitButton = quitButton;
    [self addSubview:quitButton];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.headViewRect];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 12 - 24, [RCKitUtility getWindowSafeAreaInsets].top+10, 24, 24)];
    [backButton setImage:[UIImage imageNamed:@"back_to_conversation"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:backButton];
    self.backButton = backButton;
    if ([RTLUtilities isRTL]) {
        self.quitButton.frame = CGRectMake(self.bounds.size.width - 8 - 26, [RCKitUtility getWindowSafeAreaInsets].top+10, 26, 26);
        self.backButton.frame = CGRectMake(8, [RCKitUtility getWindowSafeAreaInsets].top+10, 26, 26);
    }

    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headViewRect.origin.x, CGRectGetMaxY(self.headViewRect) + 10,
                                                              self.headViewRect.size.width, 15)];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.font = [UIFont boldSystemFontOfSize:13];
    [self showUserShareInfo];
    [self addSubview:self.tipLabel];
}
@end
