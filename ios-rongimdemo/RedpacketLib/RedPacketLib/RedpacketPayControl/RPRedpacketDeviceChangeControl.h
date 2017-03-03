//
//  RedpacketDeviceChangeControl.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/10/14.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RPTelphoneValidateView.h"

typedef void (^DeviceChangeBlock)(BOOL isSuccess);

@interface RPRedpacketDeviceChangeControl : NSObject
@property (nonatomic, strong, readonly)   RPTelphoneValidateView *validateView;

+ (RPRedpacketDeviceChangeControl *)showValidateTelViewOnController:(UIViewController *)controller
                                                 andValidateBlock:(DeviceChangeBlock)changeBlock;

@end
