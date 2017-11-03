/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCPublicServiceMenu.h
//  Created by litao on 15/4/14.

#import "RCPublicServiceMenuItem.h"
#import <Foundation/Foundation.h>

/*!
 公众服务账号菜单类

 @discussion
 公众服务菜单类，其中包含若干数量的菜单项，每个菜单项可能还包含子菜单项。
 公众服务菜单的树状结构如下所示：
 Menu -> MenuItem1
         MenuItem2  -> MenuItem2.1
                       MenuItem2.2
         MenuItem3  -> MenuItem3.1
                       MenuItem3.2
                       MenuItem3.3
 */
@interface RCPublicServiceMenu : NSObject

/*!
 菜单中包含的所有菜单项RCPublicServiceMenuItem数组
 */
@property(nonatomic, strong) NSArray *menuItems;

/*!
 将公众服务菜单下的所有菜单项解码（已废弃，请勿使用）

 @param jsonDictionary  公众服务菜单项Json组成的数组

 @warning **已废弃，请勿使用。**
 */
- (void)decodeWithJsonDictionaryArray:(NSArray *)jsonDictionary __deprecated_msg("已废弃，请勿使用。");

@end
