//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "UIColor+RCColor.h"

@interface RCDAboutRongCloudTableViewController ()
@property(nonatomic, strong) NSArray *urls;
@property(nonatomic) BOOL hasNewVersion;
@property(nonatomic) NSString *versionUrl;
@property(nonatomic, strong) NSString *versionString;
@property(nonatomic, strong) NSURLConnection *connection;
@end

@implementation RCDAboutRongCloudTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.versionUrl =
        [[NSUserDefaults standardUserDefaults] stringForKey:@"newVersionUrl"];
    self.versionUrl = [[NSUserDefaults standardUserDefaults]
        stringForKey:@"newVersionString"];
    //        self.hasNewVersion = [[NSUserDefaults standardUserDefaults]
    //        boolForKey:@"hasNewVersion"];
    [self checkNewVersion];
  }
  return self;
}
#if DEBUG
#define DEMO_VERSION_BOARD @"http://bj.rongcloud.net/list.php"
#else
#define DEMO_VERSION_BOARD @"http://rongcloud.cn/demo"
#endif

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setPoweredView];
  self.tableView.tableFooterView = [UIView new];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 5) {
    if (self.hasNewVersion) {
      [[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:self.versionUrl]];
      self.hasNewVersion = NO;
      self.versionUrl = nil;
    } else {
      [self checkNewVersion];
    }
    return;
  }
  if (indexPath.section == 0 && indexPath.row < 4) {
    NSURL *url = [self getUrlAt:indexPath];
    if (url) {
      [[UIApplication sharedApplication] openURL:[self getUrlAt:indexPath]];
    }
  }
}

- (void)setHasNewVersion:(BOOL)hasNewVersion {
  _hasNewVersion = hasNewVersion;
  [[NSUserDefaults standardUserDefaults] setBool:self.hasNewVersion
                                          forKey:@"hasNewVersion"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self updateNewVersionBadge];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateNewVersionBadge];
}

- (NSArray *)urls {
  if (!_urls) {
    NSArray *section0 =
        [NSArray arrayWithObjects:@"http://rongcloud.cn/",
                                  @"http://rongcloud.cn/downloads/history/ios",
                                  @"http://rongcloud.cn/features",
                                  @"http://rongcloud.cn/", nil];
    //        NSArray *section1 = [NSArray
    //        arrayWithObjects:@"http://rongcloud.cn/", nil];
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

- (void)checkNewVersion {
  long lastCheckTime = [[NSUserDefaults standardUserDefaults]
      integerForKey:@"lastupdatetimestamp"];

  NSDate *now = [[NSDate alloc] init];
  if (now.timeIntervalSince1970 - lastCheckTime > 0) {
    if (DEMO_VERSION_BOARD.length == 0) {
      return;
    }
    NSURL *url = [NSURL URLWithString:DEMO_VERSION_BOARD];
    NSURLRequest *request =
        [[NSURLRequest alloc] initWithURL:url
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                          timeoutInterval:10];
    self.connection =
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
  }
}

- (void)updateNewVersionBadge {
#if DEBUG
  NSString *version =
      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  if (self.hasNewVersion &&
      ([self.versionString compare:version] == NSOrderedDescending)) {
#else
  if (self.hasNewVersion) {
#endif
    _VersionLabel.attributedText = [[NSAttributedString alloc]
        initWithString:@"有新版本啦。。。"
            attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}];
  } else {
    self.tabBarItem.badgeValue = nil;
    NSString *version = [[[NSBundle mainBundle] infoDictionary]
        objectForKey:@"CFBundleShortVersionString"];
    _VersionLabel.text = [NSString stringWithFormat:@"SDK 版本 %@", version];
  }
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
//  footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
//  NSDictionary *subViews = NSDictionaryOfVariableBindings(footerLabel);
//  
//  [self.view
//   addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel
//                                              attribute:NSLayoutAttributeCenterX
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:self.view
//                                              attribute:NSLayoutAttributeCenterX
//                                             multiplier:1
//                                               constant:0]];
//  [self.view
//   addConstraints:
//   [NSLayoutConstraint
//    constraintsWithVisualFormat:@"V:[footerLabel]-15-|"
//    options:0
//    metrics:nil
//    views:subViews]];
}

@end
