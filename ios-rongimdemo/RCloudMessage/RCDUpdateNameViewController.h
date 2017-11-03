//
//  RCDUpdateNameViewController.h
//  RCloudMessage
//  更改讨论组名称
//  Created by Liv on 15/4/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^setDisplayText)(NSString *text);

@interface RCDUpdateNameViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

/**
 *  初始化方法
 *
 *  @return RCDUpdateNameViewController对象
 */
+ (instancetype)updateNameViewController;

/**
 *  更改讨论组名称的textField
 */
@property(nonatomic, strong) UITextField *nameTextField;

/**
 *  讨论组id
 */
@property(nonatomic, copy) NSString *targetId;

/**
 *  讨论组名称
 */
@property(nonatomic, copy) NSString *displayText;

/**
 *  保存讨论组名称block
 */
@property(nonatomic, copy) setDisplayText setDisplayTextCompletion;

@end
