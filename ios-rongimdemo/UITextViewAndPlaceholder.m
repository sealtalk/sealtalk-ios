//
//  UITextViewAndPlaceholder.m
//  RCloudMessage
//
//  Created by Jue on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "UITextViewAndPlaceholder.h"
#import "UIColor+RCColor.h"

@interface UITextViewAndPlaceholder ()

@property(nonatomic, weak) UILabel *placeholderLabel;

@end

@implementation UITextViewAndPlaceholder

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (self) {

        self.backgroundColor = [UIColor clearColor];

        UILabel *placeholderLabel = [[UILabel alloc] init]; //添加一个占位label

        placeholderLabel.backgroundColor = [UIColor clearColor];

        placeholderLabel.numberOfLines = 0; //设置可以输入多行文字时可以自动换行

        [self addSubview:placeholderLabel];

        self.placeholderLabel = placeholderLabel; //赋值保存

        self.myPlaceholderColor = [UIColor colorWithHexString:@"999999" alpha:1.0]; //设置占位文字默认颜色

        self.font = [UIFont systemFontOfSize:16]; //设置默认的字体

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self]; //通知:监听文字的改变

        //设置可以上下拖动
        [self setScrollEnabled:YES];
        self.userInteractionEnabled = YES;
        self.showsVerticalScrollIndicator = YES;
        CGSize size = CGSizeMake(0, 600.0f);
        [self setContentSize:size];
    }

    return self;
}

- (void)layoutSubviews {

    [super layoutSubviews];

    //根据文字计算高度

    CGSize maxSize = CGSizeMake(self.frame.size.width, MAXFLOAT);

    CGFloat height =
        [self.myPlaceholder boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : self.placeholderLabel.font}
                                         context:nil]
            .size.height;

    CGRect frame = CGRectMake(5, 8, self.frame.size.width, height);

    self.placeholderLabel.frame = frame;
}

- (void)setMyPlaceholder:(NSString *)myPlaceholder {

    _myPlaceholder = [myPlaceholder copy];

    //设置文字

    self.placeholderLabel.text = myPlaceholder;

    //重新计算子控件frame

    [self setNeedsLayout];
}

- (void)setMyPlaceholderColor:(UIColor *)myPlaceholderColor {

    _myPlaceholderColor = myPlaceholderColor;

    //设置颜色

    self.placeholderLabel.textColor = myPlaceholderColor;
}

- (void)setText:(NSString *)text {

    [super setText:text];

    [self textDidChange]; //这里调用的就是 UITextViewTextDidChangeNotification 通知的回调
}

- (void)textDidChange {

    self.placeholderLabel.hidden = self.hasText;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:UITextViewTextDidChangeNotification];
}

@end
