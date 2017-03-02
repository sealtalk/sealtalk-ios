//
//  RCExtensionMessageCellInfo.h
//  RongIMExtension
//
//  Created by 岑裕 on 2016/10/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 MessageCell信息
 */
@interface RCExtensionMessageCellInfo : NSObject

@property (nonatomic, strong)Class messageContentClass;
@property (nonatomic, strong)Class messageCellClass;

@end
