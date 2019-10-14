//
//  RCDFriendDescription.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDFriendDescription : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *displayName;
//@property (nonatomic, copy) NSString *remark;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imageUrl;

- (instancetype)initWithJson:(NSDictionary *)json;

@end

NS_ASSUME_NONNULL_END
