//
//  RCDIndicateTextField.m
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCDIndicateTextField.h"
@interface RCDIndicateTextField ()
@property (nonatomic, strong) UIColor *lineColor;
@end
@implementation RCDIndicateTextField
- (instancetype)initWithLineColor:(UIColor *)color{
    self = [super init];
    if (self) {
        [self initialize];
        self.lineColor = color;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Get the current drawing context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the line color and width
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    
    // Start a new Path
    CGContextBeginPath(context);
    
    // Find the number of lines in our textView + add a bit more height to draw
    // lines in the empty part of the view
    // NSUInteger numberOfLines = (self.contentSize.height +
    // self.bounds.size.height) / self.font.leading;
    
    // Set the line offset from the baseline. (I'm sure there's a concrete way to
    // calculate this.)
    CGFloat baselineOffset = 45.0f;
    
    // iterate over numberOfLines and draw each line
    // for (int x = 1; x < numberOfLines; x++) {
    
    // 0.5f offset lines up line with pixel boundary
    CGContextMoveToPoint(context, self.bounds.origin.x, baselineOffset);
    CGContextAddLineToPoint(context, self.bounds.size.width - 10, baselineOffset);
    //}
    
    // Close our Path and Stroke (draw) it
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

#pragma mark - 初始化与布局

//初始化
- (void)initialize {
    self.lineColor = [UIColor colorWithRed:161 green:163 blue:168 alpha:0.2f];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.indicateInfoLabel];
    [self addSubview:self.textField];
    [self addSubview:self.indicateIcon];
    
    self.indicateInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.indicateIcon.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *subviews = NSDictionaryOfVariableBindings(_indicateInfoLabel, _textField, _indicateIcon);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_indicateInfoLabel(44)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:subviews]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicateInfoLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textField(44)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:subviews]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_textField
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:1]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_indicateIcon(14)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:subviews]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicateIcon
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"H:|-0-[_indicateInfoLabel]-10-[_textField(>=100)]|"
                          options:0
                          metrics:nil
                          views:subviews]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"H:[_indicateIcon(9)]-10-|"
                          options:0
                          metrics:nil
                          views:subviews]];
}

- (void)indicateIconShow:(BOOL)isShow{
    self.indicateIcon.hidden = !isShow;
    if (isShow) {
        [self updateLayout];
    }
}

- (void)updateLayout{
//    NSDictionary *subviews = NSDictionaryOfVariableBindings(_indicateInfoLabel, _textField, _indicateIcon);
//    [self addConstraints:[NSLayoutConstraint
//                          constraintsWithVisualFormat:
//                          @"H:|[_indicateIcon]-0-|"
//                          options:0
//                          metrics:nil
//                          views:subviews]];
//    [self setNeedsLayout];
//    [self layoutIfNeeded];
}

#pragma mark -控件属性初始化

- (UILabel *)indicateInfoLabel {
    if (_indicateInfoLabel == nil) {
        _indicateInfoLabel = [[UILabel alloc] init];
        _indicateInfoLabel.textColor = [UIColor whiteColor];
        [_indicateInfoLabel sizeToFit];
    }
    return _indicateInfoLabel;
}

- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor whiteColor];
    }
    return _textField;
}

- (UIImageView *)indicateIcon{
    if (_indicateIcon == nil) {
        _indicateIcon = [[UIImageView alloc] init];
        _indicateIcon.image = [UIImage imageNamed:@"location_arrow"];
        _indicateIcon.hidden = YES;
    }
    return _indicateIcon;
}
@end
