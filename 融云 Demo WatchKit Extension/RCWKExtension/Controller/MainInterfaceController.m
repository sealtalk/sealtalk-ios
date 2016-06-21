//
//  MainInterfaceController.m
//  RongWKLib
//
//  Created by litao on 15/4/7.
//
//

#import "MainInterfaceController.h"
#import "RCAppQueryHelper.h"
#import "RCAppSharedUserDefault.h"
#import "RCAppInfoModel.h"
#import "RCWKNotificationCenter.h"

@interface MainInterfaceController() <RCWKNotificationObserver>
@property (weak, nonatomic) IBOutlet WKInterfaceImage *appIcon;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *newmsgcount;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *conversation;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *discussion;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *settings;
@property (nonatomic)BOOL needLoadAtWillActivity;
@end



@implementation MainInterfaceController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        // Retrieve the data. This could be accessed from the iOS app via a shared container.
        [RCAppQueryHelper requestParentAppOpen];
        [RCAppQueryHelper queryParentAppGroups:^(NSString *appGroups) {
            [RCAppInfoModel sharedModel].appGroups = appGroups;
        }];
        
        [RCAppQueryHelper queryParentAppName:^(NSString *appName) {
            [RCAppInfoModel sharedModel].appName = appName;
            [self setTitle:appName];
        }];
        
        if (![RCAppInfoModel sharedModel].contacts) {
            [self loadContactFromApp];
        }
        [self loadDataFromApp];
        
        self.needLoadAtWillActivity = NO;
    }
    
    return self;
}

- (void)loadDataFromApp
{
    NSLog(@"loadDataFromApp");
//    [RCAppQueryHelper queryParentAppConnectionStatus:^(BOOL isConnected) {
//        if (isConnected) {
            [RCAppQueryHelper queryParentAppUnreadMessageCount:^(int count) {
                [self.newmsgcount setText:[NSString  stringWithFormat:@"%d条未读消息", count]];
            }];
//        } else {
//            [self.newmsgcount setText:@"客户端未登录"];
//        }
//    }];
}
- (void)loadContactFromApp
{
    [RCAppQueryHelper queryParentAppGroupInfos:^(NSArray *groups) {
        [RCAppInfoModel sharedModel].groups = groups;
    }];
    [RCAppQueryHelper queryParentAppContacts:^(NSArray *contacts) {
        NSLog(@"contact loaded");
        [RCAppInfoModel sharedModel].contacts = contacts;
    }];
    [RCAppQueryHelper requestParentAppCacheAllHeadIcon];
}
- (void)loadGroupFromApp
{
    [RCAppQueryHelper queryParentAppGroupInfos:^(NSArray *contacts) {
        NSLog(@"contact loaded");
        [RCAppInfoModel sharedModel].groups = contacts;
    }];
}
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [[RCWKNotificationCenter defaultCenter] addConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] addMessageChangeObserver:self];
    [[RCWKNotificationCenter defaultCenter] addGroupInfoChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:YES];
    if (self.needLoadAtWillActivity) {
        [self loadDataFromApp];
    }

}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [[RCWKNotificationCenter defaultCenter] removeConnectionStatusObserver:self];
    [[RCWKNotificationCenter defaultCenter] removeMessageChangeObserver:self];
    [[RCWKNotificationCenter defaultCenter] removeGroupInfoChangeObserver:self];
    [RCAppQueryHelper requestParentAppNotification:NO];
    self.needLoadAtWillActivity = YES;
}
- (void)onMessageChangedEvent
{
    [self loadDataFromApp];
}
- (void)onUserInfoChangedEvent
{
    [self loadContactFromApp];
}
- (void)onConnectionStatusChangedEvent
{
    [self loadDataFromApp];
}
- (void)onGroupInfoChangedEvent
{
    [self loadGroupFromApp];
}
- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification
{
    
}
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification
{
    
}
@end






