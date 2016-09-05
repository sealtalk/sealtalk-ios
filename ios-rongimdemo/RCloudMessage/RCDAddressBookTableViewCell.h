//
//  RCDAddressBookTableViewCell.h
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDAddressBookTableViewCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *lblName;
@property(weak, nonatomic) IBOutlet UIImageView *imgvAva;
@property(weak, nonatomic) IBOutlet UILabel *rightLabel;
@property(weak, nonatomic) IBOutlet UIImageView *arrow;
@property(strong, nonatomic) UIButton *acceptBtn;

@end
