//
//  RedpacketErrorLog.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/5/10.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RedpacketErrorLoger : NSObject

+ (RedpacketErrorLoger *)sharedLoger;

- (void)addNetworError:(NSString *)url andErrorMsg:(NSString *)msg;

- (void)addWebviewError:(NSString *)url andErrorMsg:(NSString *)msg;

- (void)update;

@end
