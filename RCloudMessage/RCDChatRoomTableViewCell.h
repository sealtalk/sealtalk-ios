//
//  RCDChatRoomTableViewCell.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/26.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDChatRoomTableViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *lbChatroom;
@property(weak, nonatomic) IBOutlet UIImageView *ivChatRoomPortrait;
@property(weak, nonatomic) IBOutlet UILabel *lbNumber;
@property(weak, nonatomic) IBOutlet UILabel *lbDescription;

@end
