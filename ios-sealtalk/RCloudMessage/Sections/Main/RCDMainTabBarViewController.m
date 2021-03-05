//
//  RCDMainTabBarViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMainTabBarViewController.h"
#import "RCDChatListViewController.h"
#import "RCDContactViewController.h"
#import "RCDMeTableViewController.h"
#import "RCDSquareTableViewController.h"
#import "UITabBar+badge.h"
#import "RCDUtilities.h"
@interface RCDMainTabBarViewController ()

@property NSUInteger previousIndex;

@property (nonatomic, strong) NSArray *tabTitleArr;

@property (nonatomic, strong) NSArray *imageArr;

@property (nonatomic, strong) NSArray *selectImageArr;

@property (nonatomic, strong) NSArray *animationImages;
@end

@implementation RCDMainTabBarViewController

+ (RCDMainTabBarViewController *)sharedInstance {
    static RCDMainTabBarViewController *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rcdinitTabImages];
    [self setControllers];
    [self setTabBarItems];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeSelectedIndex:)
                                                 name:@"ChangeTabBarIndex"
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self setTabBarItems];
}

- (void)setControllers {
    RCDChatListViewController *chatVC = [[RCDChatListViewController alloc] init];
    RCDContactViewController *contactVC = [[RCDContactViewController alloc] init];
    RCDSquareTableViewController *discoveryVC = [[RCDSquareTableViewController alloc] init];
    RCDMeTableViewController *meVC = [[RCDMeTableViewController alloc] init];
    self.viewControllers = @[ chatVC, contactVC, discoveryVC, meVC ];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[RCDChatListViewController class]]) {
                RCDChatListViewController *chatListVC = (RCDChatListViewController *)obj;
                [chatListVC updateBadgeValueForTabBarItem];
            }
        }];
}

- (void)setTabBarItems {
    [self.viewControllers
        enumerateObjectsUsingBlock:^(__kindof UIViewController *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

            if ([obj isKindOfClass:[RCDChatListViewController class]] || [obj isKindOfClass:[RCDContactViewController class]] || [obj isKindOfClass:[RCDSquareTableViewController class]] || [obj isKindOfClass:[RCDMeTableViewController class]]) {
                obj.tabBarItem.title = self.tabTitleArr[idx];
                obj.tabBarItem.image =
                    [[UIImage imageNamed:self.imageArr[idx]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                obj.tabBarItem.selectedImage =
                    [[UIImage imageNamed:self.selectImageArr[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                NSLog(@"Unknown TabBarController");
            }
            [obj.tabBarController.tabBar bringBadgeToFrontOnItemIndex:(int)idx];
        }];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
    NSUInteger index = tabBarController.selectedIndex;
    [RCDMainTabBarViewController sharedInstance].selectedTabBarIndex = index;
    if (self.previousIndex != index) {
        [self tabBarImageAnimation:index];
    }

    switch (index) {
    case 0: {
        if (self.previousIndex == index) {
            //判断如果有未读数存在，发出定位到未读数会话的通知
            if ([[RCIMClient sharedRCIMClient] getTotalUnreadCount] > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoNextConversation" object:nil];
            }
            self.previousIndex = index;
        }
        self.previousIndex = index;
    } break;

    case 1:
        self.previousIndex = index;
        break;

    case 2:
        self.previousIndex = index;
        break;

    case 3:
        self.previousIndex = index;
        break;

    default:
        break;
    }
}

- (void)changeSelectedIndex:(NSNotification *)notify {
    NSInteger index = [notify.object integerValue];
    self.selectedIndex = index;
}

- (void)tabBarImageAnimation:(NSUInteger)index {
    NSMutableArray *arry = [NSMutableArray array];
    for (UIControl *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            for (UIView *imageView in tabBarButton.subviews) {
                if ([imageView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                    //添加动画:放大效果
                    [arry addObject:imageView];
                }
            }
        }
    }
    
    //快速切换时会出现前一个动画还在播放的情况，所以需要先停止前一个动画
    UIImageView *preImageView = arry[self.previousIndex];
    [preImageView stopAnimating];
    preImageView.animationImages = nil;
    
    UIImageView *imgView = arry[index];
    imgView.animationImages = self.animationImages[index];
    imgView.animationDuration = 1;
    imgView.animationRepeatCount = 1;
    [imgView startAnimating];
}

- (void)rcdinitTabImages{
    self.tabTitleArr = @[RCDLocalizedString(@"Messages"), RCDLocalizedString(@"contacts"), RCDLocalizedString(@"chatroom"), RCDLocalizedString(@"me")];
    self.imageArr = @[@"chat_0",@"contact_0",@"square_0",@"me_0"];
    self.selectImageArr = @[@"chat_29",@"contact_29",@"square_29",@"me_29"];
    NSMutableArray *chatAnimationImages = @[].mutableCopy;
    NSMutableArray *contactAnimationImages = @[].mutableCopy;
    NSMutableArray *squareAnimationImages = @[].mutableCopy;
    NSMutableArray *meAnimationImages = @[].mutableCopy;
    for (int i = 0; i < 30; i++) {
        [chatAnimationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"chat_%d",i]]];
        [contactAnimationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"contact_%d",i]]];
        [squareAnimationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"square_%d",i]]];
        [meAnimationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"me_%d",i]]];
    }
    self.animationImages = @[chatAnimationImages.copy,contactAnimationImages,squareAnimationImages,meAnimationImages];
}
@end
