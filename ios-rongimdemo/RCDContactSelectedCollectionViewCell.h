//
//  RCDContactSelectedCollectionViewCell.h
//  RCloudMessage
//
//  Created by Jue on 2016/10/20.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDUserInfo.h"

@interface RCDContactSelectedCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *ivAva;

- (void)setUserModel:(RCUserInfo *)userModel;

@end
