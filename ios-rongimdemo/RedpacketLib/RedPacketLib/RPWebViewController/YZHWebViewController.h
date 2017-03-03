//
//  YZHWebViewController.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "HTWebViewController.h"

@interface YZHWebViewController : HTWebViewController

@property (nonatomic, copy) void(^redpacketSendLuckMoneySuccess)(NSDictionary * dict);

@end
