//
//  RCDDescriptionView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/5.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCDTextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDDescriptionView : UIView

@property (nonatomic, strong) RCDTextView *textView;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *inputText;

@property (nonatomic, assign) NSUInteger charMaxCount;

@property (nonatomic, assign) BOOL showTextNumber;

@property (nonatomic, assign) BOOL rcdIsFirstResponder;

@end

NS_ASSUME_NONNULL_END
