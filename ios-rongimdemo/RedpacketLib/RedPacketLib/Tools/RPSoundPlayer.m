//
//  RPSoundPlayer.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/9/13.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RPRedpacketTool.h"

static SystemSoundID redpacketOpenSoundId = 0;

@implementation RPSoundPlayer

+ (void)regisitSoundId
{
    /**
     *  抢红包的声音
     */
    CFURLRef urlref = [self urlPathWithSoundName:@"redpacket_sound_open.wav"];
    if (urlref) {
        AudioServicesCreateSystemSoundID(urlref,&redpacketOpenSoundId);
    }
}

+ (void)playRedpacketOpenSound
{
    AudioServicesPlaySystemSound(redpacketOpenSoundId);
}

+ (CFURLRef)urlPathWithSoundName:(NSString *)soundname
{
    //[[NSBundle RedpacketBundle] pathForResource:soundname ofType:@"wav"];
    NSString *path = rpRedpacketBundleResource(soundname);

    if (!path) {
        
        RPDebug(@"声音文件不存在，或者路径错误");
        return nil;
        
    }
    return (__bridge CFURLRef)[NSURL fileURLWithPath:path];
}

@end
