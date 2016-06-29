//
//  RCDMeTableViewController.m
//  RCloudMessage
//
//  Created by Liv on 14/11/28.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCDMeTableViewController.h"
#import "UIColor+RCColor.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDChatViewController.h"
#import "RCDRCIMDataSource.h"
#import "RCDCommonDefine.h"
#import "DefaultPortraitView.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "RCDCustomerServiceViewController.h"
#import "AFHttpTool.h"
#import "RCDataBaseManager.h"
#import "RCDUtilities.h"

@interface RCDMeTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentUserNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserPortrait;
@property (nonatomic)BOOL hasNewVersion;
@property (nonatomic)NSString *versionUrl;
@property (nonatomic, strong)NSString *versionString;

@property (nonatomic, strong)NSURLConnection *connection;
@property (nonatomic, strong)NSMutableData *receiveData;

@end

@implementation RCDMeTableViewController
{
    UIImage *userPortrait;
    BOOL isSyncCurrentUserInfo;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //设置为不用默认渲染方式
        self.tabBarItem.image = [[UIImage imageNamed:@"icon_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_me_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.versionUrl= [[NSUserDefaults standardUserDefaults] stringForKey:@"newVersionUrl"];
        self.versionUrl= [[NSUserDefaults standardUserDefaults] stringForKey:@"newVersionString"];
//        self.hasNewVersion = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasNewVersion"];
        [self checkNewVersion];
    }
    return self;
}
#if DEBUG
#define DEMO_VERSION_BOARD @"http://bj.rongcloud.net/list.php"
#else
#define DEMO_VERSION_BOARD @"http://rongcloud.cn/demo"
#endif

- (void)checkNewVersion {
    long lastCheckTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastupdatetimestamp"];
    
    NSDate *now = [[NSDate alloc] init];
    if (now.timeIntervalSince1970 - lastCheckTime > 0) {
        if (DEMO_VERSION_BOARD.length == 0) {
            return;
        }
        NSURL *url = [NSURL URLWithString:DEMO_VERSION_BOARD];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView=[UIView new];
    //设置分割线颜色
    self.tableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
//    self.currentUserNameLabel.text = [DEFAULTS objectForKey:@"userName"];;
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.currentUserPortrait.layer.masksToBounds =YES;
    self.currentUserPortrait.layer.cornerRadius = 6.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUserPortrait:)
                                                 name:@"setCurrentUserPortrait"
                                               object:nil];
    
    isSyncCurrentUserInfo = NO;
    self.currentUserNameLabel.text = [DEFAULTS stringForKey:@"userNickName"];
    [self.currentUserPortrait sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"我";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    [self updateNewVersionBadge];
    [self syncCurrentUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self chatWithCustomerService];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        if (self.hasNewVersion) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.versionUrl]];
            self.hasNewVersion = NO;
            self.versionUrl = nil;
        } else {
            [self checkNewVersion];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15.f;
    }
    return 5.f;
}

-(void)setUserPortrait:(NSNotification *)notifycation
{
    userPortrait = [notifycation object];
}

- (void)setHasNewVersion:(BOOL)hasNewVersion
{
    _hasNewVersion = hasNewVersion;
    [[NSUserDefaults standardUserDefaults] setBool:self.hasNewVersion forKey:@"hasNewVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateNewVersionBadge];
}

- (void)setVersionUrl:(NSString *)versionUrl
{
    _versionUrl = versionUrl;
    [[NSUserDefaults standardUserDefaults] setObject:self.versionUrl forKey:@"newVersionUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setvrsionString:(NSString *)newVersionString {
    _versionString = newVersionString;
    [[NSUserDefaults standardUserDefaults] setObject:self.versionUrl forKey:@"newVersionString"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSLog(@"%@",[res allHeaderFields]);
    self.receiveData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receiveData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDate *now = [[NSDate alloc] init];
    [[NSUserDefaults standardUserDefaults] setInteger:now.timeIntervalSince1970 forKey:@"lastupdatetimestamp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *receiveStr = [[NSString alloc]initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    
    [self compareVersion:receiveStr];
}

- (void)chatWithCustomerService
{
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
#define SERVICE_ID @"KEFU146001495753714"
    // live800  KEFU146227005669524   live800的客服ID
    // zhichi   KEFU146001495753714   智齿的客服ID
    chatService.userName = @"客服";
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    
    chatService.targetId = SERVICE_ID;
    
    //上传用户信息，nickname是必须要填写的
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = @"昵称";
    csInfo.loginName = @"登录名称";
    csInfo.name = @"用户名称";
    csInfo.grade = @"11级";
    csInfo.gender = @"男";
    csInfo.birthday = @"2016.5.1";
    csInfo.age = @"36";
    csInfo.profession = @"software engineer";
    csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
    csInfo.province = @"beijing";
    csInfo.city = @"beijing";
    csInfo.memo = @"这是一个好顾客!";
    
    csInfo.mobileNo = @"13800000000";
    csInfo.email = @"test@example.com";
    csInfo.address = @"北京市北苑路北泰岳大厦";
    csInfo.QQ = @"88888888";
    csInfo.weibo = @"my weibo account";
    csInfo.weixin = @"myweixin";
    
    csInfo.page = @"卖化妆品的页面来的";
    csInfo.referrer = @"客户端";
    csInfo.enterUrl = @"testurl";
    csInfo.skillId = @"技能组";
    csInfo.listUrl = @[@"用户浏览的第一个商品Url", @"用户浏览的第二个商品Url"];
    csInfo.define = @"自定义信息";
    
    chatService.csInfo = csInfo;
    chatService.title = chatService.userName;
    
    [self.navigationController pushViewController :chatService animated:YES];
}

#if DEBUG
-(void)compareVersion:(NSString *)receiveStr {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    NSLog(@"%@",receiveStr);
    NSRange strRange = NSMakeRange(0, receiveStr.length);
 
        NSRange startRange = [receiveStr rangeOfString:@"<a href='itms-services:" options:0 range:strRange];
        if (startRange.location != NSNotFound) {
            NSRange endRange = [receiveStr rangeOfString:@"'>" options:0 range:NSMakeRange(startRange.location + startRange.length, receiveStr.length - startRange.location - startRange.length)];
            NSString *url = [receiveStr substringWithRange:NSMakeRange(startRange.location + 9, endRange.location - startRange.location - 9)];
            NSRange nameEndRange = [receiveStr rangeOfString:@"</a>" options:0 range:NSMakeRange(endRange.location, receiveStr.length - endRange.location)];
            NSString *name = [receiveStr substringWithRange:NSMakeRange(endRange.location+2, nameEndRange.location - endRange.location - 2)];
            NSRange versionBegin = [name rangeOfString:@"_201"];
            if (versionBegin.location == NSNotFound) {
                self.hasNewVersion = NO;
                self.versionUrl = nil;
                return;
            }
            NSString *versionString = [name substringWithRange:NSMakeRange(versionBegin.location+1, 12)];

            if ([versionString compare:version] == NSOrderedDescending) {
                self.versionUrl = url;
                self.versionString = versionString;
                self.hasNewVersion = YES;
            } else {
                self.versionUrl = nil;
                self.versionString = nil;
                self.hasNewVersion = NO;
            }
        } else {
            self.versionUrl = nil;
            self.versionString = nil;
            self.hasNewVersion = NO;
        }
}

#else

-(void)compareVersion:(NSString *)receiveStr {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSCharacterSet *setToRemove =
    [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789."]
     invertedSet ];
    
    NSString *versionNum =
    [[version componentsSeparatedByCharactersInSet:setToRemove]
     componentsJoinedByString:@""];
    NSLog(@"%@",receiveStr);
    NSRange strRange = NSMakeRange(0, receiveStr.length);
    while (true) {
        NSRange startRange = [receiveStr rangeOfString:@"itms-services:" options:0 range:strRange];
        if (startRange.location != NSNotFound) {
            NSRange endRange = [receiveStr rangeOfString:@"')\"" options:0 range:NSMakeRange(startRange.location + startRange.length, receiveStr.length - startRange.location - startRange.length)];
            NSString *url = [receiveStr substringWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location)];
            
            NSRange nameStartRange = [receiveStr rangeOfString:@">" options:0 range:NSMakeRange(endRange.location, receiveStr.length - endRange.location)];
            
            NSRange nameEndRange = [receiveStr rangeOfString:@"</a>" options:0 range:NSMakeRange(endRange.location, receiveStr.length - endRange.location)];
            NSString *name = [receiveStr substringWithRange:NSMakeRange(nameStartRange.location+1, nameEndRange.location - nameStartRange.location - 1)];
            
            NSString *model = @"稳定";
            
            NSRange range = [name rangeOfString:model];
            if (range.location != NSNotFound) {
                range = [name rangeOfString:versionNum];
                if (range.location == NSNotFound) {
                    self.hasNewVersion = YES;
                    self.versionUrl = url;
                    break;
                } else {
                    self.hasNewVersion = NO;
                    self.versionUrl = nil;
                    break;
                }
            }
            strRange.location = nameEndRange.location + nameEndRange.length;
            strRange.length = receiveStr.length - strRange.location;
        } else {
            self.hasNewVersion = NO;
            self.versionUrl = nil;
            break;
        }
    }
}
#endif

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.hasNewVersion = NO;
    self.versionUrl = nil;
}

- (void)updateNewVersionBadge {
#if DEBUG
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if (self.hasNewVersion && ([self.versionString compare:version] == NSOrderedDescending)) {
#else
    if (self.hasNewVersion) {
#endif
        self.tabBarItem.badgeValue = @"有新版本！";
        _versionLb.attributedText = [[NSAttributedString alloc] initWithString:@"有新版本啦。。。" attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    } else {
        self.tabBarItem.badgeValue = nil;
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _versionLb.text=[NSString stringWithFormat:@"当前版本 %@",version];
    }
}
    
-(void) syncCurrentUserInfo
{
    [AFHttpTool getUserInfo:[RCIM sharedRCIM].currentUserInfo.userId
                    success:^(id response) {
                        if ([response[@"code"] intValue] == 200) {
                            NSDictionary *result    = response[@"result"];
                            NSString *userId        = result[@"id"];
                            NSString *nickname      = result[@"nickname"];
                            NSString *portraitUri   = result[@"portraitUri"];
                            RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:userId name:nickname portrait:portraitUri];
                            if (!user.portraitUri || user.portraitUri.length <= 0) {
                                user.portraitUri = [RCDUtilities defaultUserPortrait:user];
                            }
                            [[RCDataBaseManager shareInstance] insertUserToDB:user];
                            [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:userId];
                            [RCIM sharedRCIM].currentUserInfo = user;
                            [DEFAULTS setObject:user.portraitUri forKey:@"userPortraitUri"];
                            [DEFAULTS setObject:user.name forKey:@"userNickName"];
                            [DEFAULTS synchronize];
                            isSyncCurrentUserInfo = YES;
                            [self setNicknameAndPortrait];
                        }
                    } failure:^(NSError *err) {
                        isSyncCurrentUserInfo = YES;
                        [self setNicknameAndPortrait];
                    }];

}
    
-(void) setNicknameAndPortrait
{
    NSString *portraitUrl = [DEFAULTS stringForKey:@"userPortraitUri"];
    if ([portraitUrl isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:[RCIM sharedRCIM].currentUserInfo.userId Nickname:[DEFAULTS stringForKey:@"userNickName"]];
        UIImage *portrait = [defaultPortrait imageFromView];
        self.currentUserPortrait.image = portrait;
        NSData *data = UIImagePNGRepresentation(portrait);
        [RCDHTTPTOOL uploadImageToQiNiu:[RCIM sharedRCIM].currentUserInfo.userId
                              ImageData:data
                                success:^(NSString *url) {
                                    [DEFAULTS setObject:url forKey:@"userPortraitUri"];
                                    [DEFAULTS synchronize];
                                    RCUserInfo *user = [RCUserInfo new];
                                    user.userId = [RCIM sharedRCIM].currentUserInfo.userId;
                                    user.portraitUri = url;
                                    user.name =[DEFAULTS stringForKey:@"userNickName"];
                                    [[RCIM sharedRCIM] refreshUserInfoCache:user
                                                                 withUserId:user.userId];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.currentUserPortrait sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:portrait];
                                    });
                                } failure:^(NSError *err) {
                                    
                                }];
    }
    else
    {
        [self.currentUserPortrait sd_setImageWithURL:[NSURL URLWithString:[DEFAULTS stringForKey:@"userPortraitUri"]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.currentUserPortrait.layer.masksToBounds = YES;
        self.currentUserPortrait.layer.cornerRadius = 30.f;
    }
    self.currentUserNameLabel.text = [DEFAULTS stringForKey:@"userNickName"];

}
@end
