//
//  RCDSearchDataManager.h
//  RCloudMessage
//
//  Created by 张改红 on 16/9/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, RCDSearchType) {
    RCDSearchFriend = 0,
    RCDSearchGroup,
    RCDSearchChatHistory,
    RCDSearchAll,
};

@interface RCDSearchDataManager : NSObject
+ (instancetype)shareInstance;

- (void)searchDataWithSearchText:(NSString *)searchText
                    bySearchType:(NSInteger)searchType
                        complete:(void (^)(NSDictionary *dic, NSArray *array))result;

@end
