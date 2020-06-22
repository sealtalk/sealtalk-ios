//
//  RCDPictureView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCDPictureViewDelegate <NSObject>

- (void)pictureViewDidTap;

@end

@interface RCDPictureView : UIView

@property (nonatomic, weak) id<RCDPictureViewDelegate> delegate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *promptTitle;

@property (nonatomic, strong) UIImageView *imageView;

- (void)addBorder;

@end

NS_ASSUME_NONNULL_END
