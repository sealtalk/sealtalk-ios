//
//  ReceivedVoiceMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ReceivedVoiceMessageRow.h"

@implementation ReceivedVoiceMessageRow
- (void)updateUIPlaying {
  [self.voiceIcon setImageNamed:@"from_voice_play"];
  [self.voiceIcon startAnimating];
}
- (void)updateUIStop {
  [self.voiceIcon stopAnimating];
  [self.voiceIcon setImageNamed:@"from_voice"];
}
@end
