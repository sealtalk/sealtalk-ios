//
//  RCDReceiptDetailsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/9/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCMessageModel;
@interface RCDReceiptDetailsTableViewController : UITableViewController
@property (nonatomic, strong) RCMessageModel *message;
@end
