//
//  RCDGroupAnnouncement.h
//  SealTalk
//
//  Created by 张改红 on 2019/6/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupAnnouncement : NSObject
@property (nonatomic, copy) NSString *publishId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) long long publishTime;
- (instancetype)initWithJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
