//
//  RCDRecentPictureViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^SendBlock)(BOOL isFull);

@interface RCDRecentPictureViewController : RCDViewController

@property (nonatomic, copy) SendBlock sendBlock;

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
