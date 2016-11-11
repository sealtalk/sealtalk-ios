//
//  RCDCustomerEmoticonTab.m
//  RCloudMessage
//
//  Created by 杜立召 on 16/9/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerEmoticonTab.h"
#import "RCDChatViewController.h"

@interface RCDCustomerEmoticonTab()
@end

@implementation RCDCustomerEmoticonTab
- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index {
    return [self.chartView loadEmoticonView:identify index:index];
}
@end
