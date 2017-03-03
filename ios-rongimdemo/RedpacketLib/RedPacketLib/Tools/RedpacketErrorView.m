//
//  RedpacketErrorView.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/5/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketErrorView.h"
#import "UIView+YZHExtension.h"
#import "RPRedpacketTool.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"

@implementation RedpacketErrorView

+ (RedpacketErrorView *)viewWithWith:(CGFloat)width
{
    RedpacketErrorView *view = [RedpacketErrorView new];
    view.rp_width = width;
    
    return view;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [UIImageView new];
        _imageView.rp_size = CGSizeMake(93.0f, 93.0f);
        _imageView.image = rpRedpacketBundleImage(@"hudView_error");
        [self addSubview:_imageView];
        
        _prompt = [UILabel new];
        _prompt.textColor = [RedpacketColorStore rp_textColorLightGray];
        _prompt.text = @"糟糕，好像哪里出了点问题";
        _prompt.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:_prompt];
        
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.rp_size = CGSizeMake(109, 33);
        [_submitButton setBackgroundImage:rpRedpacketBundleImage(@"hudView_button_error") forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_submitButton];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.rp_width;
    CGFloat margin = (width - self.imageView.rp_width) / 2.0f;
    _imageView.rp_left = margin;
    _imageView.rp_top = 90.0f;
    
    [_prompt sizeToFit];
    _prompt.rp_top = _imageView.rp_bottom + 18.0f;
    _prompt.rp_left = (width - self.prompt.rp_width) / 2.0f;
    
    _submitButton.rp_top = _prompt.rp_bottom + 46.0f;
    _submitButton.rp_left = (width - self.submitButton.rp_width) / 2.0f;

}


- (void)submitButtonClicked
{
    if (_buttonClickBlock) {
        _buttonClickBlock();
    }
}

@end
