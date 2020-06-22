//
//  RCDReceiptDetailsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDTableViewController.h"
@class RCMessageModel;
@interface RCDReceiptDetailsTableViewController : RCDTableViewController
@property (nonatomic, strong) RCMessageModel *message;
@end
