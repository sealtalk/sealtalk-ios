//
//  TextMessageRow.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/28.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ConversationRowBase.h"

@interface TextMessageRow : ConversationRowBase
@property(weak, nonatomic) IBOutlet WKInterfaceLabel *contentLabel;

@end
