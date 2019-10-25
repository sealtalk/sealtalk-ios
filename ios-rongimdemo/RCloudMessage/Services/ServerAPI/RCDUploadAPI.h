//
//  RCDUploadAPI.h
//  SealTalk
//
//  Created by LiFei on 2019/6/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDUploadAPI : NSObject

+ (void)uploadImage:(NSData *)image byUser:(NSString *)userId complete:(void (^)(NSString *url))completeBlock;

@end
