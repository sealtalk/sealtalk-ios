//
//  RCDAboutRongCloudTableViewController.m
//  RCloudMessage
//
//  Created by litao on 15/4/27.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDAboutRongCloudTableViewController.h"

@interface RCDAboutRongCloudTableViewController ()
@property(nonatomic, strong) NSArray *urls;
@end

@implementation RCDAboutRongCloudTableViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select row %ld", indexPath.row);
    [[UIApplication sharedApplication] openURL:[self getUrlAt:indexPath]];
}

- (NSArray *)urls {
    if (!_urls) {
        NSArray *section0 =
            [NSArray arrayWithObjects:@"http://rongcloud.cn/downloads/history/ios", @"http://rongcloud.cn/features",
                                      @"http://docs.rongcloud.cn/api/ios/imkit/index.html", nil];
        NSArray *section1 = [NSArray arrayWithObjects:@"http://rongcloud.cn/", @"http://rongcloud.cn/", nil];
        _urls = [NSArray arrayWithObjects:section0, section1, nil];
    }
    return _urls;
}

- (NSURL *)getUrlAt:(NSIndexPath *)indexPath {
    NSArray *section = self.urls[indexPath.section];
    NSString *urlString = section[indexPath.row];
    return [NSURL URLWithString:urlString];
}
@end
