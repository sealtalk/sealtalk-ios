//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"
#import "UIColor+RCColor.h"
#import "RCDCheckVersion.h"

@interface RCDAboutRongCloudTableViewController ()
@property(nonatomic, strong) NSArray *urls;
@end

@implementation RCDAboutRongCloudTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
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


@end
