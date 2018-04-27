
//
//  IFlyVoiceWakeuperDel.h
//  wakeup
//
//  Created by admin on 14-3-18.
//  Copyright (c) 2014年 iflytek. All rights reserved.
//



#import <Foundation/Foundation.h>

@class IFlySpeechError;

/*!
 *  代理返回时序描述
 
   onError 为唤醒会话错误反馈<br>
   onBeginOfSpeech 表示录音开始<br>
   onVolumeChanged 录音音量大小<br>
   onEndOfSpeech 录音结束，当服务终止时返回onEndOfSpeech<br>
   onResult 服务结果反馈，内容定义如下
 
 *  唤醒服务
 
    例：<br>
    focus_type = wake   唤醒会话<br>
    wakeup_result_id = 0    唤醒词位置<br>
    wakeup_result_Score = 60    唤醒词可信度<br>
 
 *  注册服务
 
    例：<br>
    focus_type = enroll 注册会话<br>
    enroll_success_num = 1  当前注册成功次数<br>
    current_enroll_status = success/failed  当前会话是否成功<br>
    wakeup_result_Score = 60    注册结果可信度<br>
    threshold = 10  当注册达到3次后，反馈对应资源的阀值
 */
@protocol IFlyVoiceWakeuperDelegate <NSObject>

@optional

/*!
 * 录音开始
 */
-(void) onBeginOfSpeech;

/*!
 * 录音结束
 */
-(void) onEndOfSpeech;

/*!
 * 会话错误
 *
 * @param error 错误描述类，
 */
- (void) onError:(IFlySpeechError *) error;

/*!
 * 唤醒结果
 *
 * @param resultDic 唤醒结果字典
 */
-(void) onResult:(NSMutableDictionary *)resultDic;

/*!
 * 音量反馈，返回频率与录音数据返回回调频率一致
 *
 * @param volume 音量值
 */
- (void) onVolumeChanged: (int)volume;


/*!
 * 扩展事件回调<br>
 * 根据事件类型返回额外的数据
 *
 @param eventType 事件类型，具体参见IFlySpeechEvent枚举。
 */
- (void) onEvent:(int)eventType isLast:(BOOL)isLast arg1:(int)arg1 data:(NSMutableDictionary *)eventData;

@end

