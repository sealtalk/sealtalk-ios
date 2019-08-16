//
//  RCDTipFooterView.h
//  SealTalk
//
//  Created by hrx on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDTipFooterView : UIView

- (void)renderWithTip:(NSString *)tip font:(UIFont *)font;

- (CGFloat)heightForTipFooterViewWithTip:(NSString *)tip font:(UIFont *)font constrainedSize:(CGSize)constrainedSize;

@end

NS_ASSUME_NONNULL_END
