//
//  HTPlaceHolderTextView
//  htlabel
//
//  Created by Mr.Yang on 14-4-4.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//


#import "PlaceHolderTextView.h"
#import "RedpacketColorStore.h"

@interface HTPlaceHolderTextView () {
    BOOL _placeHolderVisible;
    BOOL _hasSetPlaceHolderVisible;
}

@property (nonatomic, assign)   BOOL shouldDrawPlaceHold;

@end

@implementation HTPlaceHolderTextView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    if (!_placeholderColor) {
        _placeholderColor = [RedpacketColorStore rp_colorWithHEX:0x9e9e9e];
    }
    
    if (!self.font) {
        self.font = [UIFont systemFontOfSize:16.0f];
    }
    
    if (!_hasSetPlaceHolderVisible) {
        _placeHolderVisible = YES;
    }
    
    _shouldDrawPlaceHold = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self initialize];
    }
    return self;
}

- (void)setPlaceHolderVisible:(BOOL)hidden {
    _hasSetPlaceHolderVisible = YES;
    _placeHolderVisible = hidden;
    [self reloadVisibleState];
}

- (void)textChanged:(NSNotification *)notification {
    [self reloadVisibleState];
}

- (void)setPlaceholder:(NSString *)placeholder {
    if (_placeholder != placeholder) {
        if (self.ellipsisState) {
            //  不截取
        } else {
            if (placeholder.length > 20) {
                placeholder = [placeholder substringToIndex:20];
                placeholder = [placeholder stringByAppendingString:@"..."];
            }
        }
        
        _placeholder = placeholder;
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self reloadVisibleState];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];
    
    [self setNeedsDisplay];
}

- (void)reloadVisibleState {
    
    if (!self.text.length && self.placeholder.length && _placeHolderVisible) {
        _shouldDrawPlaceHold = YES;
    } else {
        _shouldDrawPlaceHold = NO;
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGRect dractRect = UIEdgeInsetsInsetRect(rect, self.textContainerInset);
    dractRect.origin.x += 6;
    
    if (_shouldDrawPlaceHold) {
        [_placeholder drawInRect:dractRect withAttributes:@{NSFontAttributeName:self.font,
                                                            NSForegroundColorAttributeName:self.placeholderColor}];
    }
    
    [super drawRect:rect];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
