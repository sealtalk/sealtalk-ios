//
//  RCDCheckVersion.h
//  RCloudMessage
//
//  Created by Jue on 16/7/7.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDCheckVersion : NSObject

+ (RCDCheckVersion *)shareInstance;

-(void)startCheckSuccess:(void (^)(NSDictionary *result))success;
@end
