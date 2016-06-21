//
//  SentVoiceMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "SentVoiceMessageRow.h"

@implementation SentVoiceMessageRow
- (void)updateUIPlaying {
  [self.voiceIcon setImageNamed:@"to_voice_play"];
  [self.voiceIcon startAnimating];
}
- (void)updateUIStop {
  [self.voiceIcon stopAnimating];
  [self.voiceIcon setImageNamed:@"to_voice"];
}
@end
