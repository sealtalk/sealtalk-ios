//
//  VoiceInputController.m
//  RongIMDemo
//
//  Created by litao on 15/4/1.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "VoiceInputController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCAppQueryHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface VoiceInputController()
@property (weak, nonatomic) IBOutlet WKInterfaceButton *recordButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *sendButton;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *recordImage;
@property (strong, nonatomic)RCConversation *conversation;
@property (nonatomic)BOOL isRecording;
@property (strong, nonatomic)AVAudioRecorder *recorder;
@property (strong, nonatomic)NSURL *recordTempFileURL;
@property (strong, nonatomic)NSData *recordedData;
@property (nonatomic)NSTimeInterval duration;
@end

@implementation VoiceInputController
- (IBAction)recordButtonPressed {
    if (self.isRecording) {
        [self stopRecord];
    } else {
        [self startRecord];
    }
}

- (IBAction)sendButtonPressed {
    if (self.recordedData && self.duration > 1)  {
        [RCAppQueryHelper requestParentAppSendVoiceMsg:self.conversation.targetId
                                                type:self.conversation.conversationType
                                             content:self.recordedData
                                             duration:self.duration
                                               reply:^(BOOL sendToLib) {
                                                   [self dismissController];
                                               }];
        self.recordedData = nil;
        self.duration = 0;
        self.isRecording = NO;
    } else {
        NSLog(@"invalid data");
    }
}

- (NSURL *)recordTempFileURL
{
    if (!_recordTempFileURL) {
        _recordTempFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: @"tempAC.caf"]];
    }
    return _recordTempFileURL;
}

- (AVAudioRecorder *)recorder
{
    if (!_recorder) {
        NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                                   AVSampleRateKey: @8000.00f,
                                   AVNumberOfChannelsKey: @1,
                                   AVLinearPCMBitDepthKey: @16,
                                   AVLinearPCMIsNonInterleaved: @NO,
                                   AVLinearPCMIsFloatKey: @NO,
                                   AVLinearPCMIsBigEndianKey: @NO};
        NSError *error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordTempFileURL settings:settings error:&error];
    }
    return _recorder;
}

- (void)startRecord
{
    [self.recorder prepareToRecord];
    
    self.isRecording = [self.recorder record];
}
- (void)stopRecord
{
    if (self.isRecording) {
        self.recordedData =[NSData dataWithContentsOfURL:self.recordTempFileURL];
        self.duration = self.recorder.currentTime;
        [self.recorder stop];
    }
    self.isRecording = NO;
    
}
- (void)cancelRecord
{
    if (nil != self.recorder && [self.recorder isRecording]) {
        [self.recorder stop];
        [self.recorder deleteRecording];
        self.isRecording = false;
    }
}

- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
    [self updateUI];
}
- (instancetype)init {
    self = [super init];
    NSLog(@"conversationController init");
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    self.conversation = context;
    
    // Retrieve the data. This could be accessed from the iOS app via a shared container.
    self.isRecording = false;
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self cancelRecord];
    [super didDeactivate];
}

- (void)updateUI
{
    if (self.isRecording) {
        [self.recordButton setTitle:@"停止录音"];
        [self.recordImage setImageNamed:@"to_voice_play"];
        [self.recordImage startAnimating];
        [self.sendButton setEnabled:false];
    } else {
        [self.recordButton setTitle:@"开始录音"];
        if (self.recordedData && self.duration > 1) {
            [self.sendButton setEnabled:true];
            [self.recordImage setImageNamed:@"to_voice"];
        } else {
            [self.sendButton setEnabled:false];
            [self.recordImage setImageNamed:nil];
        }
        
        [self.recordImage stopAnimating];
        
    }
}
@end
