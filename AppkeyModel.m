//
//  AppkeyModel.m
//  RCloudMessage
//
//  Created by litao on 15/5/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

//本文件为了切换appkey测试用的，请应用开发者忽略关于本文件的信息。
#import "AppkeyModel.h"

@implementation AppkeyModel
- (instancetype)initWithKey:(NSString *)appKey env:(int)env
{
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.env = env;
    }
    return self;
}
@end
