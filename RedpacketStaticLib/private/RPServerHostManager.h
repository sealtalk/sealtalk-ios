//
//  ServerHostManager.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/8/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPServerHostManager : NSObject

+ (NSArray *)serverHosts;

+ (NSString *)selectedServerHost;

+ (void)selectServerHostAtIndex:(NSInteger)index;

@end
