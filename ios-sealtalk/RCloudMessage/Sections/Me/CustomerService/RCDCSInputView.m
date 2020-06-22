//
//  RCDCSInputView.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSInputView.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
@interface RCDCSInputView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *placeHolderText;

@end

@implementation RCDCSInputView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self.placeHolderText addSubview:self.suggestText];
    }
    return self;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.suggestText becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.suggestText resignFirstResponder];
        return NO;
    }

    if (![text isEqualToString:@""]) {
        self.placeHolderText.text = nil;
    }

    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        self.placeHolderText.text = self.placeHolderString;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (![textView.text isEqualToString:@""]) {
        self.placeHolderText.text = nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //隐藏键盘
    [self.suggestText resignFirstResponder];
}

- (UITextView *)suggestText {
    if (!_suggestText) {
        _suggestText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.placeHolderText.frame.size.width,
                                                                    self.placeHolderText.frame.size.height)];
        _suggestText.layer.cornerRadius = 4;
        _suggestText.font = [UIFont systemFontOfSize:14];
        _suggestText.textColor = RCDDYCOLOR(0x939dab, 0x999999);
        _suggestText.backgroundColor = [UIColor clearColor];
        _suggestText.delegate = self;
        _suggestText.delegate = self;
    }
    return _suggestText;
}

- (UITextView *)placeHolderText {
    if (!_placeHolderText) {
        _placeHolderText = [[UITextView alloc] initWithFrame:CGRectMake(47, 0, RCDScreenWidth - 94, 80)];
        _placeHolderText.font = [UIFont systemFontOfSize:14];
        _placeHolderText.editable = NO;
        _placeHolderText.textColor = RCDDYCOLOR(0x939dab, 0x999999);
        _placeHolderText.backgroundColor = RCDDYCOLOR(0xf1f3f5, 0x1a1a1a);
        _placeHolderText.layer.cornerRadius = 4;
        [self addSubview:_placeHolderText];
        _placeHolderText.text = self.placeHolderString;
    }
    return _placeHolderText;
}

- (void)setPlaceHolderString:(NSString *)placeHolderString {
    _placeHolderString = placeHolderString;
    self.placeHolderText.text = placeHolderString;
    self.suggestText.text = nil;
}
@end
