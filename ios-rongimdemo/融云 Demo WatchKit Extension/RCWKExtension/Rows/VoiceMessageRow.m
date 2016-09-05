//
//  VoiceMessageRow.m
//  RongIMWatchKit
//
//  Created by litao on 15/4/29.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "VoiceMessageRow.h"
#import <AVFoundation/AVFoundation.h>

@interface VoiceMessageRow () <AVAudioPlayerDelegate>
@property(strong, nonatomic) NSData *wavAudioData;
@property(nonatomic) BOOL isPlaying;
@property(nonatomic, strong) AVAudioPlayer *player;
@end

@implementation VoiceMessageRow
- (void)setMessage:(RCMessage *)message {
  [super setMessage:message];
//  RCVoiceMessage *voiceMsg = (RCVoiceMessage *)message.content;
  if (message.messageDirection == MessageDirection_SEND) {
    [self.voiceIcon setImageNamed:@"to_voice"];
  } else {
    [self.voiceIcon setImageNamed:@"from_voice"];
  }
}
- (void)rowSelected:(RCMessage *)message {
  [super rowSelected:message];
  RCVoiceMessage *voiceMsg = (RCVoiceMessage *)message.content;
  self.wavAudioData = voiceMsg.wavAudioData;
  [self voicePressed];
}
- (void)setWavAudioData:(NSData *)wavAudioData {
  _wavAudioData = wavAudioData;
  NSError *error;
  AVAudioPlayer *player =
      [[AVAudioPlayer alloc] initWithData:wavAudioData error:&error];
  self.player = player;
  self.player.delegate = self;
}

- (void)voicePressed {
  NSLog(@"pressed");
  if (self.isPlaying) {
    [self stop];
  } else {
    [self playing];
  }
}

- (void)playing {
  self.isPlaying = YES;
  [self updateUI];
  [self.player prepareToPlay];
  [self.player play];
}
- (void)stop {
  self.isPlaying = NO;
  [self updateUI];
  [self.player stop];
}

- (void)updateUI {
  if (self.isPlaying) {
    [self updateUIPlaying];
  } else {
    [self updateUIStop];
  }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
  self.isPlaying = NO;
  [self updateUI];
}
@end
