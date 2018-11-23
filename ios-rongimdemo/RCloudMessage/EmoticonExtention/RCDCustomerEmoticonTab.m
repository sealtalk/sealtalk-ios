//
//  RCDCustomerEmoticonTab.m
//  RCloudMessage
//
//  Created by 杜立召 on 16/9/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerEmoticonTab.h"

@interface RCDCustomerEmoticonTab ()
@end

@implementation RCDCustomerEmoticonTab
- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index {
    UIView *view11 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 186)];
    view11.backgroundColor = [UIColor blackColor];
    switch (index) {
    case 1:
        view11.backgroundColor = [UIColor yellowColor];
        break;
    case 2:
        view11.backgroundColor = [UIColor redColor];
        break;
    case 3:
        view11.backgroundColor = [UIColor greenColor];
        break;
    case 4:
        view11.backgroundColor = [UIColor grayColor];
        break;

    default:
        break;
    }
    return view11;
}
@end
