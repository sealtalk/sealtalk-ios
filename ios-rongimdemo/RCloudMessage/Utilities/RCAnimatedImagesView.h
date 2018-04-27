//
//  RCAnimatedImagesView.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/18.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJSAnimatedImagesViewDefaultTimePerImage 20.0f

@protocol RCAnimatedImagesViewDelegate;

@interface RCAnimatedImagesView : UIView

@property(nonatomic, weak) id<RCAnimatedImagesViewDelegate> delegate;

@property(nonatomic, assign) NSTimeInterval timePerImage;

- (void)startAnimating;
- (void)stopAnimating;

- (void)reloadData;

@end

@protocol RCAnimatedImagesViewDelegate
- (NSUInteger)animatedImagesNumberOfImages:(RCAnimatedImagesView *)animatedImagesView;
- (UIImage *)animatedImagesView:(RCAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index;
@end
