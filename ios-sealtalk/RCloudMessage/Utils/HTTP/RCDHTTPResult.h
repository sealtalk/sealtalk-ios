//
//  RCDHTTPResult.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDHTTPResult : NSObject

@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger httpCode;
@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) id content;

@end

NS_ASSUME_NONNULL_END
