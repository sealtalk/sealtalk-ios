//
//  RCDGroupSettingsTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDGroupSettingsTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property(weak, nonatomic) IBOutlet UILabel *ContentLabel;
@property(weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property(weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property(weak, nonatomic) IBOutlet UIImageView *PortraitImg;

@end
