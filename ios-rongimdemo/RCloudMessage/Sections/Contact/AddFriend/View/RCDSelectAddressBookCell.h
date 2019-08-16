//
//  RCDSelectAddressBookCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDContactsInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCDSelectedStatus) {
    RCDSelectedStatusUnSelected,
    RCDSelectedStatusSelected,
};

@interface RCDSelectAddressBookCell : UITableViewCell

@property (nonatomic, assign) RCDSelectedStatus selectStatus;

- (void)setModel:(RCDContactsInfo *)model;

@end

NS_ASSUME_NONNULL_END
