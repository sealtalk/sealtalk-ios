//
//  RCDIndicateTextField.h
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickedTextField)(void);

@interface RCDIndicateTextField : UIView

@property (nonatomic, strong) UILabel *indicateInfoLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *indicateIcon;

- (instancetype)initWithLineColor:(UIColor *)color;
- (void)indicateIconShow:(BOOL)isShow;
@end

NS_ASSUME_NONNULL_END
