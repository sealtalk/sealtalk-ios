//
//  RCDUploadManager.h
//  SealTalk
//
//  Created by LiFei on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDUploadManager : NSObject

+ (void)uploadImage:(NSData *)image complete:(void (^)(NSString *url))completeBlock;

@end
