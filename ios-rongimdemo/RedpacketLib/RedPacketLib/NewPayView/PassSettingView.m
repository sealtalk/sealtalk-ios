//
//  PassSettingView.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "PassSettingView.h"
#import "RedpacketColorStore.h"


@interface PassSettingView() <UITextFieldDelegate>

@property (nonatomic, strong)   NSArray *labels;

@property (nonatomic, assign)   UILabel *pass1;
@property (nonatomic, assign)   UILabel *pass2;
@property (nonatomic, assign)   UILabel *pass3;
@property (nonatomic, assign)   UILabel *pass4;
@property (nonatomic, assign)   UILabel *pass5;
@property (nonatomic, assign)   UILabel *pass6;

@property (nonatomic, strong)   UITextField *passwordField;

@property (nonatomic, assign) BOOL isInputError;

@end

@implementation PassSettingView

- (instancetype)initWithWith:(CGFloat)width andPadding:(CGFloat)padding
{
    self = [super init];
    if (self) {
        self.passwordField.delegate = self;
        _isSecurity = YES;
        _labels = [self createPassFieldWithWidth:width andPadding:padding];
        CGFloat height = 36.0f;
        UILabel *label = _labels[0];
        if (label) {
            height = CGRectGetHeight(label.frame);
        }
        
        self.frame = CGRectMake(0, 0, width, height);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
        [self addGestureRecognizer:tap];
    }

    return self;
}

- (NSArray *)createPassFieldWithWidth:(CGFloat)width andPadding:(CGFloat)padding
{
    NSMutableArray *array = [NSMutableArray array];
    CGFloat avgWidth = (width - 2 * padding) / 6;
    for (NSInteger i = 0; i < 6; i++) {
        CGFloat x = padding + i * avgWidth - i / [UIScreen mainScreen].scale;
        CGFloat y = 0.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, avgWidth, 43)];
        [self formatLabel:label];
        [self addSubview:label];
        [array addObject:label];
    }
    
    return array;
}

- (void)setIsSecurity:(BOOL)isSecurity
{
    _isSecurity = isSecurity;
}

- (void)formatLabel:(UILabel *)label
{
    label.backgroundColor   = [UIColor clearColor];
    label.textAlignment     = NSTextAlignmentCenter;
    label.font              = [UIFont systemFontOfSize:20.0f];
    label.layer.borderColor = [RedpacketColorStore rp_lineColorLightGray].CGColor;
    label.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
    label.text              = @"";
}

#pragma mark -

- (void)clearPassword
{
    _passwordField.text = @"";
    for (UILabel *label in _labels) {
        label.text = @"";
    }
}

- (void)passwordInputError:(BOOL)error
{
    _isInputError = error;
    for (UILabel *label in _labels) {
        label.layer.borderColor = error ? [RedpacketColorStore rp_textColorRed].CGColor : [RedpacketColorStore rp_textColorLightGray].CGColor;
    }
}

- (void)formatPassLabel:(NSArray *)labels
{
    for (UILabel *label in labels) {
        label.backgroundColor   = [UIColor clearColor];
        label.layer.borderColor = [RedpacketColorStore rp_lineColorLightGray].CGColor;
        label.layer.borderWidth = 1.0f / [UIScreen mainScreen].scale;
        label.text              = @"";
    }
}

- (void)viewTaped:(UITapGestureRecognizer *)tap
{
    [self.passwordField becomeFirstResponder];
}

- (void)becomeFirstResponder
{
    [self.passwordField becomeFirstResponder];
}

- (void)resignFirstResponder
{
    [self.passwordField resignFirstResponder];
}

#pragma mark - Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replaceString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (replaceString.length > 6) {
        return NO;
    }
    
    if ([string isEqualToString:@""]) {
        UILabel *label = [_labels objectAtIndex:replaceString.length];
        label.text = @"";
        
    }else {
        UILabel *label = [_labels objectAtIndex:textField.text.length];
        if (_isSecurity) {
            label.text = @"*";
        }else {
            label.text = string;
        }
        
    }
    
    //  验证密码
    if (_passViewBlock && replaceString.length == 6) {
        _passViewBlock(replaceString);
    }
    
    if (_passViewInputingBlock && _isInputError) {
        _passViewInputingBlock(textField.text);
    }
    
    return YES;
}

- (NSString *)password
{
    return _passwordField.text;
}

#pragma mark -
- (UITextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _passwordField.keyboardType = UIKeyboardTypeNumberPad;
        _passwordField.hidden = YES;
        [self addSubview:_passwordField];
    }
    
    return _passwordField;
}

@end
