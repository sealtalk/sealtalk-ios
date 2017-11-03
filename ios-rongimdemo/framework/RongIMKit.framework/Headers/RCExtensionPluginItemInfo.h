//
//  RCExtensionPluginItemInfo.h
//  RongExtensionKit
//
//  Created by 岑裕 on 2016/10/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCChatSessionInputBarControl.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^RCConversationPluginItemTapBlock)(RCChatSessionInputBarControl *chatSessionInputBar);

/*!
 Plugin board item信息
 */
@interface RCExtensionPluginItemInfo : NSObject

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, copy) RCConversationPluginItemTapBlock tapBlock;
@property(nonatomic, assign) NSInteger tag;

@end
