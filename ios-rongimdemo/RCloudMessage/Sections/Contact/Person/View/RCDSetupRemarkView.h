//
//  RCDSetupRemarkView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/8/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapAreaCodeBlock)();

@interface RCDSetupRemarkView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, copy) NSString *inputText;

@property (nonatomic, assign) NSUInteger charMaxCount;

@property (nonatomic, assign) BOOL showCountryBtn;

@property (nonatomic, assign) BOOL isPhoneNumber;

@property (nonatomic, copy) NSString *btnTitle;

@property (nonatomic, copy) TapAreaCodeBlock tapAreaCodeBlock;

@end

NS_ASSUME_NONNULL_END
