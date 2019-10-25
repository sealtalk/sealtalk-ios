//
//  RCDGroupConversationCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
static NSString *_Nullable RCDGroupConversationCellIdentifier = @"RCDGroupConversationCellIdentifier";

NS_ASSUME_NONNULL_BEGIN

@interface RCDGroupConversationCell : RCConversationCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
