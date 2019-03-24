//
//  RCDMeCell.h
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDBaseSettingTableViewCell.h"

@interface RCDMeCell : RCDBaseSettingTableViewCell

- (id)initWithImageName:(NSString *)imageName labelName:(NSString *)labelName;

- (void)setCellWithImageName:(NSString *)imageName labelName:(NSString *)labelName rightLabelName:(NSString *)rightLabelName;

- (void)addRedpointImageView;
@end
