//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "UIColor+RCColor.h"
#import "RCDMeButton.h"
#import "RCDCommonDefine.h"

@interface RCDAboutRongCloudTableViewController ()
@property(nonatomic, strong) NSArray *urls;

//force crash for test
@property (nonatomic, strong)NSDate *firstClickDate;
@property (nonatomic, assign)NSUInteger clickTimes;
@end

@implementation RCDAboutRongCloudTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.firstClickDate = nil;
    self.clickTimes = 0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setPoweredView];
  self.tableView.tableFooterView = [UIView new];
  
  NSString *version = [[[NSBundle mainBundle] infoDictionary]
                       objectForKey:@"CFBundleShortVersionString"];
  _SDKVersionLabel.text = [NSString stringWithFormat:@"SDK 版本 %@", version];
  
  NSString *SealTalkVersion = [[[NSBundle mainBundle] infoDictionary]
                       objectForKey:@"SealTalk Version"];
  self.SealTalkVersionLabel.text = [NSString stringWithFormat:@"SealTalk 版本 %@",SealTalkVersion];
  
  NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
  if ([isNeedUpdate isEqualToString:@"YES"]) {
    _NewVersionImage.hidden = NO;
  }
    //设置分割线颜色
    self.tableView.separatorColor =
    [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
  
  RCDMeButton *backBtn = [[RCDMeButton alloc] init];
  [backBtn addTarget:self action:@selector(cilckBackBtn:) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
  [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *isNeedUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"isNeedUpdate"];
  if (indexPath.section == 0 && indexPath.row == 4) {
    if ([isNeedUpdate isEqualToString:@"YES"]) {
      NSString *finalURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"applistURL"];
      NSURL *applistURL = [NSURL URLWithString:finalURL];
      [[UIApplication sharedApplication] openURL:applistURL];
    }
  }
  if (indexPath.section == 0 && indexPath.row < 4) {
    NSURL *url = [self getUrlAt:indexPath];
    if (url) {
      [[UIApplication sharedApplication] openURL:url];
    }

  }

  //force crash for test
  if (indexPath.section == 0 && indexPath.row == 5) {
    if (self.clickTimes == 0) {
      self.firstClickDate = [[NSDate alloc] init];
      self.clickTimes = 1;
    } else if ([self.firstClickDate timeIntervalSinceNow] > -3){
      self.clickTimes++;
      if (self.clickTimes >= 5) {
        [self gotoDebugModel];
      }
    } else {
      self.clickTimes = 0;
      self.firstClickDate = nil;
    }
  }
}

-(void)gotoDebugModel
{
    NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
  if ([isDisplayID isEqualToString:@"YES"]) {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:@"Debug模式"
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:@"强制Crash",@"关闭显示ID", nil];
    alert.delegate = self;
    [alert show];
    
  } else {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:@"Debug模式"
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:@"强制Crash",@"显示ID", nil];
    alert.delegate = self;
    [alert show];
  }
}

//force crash for test
- (void)forceCrash {
  int x = 0;
  x = x/x;
}

-(void) setIsDisplayId
{
  NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];
  if ([isDisplayID isEqualToString:@"YES"]) {
    [DEFAULTS setObject:nil forKey:@"isDisplayID"];
    [DEFAULTS synchronize];
  } else {
    [DEFAULTS setObject:@"YES" forKey:@"isDisplayID"];
    [DEFAULTS synchronize];

  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  switch (buttonIndex) {
    case 1:
      [self forceCrash];
      break;
      
    case 2:
      [self setIsDisplayId];
      break;
      
    default:
      break;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

}

- (void)setPoweredView
{
  CGRect screenBounds = self.view.frame;
  UILabel *footerLabel = [[UILabel alloc] init];
  footerLabel.textAlignment = NSTextAlignmentCenter;
  footerLabel.frame = CGRectMake(screenBounds.size.width / 2 - 100, screenBounds.size.height - 30 - 21 - self.navigationController.navigationBar.frame.size.height, 200, 21);
  footerLabel.text = @"Powered by RongCloud";
  [footerLabel setFont:[UIFont systemFontOfSize:12.f]];
  [footerLabel setTextColor:[UIColor colorWithHexString:@"999999" alpha:1.0]];
  [self.view addSubview:footerLabel];
}

- (NSArray *)urls {
  if (!_urls) {
    NSArray *section0 =
    [NSArray arrayWithObjects:@"http://rongcloud.cn/",
     @"http://www.rongcloud.cn/changelog",
     @"http://rongcloud.cn/features",
     @"http://rongcloud.cn/", nil];
    _urls = [NSArray arrayWithObjects:section0, nil];
  }
  return _urls;
}

- (NSURL *)getUrlAt:(NSIndexPath *)indexPath {
  NSArray *section = self.urls[indexPath.section];
  NSString *urlString = section[indexPath.row];
  if (!urlString.length) {
    return nil;
  }
  return [NSURL URLWithString:urlString];
}

-(void)cilckBackBtn:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}
@end
