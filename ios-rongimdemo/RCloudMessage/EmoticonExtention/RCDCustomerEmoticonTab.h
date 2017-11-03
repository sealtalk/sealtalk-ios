//
//  RCDCustomerEmoticonTab.h
//  RCloudMessage
//
//  Created by 杜立召 on 16/9/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
@class RCDChatViewController;

@interface RCDCustomerEmoticonTab : NSObject <RCEmoticonTabSource>

/*!
 表情tab的标识符
 @return 表情tab的标识符，请勿重复
 */
@property(nonatomic, strong) NSString *identify;

/*!
 表情tab的图标
 @return 表情tab的图标
 */
@property(nonatomic, strong) UIImage *image;

/*!
 表情tab的页数
 @return 表情tab的页数
 */
@property(nonatomic, assign) int pageCount;
/*!
 表情tab的index页的表情View

 @return 表情tab的index页的表情View
 @discussion 返回的 view 大小必须等于 contentViewSize （宽度 = 屏幕宽度，高度 =
 186）
 */
- (UIView *)loadEmoticonView:(NSString *)identify index:(int)index;

//@property(nonatomic, weak) RCDChatViewController *chartView;
@end
