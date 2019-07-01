//
//  RongRTCActivityMonitorDelegate.h
//  RongRTCLib
//
//  Created by birney on 2019/6/12.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RongRTCStatisticalForm;

@protocol RongRTCActivityMonitorDelegate <NSObject>

@optional

/**
 汇报sdk 统计数据

 @param form 统计表单对象
 */
- (void)didReportStatForm:(RongRTCStatisticalForm*)form;

@end

NS_ASSUME_NONNULL_END
