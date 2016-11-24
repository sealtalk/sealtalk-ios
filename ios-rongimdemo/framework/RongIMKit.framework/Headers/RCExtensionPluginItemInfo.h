//
//  RCExtensionPluginItemInfo.h
//  RongExtensionKit
//
//  Created by 岑裕 on 2016/10/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCChatSessionInputBarControl.h"

typedef void (^RCConversationPluginItemTapBlock)(RCChatSessionInputBarControl *chatSessionInputBar);

/*!
 Plugin board item信息
 */
@interface RCExtensionPluginItemInfo : NSObject

@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, copy)RCConversationPluginItemTapBlock tapBlock;

@end
