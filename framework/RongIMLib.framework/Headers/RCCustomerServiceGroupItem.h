//
//  RCCustomerGroupItem.h
//  RongIMLib
//
//  Created by 张改红 on 16/7/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCCustomerServiceGroupItem : UITableViewCell
@property (nonatomic, strong)NSString *groupId;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, assign)BOOL online;
@end
