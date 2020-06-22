//
//  RCDHTTPUtility.h
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCDHTTPResult.h"

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGet = 1,
    HTTPMethodHead = 2,
    HTTPMethodPost = 3,
    HTTPMethodPut = 4,
    HTTPMethodDelete = 5
};

@interface RCDHTTPUtility : NSObject

+ (void)requestWithHTTPMethod:(HTTPMethod)method
                    URLString:(NSString *)URLString
                   parameters:(NSDictionary *)parameters
                     response:(void (^)(RCDHTTPResult *result))responseBlock;

@end
