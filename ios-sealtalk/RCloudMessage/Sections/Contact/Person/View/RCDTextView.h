//
//  RCDTextView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RCDTextView;
@protocol RCDTextViewDelegate <NSObject>
@optional
- (void)rcdTextView:(RCDTextView *)textView textDidChange:(NSString *)text;
@end

@interface RCDTextView : UITextView

@property (nonatomic, weak) id<RCDTextViewDelegate> textChangeDelegate;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) UIFont *placeholderFont;

- (void)setPlaceholder:(NSString *)placeholder color:(UIColor *)color font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
