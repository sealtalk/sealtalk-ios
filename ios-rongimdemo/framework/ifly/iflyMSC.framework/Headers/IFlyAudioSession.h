//
//  IFlyAudioSession.h
//  MSCDemo
//
//  Created by AlexHHC on 1/9/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  音频环境初始化
 */
@interface IFlyAudioSession : NSObject

/**
 *  初始化播音环境
 *
 *  @param isMPCenter 是否初始化MPPlayerCenter：0不初始化，1初始化
 */
+(void) initPlayingAudioSession:(BOOL)isMPCenter;

/**
 *  初始化录音环境
 *
 *  @return 成功返回YES，失败返回NO
 */
+(BOOL) initRecordingAudioSession;

@end
