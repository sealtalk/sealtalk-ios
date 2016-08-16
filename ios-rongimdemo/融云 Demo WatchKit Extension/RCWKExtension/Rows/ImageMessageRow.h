//
//  ImageMessageRow.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ConversationRowBase.h"

@interface ImageMessageRow : ConversationRowBase
@property(weak, nonatomic) IBOutlet WKInterfaceImage *imageView;

@end
