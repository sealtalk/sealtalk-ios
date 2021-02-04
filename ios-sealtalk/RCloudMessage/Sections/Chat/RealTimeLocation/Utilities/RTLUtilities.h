//
//  RTLUtilities.h
//  SealTalk
//
//  Created by Jue on 2020/1/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTLUtilities : NSObject

+ (void)showHUDAddedTo:(UIView *)superView
                 color:(UIColor *)color
             labelText:(NSString *)labelText
              animated:(BOOL)animated;

+ (void)hideHUDAnimated:(BOOL)animated;

+ (void)setImageWithURL:(NSURL *)imageUrl
       placeholderImage:(UIImage *)placeholderImage
              imageView:(UIImageView *)imageView;

+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
