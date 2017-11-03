//
//  RCDBaseSettingTableViewCell.h
//  RCloudMessage
//
//  Created by Jue on 16/8/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDConversationSettingTableViewHeader;

/**
 *  RCDBaseSettingTableViewCellDelegate
 */
@protocol RCDBaseSettingTableViewCellDelegate <NSObject>

@optional

/*!
 开闭switchButton的回调函数
 @param sender 点击的Switch开关
 */
- (void)onClickSwitchButton:(id)sender;

@end

@interface RCDBaseSettingTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *leftImageView;

@property(nonatomic, assign) CGFloat leftImageCornerRadius;

@property(nonatomic, strong) UILabel *leftLabel;

@property(nonatomic, strong) UILabel *rightLabel;

@property(nonatomic, strong) UISwitch *switchButton;

@property(nonatomic, strong) UIImageView *rightImageView;

@property(nonatomic, assign) CGFloat rightImageCornerRadius;

@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, strong) UIView *bottomLine;

@property(nonatomic, assign) BOOL switchButtonStatus;

@property(nonatomic, strong) NSArray *leftLabelConstraints;

@property(weak, nonatomic) id<RCDBaseSettingTableViewCellDelegate> baseSettingTableViewDelegate;

//两边如果有图片，使用该方法初始化Cell。
- (id)initWithLeftImageStr:(NSString *)leftImageStr
             leftImageSize:(CGSize)leftImageSize
              rightImaeStr:(NSString *)rightImageStr
            rightImageSize:(CGSize)rightImageSize;

/*!
 设置imageView方法
 @param imageView   cell中左边或者右边的imageView
 @param imageStr    image的name或者url
 @param imageSize   image的尺寸大小
 @param LeftOrRight 为了设置约束，需要告诉方法是设置左边还是右边的imageView
                    0:表示设置左边的imageView。
                    1:表示设置右边的imageView。
 */
- (void)setImageView:(UIImageView *)imageView
            ImageStr:(NSString *)imageStr
           imageSize:(CGSize)imageSize
         LeftOrRight:(NSInteger)LeftOrRight;

/*!
 cell的style
 */
typedef NS_ENUM(NSUInteger, RCDBaseSettingCellStyle) {
    /*!
     Display：leftLabel,rightArrow
     */
    DefaultStyle = 0,

    /*!
     Display：leftLabel,rightLabel
     */
    DefaultStyle_RightLabel_WithoutRightArrow = 1,

    /*!
     Display：leftLabel,rightLabel,rightArrow
     */
    DefaultStyle_RightLabel = 2,

    /*!
     Display：leftLabel,switchButton
     */
    SwitchStyle = 3,

    /*!
     Display：leftLabel
     */
    OnlyDisplayLeftLabelStyle = 4
};

//设置cell的style
- (void)setCellStyle:(RCDBaseSettingCellStyle)style;

@end
