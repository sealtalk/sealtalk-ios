//
//  RCDSquareTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/4/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDSquareTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *GroupPortrait;

@property (weak, nonatomic) IBOutlet UILabel *GroupName;

@property (weak, nonatomic) IBOutlet UILabel *GroupNumber;

@property (weak, nonatomic) IBOutlet UIButton *JoinGroupBtn;

@property (weak, nonatomic) IBOutlet UIButton *ChatBtn;
@end
