//
//  RCDReceiptDetailsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDReceiptDetailsTableViewController : UITableViewController

@property(nonatomic, strong) NSString *targetId;

@property(nonatomic, strong) NSString *messageContent;

@property(nonatomic, strong) NSString *messageSendTime;

@property(nonatomic, strong) NSArray *hasReadUserList;
@end
