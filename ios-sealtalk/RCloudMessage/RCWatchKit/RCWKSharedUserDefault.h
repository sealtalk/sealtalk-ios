//
//  RCWKSharedUserDefault.h
//  RongIMDemo
//
//  Created by litao on 15/3/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCWKSharedUserDefault : NSObject
+ (void)setSharedDefaultObject:(id)object forKey:(NSString *)key;
@end
