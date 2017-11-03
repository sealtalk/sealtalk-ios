//
//  RCMessageBubbleTipView.h
//  RCIM
//
//  Created by xugang on 14-6-20.
//  Copyright (c) 2014年 xugang. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 角标的位置
 */
typedef NS_ENUM(NSInteger, RCMessageBubbleTipViewAlignment) {
    /*!
     左上
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_LEFT,
    /*!
     右上
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_RIGHT,
    /*!
     中上
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_CENTER,
    /*!
     左中
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_CENTER_LEFT,
    /*!
     右中
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_CENTER_RIGHT,
    /*!
     左下
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_BOTTOM_LEFT,
    /*!
     右下
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_BOTTOM_RIGHT,
    /*!
     中下
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_BOTTOM_CENTER,
    /*!
     正中
     */
    RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_CENTER
};

/*!
 消息未读提示角标的View
 */
@interface RCMessageBubbleTipView : UIView

/*!
 角标显示的文本
 */
@property(nonatomic, copy) NSString *bubbleTipText;

/*!
 角标的位置

 @discussion 默认值为RC_MESSAGE_BUBBLE_TIP_VIEW_ALIGNMENT_TOP_RIGHT，即右上。
 */
@property(nonatomic, assign) RCMessageBubbleTipViewAlignment bubbleTipAlignment;

/*!
 角标文本的颜色
 */
@property(nonatomic, strong) UIColor *bubbleTipTextColor;

/*!
 角标文本的阴影值
 */
@property(nonatomic, assign) CGSize bubbleTipTextShadowOffset;

/*!
 角标文本的阴影颜色
 */
@property(nonatomic, strong) UIColor *bubbleTipTextShadowColor;

/*!
 角标文本的字体
 */
@property(nonatomic, strong) UIFont *bubbleTipTextFont;

/*!
 角标的背景颜色
 */
@property(nonatomic, strong) UIColor *bubbleTipBackgroundColor;

/*!
 角标的覆盖颜色（已废弃，请勿使用）

 @warning **已废弃，请勿使用。**
 */
@property(nonatomic, strong) __deprecated_msg("已废弃，请勿使用。") UIColor *bubbleTipOverlayColor;

/*!
 角标View偏移的Rect
 */
@property(nonatomic, assign) CGPoint bubbleTipPositionAdjustment;

/*!
 角标依附于的View Rect
 */
@property(nonatomic, assign) CGRect frameToPositionInRelationWith;

/*!
 角标是否显示数字

 @discussion 如果为NO，会显示红点，不显示具体数字。
 */
@property(nonatomic) BOOL isShowNotificationNumber;

/*!
 初始化角标View

 @param parentView  角标依附于的View
 @param alignment   角标的位置
 @return            角标View对象
 */
- (instancetype)initWithParentView:(UIView *)parentView alignment:(RCMessageBubbleTipViewAlignment)alignment;

/*!
 设置角标的值

 @param msgCount 角标值
 */
- (void)setBubbleTipNumber:(int)msgCount;

@end
