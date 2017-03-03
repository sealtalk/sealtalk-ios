//
//  ServerSelectionViewController.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHRefreshTableViewController.h"

@interface RPServerSelectionViewController : YZHRefreshTableViewController

@property (nonatomic, copy) void(^selectChanged)(void);

@end
