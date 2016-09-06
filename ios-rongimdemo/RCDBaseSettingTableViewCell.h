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

@property(nonatomic, strong) UILabel *leftLabel;

@property(nonatomic, strong) UILabel *rightLabel;

@property(nonatomic, strong) UISwitch *switchButton;

@property(nonatomic, strong) UIImageView *rightImageView;

@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, strong) UIView *bottomLine;

@property(nonatomic, assign) BOOL switchButtonStatus;

@property(weak, nonatomic) id<RCDBaseSettingTableViewCellDelegate>
baseSettingTableViewDelegate;

//两边如果有图片，使用该方法初始化Cell。
-(id)initWithLeftImage:(UIImage *)leftImage
         leftImageSize:(CGSize)leftImageSize
             rightImae:(UIImage *)rightImage
        rightImageSize:(CGSize)rightImageSize;

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
