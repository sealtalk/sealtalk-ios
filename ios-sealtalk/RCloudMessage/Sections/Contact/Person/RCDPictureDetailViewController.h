//
//  RCDPictureDetailViewController.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DeleteImageBlock)();

@interface RCDPictureDetailViewController : RCDViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) DeleteImageBlock deleteImageBlock;

@end

NS_ASSUME_NONNULL_END
