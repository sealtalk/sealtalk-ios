//
//  SortForTime.h
//  RCloudMessage
//
//  Created by Jue on 16/7/15.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SortForTime : NSObject
- (NSMutableArray *)sortForUpdateAt:(NSMutableArray *)updatedAtList order:(NSComparisonResult)order;

@end
