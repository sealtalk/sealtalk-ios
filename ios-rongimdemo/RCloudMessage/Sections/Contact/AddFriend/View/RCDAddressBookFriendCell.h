//
//  RCDAddressBookFriendCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import "RCDContactsInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDAddressBookFriendCell : RCDTableViewCell

@property (nonatomic, copy) void (^addBlock)(NSString *userId);

- (void)setModel:(RCDContactsInfo *)model;

@end

NS_ASSUME_NONNULL_END
