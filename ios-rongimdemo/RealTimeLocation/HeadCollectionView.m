//
//  HeadCollectionView.m
//  LocationSharer
//
//  Created by 岑裕 on 15/7/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "HeadCollectionView.h"
#import "RCDUtilities.h"
#import "UIImageView+WebCache.h"
@interface HeadCollectionView ()

@property(nonatomic) CGRect headViewRect;
@property(nonatomic) CGFloat headViewSize;
@property(nonatomic) CGFloat headViewSpace;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray *headsView;
@property(nonatomic, strong) NSMutableArray *rcUserInfos;

@end

@implementation HeadCollectionView

#pragma mark init
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

        self.headsView = [[NSMutableArray alloc] init];
        self.rcUserInfos = [[NSMutableArray alloc] init];
        self.touchDelegate = touchDelegate;
        self.avatarStyle = avatarStyle;
        [self setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
        self.headViewSize = 42;
        self.headViewSpace = 8;
        self.headViewRect = CGRectMake(8 + 26 + 8, 20 + 8, frame.size.width - (8 + 26 + 8) * 2, self.headViewSize);

        UIButton *quitButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 41.5, 26, 26)];
        [quitButton setImage:[UIImage imageNamed:@"quit_location_share"] forState:UIControlStateNormal];
        [quitButton addTarget:self action:@selector(onQuitButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:quitButton];

        self.scrollView = [[UIScrollView alloc] initWithFrame:self.headViewRect];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];

        UIButton *backButton =
            [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 8 - 26, 41.5, 26, 26)];
        [backButton setImage:[UIImage imageNamed:@"back_to_conversation"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(onBackButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:backButton];

        self.tipLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(self.headViewRect.origin.x, 20 + self.headViewSize + 12,
                                                      self.headViewRect.size.width, 13)];
        self.tipLabel.textAlignment = NSTextAlignmentCenter;
        self.tipLabel.font = [UIFont boldSystemFontOfSize:13];
        [self showUserShareInfo];
        [self addSubview:self.tipLabel];

        for (NSString *userId in userIds) {
            [self addUser:userId showChange:NO];
        }
    }

    return self;
}

#pragma mark user source processing
- (BOOL)participantJoin:(NSString *)userId {
    return [self addUser:userId showChange:YES];
}

- (BOOL)participantQuit:(NSString *)userId {
    return [self removeUser:userId showChange:YES];
}

- (BOOL)addUser:(NSString *)userId showChange:(BOOL)show {
    if (userId && [self getUserIndex:userId] < 0) {
        if ([RCIM sharedRCIM].userInfoDataSource &&
            [[RCIM sharedRCIM].userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
            [[RCIM sharedRCIM].userInfoDataSource
                getUserInfoWithUserId:userId
                           completion:^(RCUserInfo *userInfo) {
                               if (!userInfo) {
                                   userInfo = [[RCUserInfo alloc]
                                       initWithUserId:userId
                                                 name:[NSString stringWithFormat:@"user<%@>", userId]
                                             portrait:nil];
                               }
                               [self.rcUserInfos addObject:userInfo];
                               [self addHeadViewUser:userInfo];
                               if (show) {
                                   [self showUserChangeInfo:[NSString stringWithFormat:@"%@加入...", userInfo.name]];
                               } else {
                                   self.tipLabel.text = [NSString
                                       stringWithFormat:@"%lu人在共享位置", (unsigned long)self.rcUserInfos.count];
                               }
                           }];
        } else {
            RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:userId name:userId portrait:nil];
            [self.rcUserInfos addObject:userInfo];
            [self addHeadViewUser:userInfo];
            if (show) {
                [self showUserChangeInfo:[NSString stringWithFormat:@"%@加入...", userInfo.name]];
            } else {
                self.tipLabel.text =
                    [NSString stringWithFormat:@"%lu人在共享位置", (unsigned long)self.rcUserInfos.count];
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
                [self showUserChangeInfo:[NSString stringWithFormat:@"%@退出...", userInfo.name]];
            } else {
                self.tipLabel.text =
                    [NSString stringWithFormat:@"%lu人在共享位置", (unsigned long)self.rcUserInfos.count];
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
    self.tipLabel.textColor = [UIColor greenColor];
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self
                                   selector:@selector(showUserShareInfo)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)showUserShareInfo {
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.text = [NSString stringWithFormat:@"%lu人在共享位置", (unsigned long)self.rcUserInfos.count];
}

- (NSArray *)getParticipantsUserInfo {
    return [self.rcUserInfos copy];
}

- (void)addHeadViewUser:(RCUserInfo *)user {
    {
        CGFloat scrollViewWidth = [self getScrollViewWidth];
        UIImageView *userHead = [[UIImageView alloc] init];
        [userHead sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                    placeholderImage:[RCDUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];
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

- (void)onUserSelected:(UITapGestureRecognizer *)tap {
    UIImageView *selectUserHead = (UIImageView *)tap.view;
    NSUInteger index = [self.headsView indexOfObject:selectUserHead];
    RCUserInfo *user = self.rcUserInfos[index];

    if (self.touchDelegate) {
        [self.touchDelegate onUserSelected:user atIndex:index];
    }
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

//- (UIImage *)getHeadImage:(RCUserInfo *)user {
////    if (user.portraitUri) {
////        NSData *data = [NSData dataWithContentsOfURL:[NSURL
/// URLWithString:user.portraitUri]];
////        if (data) {
////            return [UIImage imageWithData:data];
////        } else {
////            return [self imageNamed:@"default_portrait_msg"
/// ofBundle:@"RongCloud.bundle"];
////        }
////    } else {
//        return [self imageNamed:@"default_portrait_msg"
//        ofBundle:@"RongCloud.bundle"];
//    //}
//}

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

@end
