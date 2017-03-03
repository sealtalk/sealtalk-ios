//
//  ValidateUserIDController.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/6/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"

@interface ValidateUserIDController : YZHRefreshTableViewController

@property (nonatomic, copy) NSString *validateMsg;
@property (nonatomic, assign)   BOOL isValidateFalid;

@property (nonatomic, copy) void(^finishBlock)(void);

@end
