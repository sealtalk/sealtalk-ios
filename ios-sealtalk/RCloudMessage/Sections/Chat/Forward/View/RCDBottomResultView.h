//
//  RCDBottomResultView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RCDBottomResultViewHeight 50

NS_ASSUME_NONNULL_BEGIN

@interface RCDBottomResultView : UIView

- (void)updateSelectResult;

- (void)updateSelectResult:(NSUInteger)result;

//只有当选择的人数大于0的时候才会触发下面的block，如果没有点击取消选人页面的确定按钮，vc为nil
@property (nonatomic, copy) void (^confirmButtonBlock)(void);
@property (nonatomic, copy) void (^resultButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
