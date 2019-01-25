//
//  RCPTTUtilities.h
//  RongPTTKit
//
//  Created by Sin on 16/12/27.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCPTTUtilities : NSObject
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;
+ (UIImage *)imageNamedInPTTBundle:(NSString *)name;
@end
