//
//  HTPlaceHolderTextView
//  htlabel
//
//  Created by Mr.Yang on 14-4-4.
//  Copyright (c) 2014年 Mr.Yang. All rights reserved.
//


#import <UIKit/UIKit.h>


/**
 *  带PlaceHolder的TextView
 */
@interface HTPlaceHolderTextView : UITextView

@property(nonatomic, strong) NSString *placeholder;

@property(nonatomic, strong) UIColor *placeholderColor;

//  省略号的状态
@property(nonatomic, assign) BOOL ellipsisState;

- (void)setPlaceHolderVisible:(BOOL)hidden;

@end
