//
//  RCDDataStatistics.h
//  SealTalk
//
//  Created by Sin on 2019/10/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDDataStatistics : NSObject
+ (instancetype)sharedInstance;
- (void)notify;
@end

NS_ASSUME_NONNULL_END
