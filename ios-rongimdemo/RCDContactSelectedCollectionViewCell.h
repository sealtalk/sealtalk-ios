//
//  RCDContactSelectedCollectionViewCell.h
//  RCloudMessage
//
//  Created by Jue on 2016/10/20.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDUserInfo.h"
#import <UIKit/UIKit.h>

@interface RCDContactSelectedCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *ivAva;

- (void)setUserModel:(RCUserInfo *)userModel;

@end
