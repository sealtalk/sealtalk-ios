//
//  RCDContactSelectedTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/3/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDContactSelectedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
