//
//  BlinkQuicHttp.h
//  Blink
//
//  Created by HaibingTang on 2018/2/28.
//  Copyright © 2018年 Bridge Mind. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Bailingquic/Bailingquic.h>

typedef void (^HttpResponseHandler)(NSData*, NSError*);

@interface BlinkQuicHttp : NSObject

- (id)init;
- (NSError*)getRequestWithUrl:(NSString*)url Callback:(HttpResponseHandler)handler;
- (NSError*) disconnect;

@end
