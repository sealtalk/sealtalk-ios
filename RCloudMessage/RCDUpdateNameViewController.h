//
//  RCDUpdateNameViewController.h
//  RCloudMessage
//  更改讨论组名称
//  Created by Liv on 15/4/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^setDisplayText)(NSString *text);

@interface RCDUpdateNameViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *tfName;

@property (nonatomic,copy) NSString *targetId;

@property (nonatomic,copy) NSString *displayText;

@property (nonatomic,copy) setDisplayText setDisplayTextCompletion;

@end
