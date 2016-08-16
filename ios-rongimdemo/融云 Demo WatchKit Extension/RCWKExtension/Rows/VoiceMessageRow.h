//
//  VoiceMessageRow.h
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ConversationRowBase.h"

@interface VoiceMessageRow : ConversationRowBase
@property(weak, nonatomic) IBOutlet WKInterfaceImage *voiceIcon;
- (void)updateUIPlaying;
- (void)updateUIStop;
@end
