/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCAMRDataConverter.h
//  Created by Heq.Shinoda on 14-6-17.

#ifndef __RCAMRDataConverter
#define __RCAMRDataConverter

#include "interf_dec.h"
#include "interf_enc.h"
#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*!
 AMR格式与WAV格式音频转换工具类
 */
@interface RCAMRDataConverter : NSObject

/*!
 获取AMR格式与WAV格式音频转换工具类单例

 @return AMR格式与WAV格式音频转换工具类单例
 */
+ (RCAMRDataConverter *)sharedAMRDataConverter;

/*!
 将AMR格式的音频数据转化为WAV格式的音频数据

 @param data    AMR格式的音频数据，可以是AMR-NB或者AMR-WB格式
 @return        WAV格式的音频数据
 */
- (NSData *)decodeAMRToWAVE:(NSData *)data;

/*!
 将AMR格式的音频数据转化为WAV格式的音频数据
 
 @param data    AMR格式的音频数据，必须是AMR-NB的格式
 @return        WAV格式的音频数据
 */
- (NSData *)decodeAMRToWAVEWithoutHeader:(NSData *)data;

/*!
 将WAV格式的音频数据转化为AMR格式的音频数据（8KHz采样）

 @param data            WAV格式的音频数据
 @param nChannels       声道数
 @param nBitsPerSample  采样位数（精度）
 @return                AMR-NB格式的音频数据

 @discussion
 此方法为工具类方法，您可以使用此方法将任意WAV音频转换为AMR-NB格式的音频。

 @warning
 如果您想和SDK自带的语音消息保持一致和互通，考虑到跨平台和传输的原因，SDK对于WAV音频有所限制.
 具体可以参考RCVoiceMessage中的音频参数说明(nChannels为1，nBitsPerSample为16)。
 */
- (NSData *)encodeWAVEToAMR:(NSData *)data channel:(int)nChannels nBitsPerSample:(int)nBitsPerSample __deprecated_msg("已废弃，请勿使用。");

/*!
 将WAV格式的音频数据转化为AMR格式的音频数据（8KHz/16KHz采样）
 
 @param data            WAV格式的音频数据
 @return                AMR-NB/AMR-WB格式的音频数据
 @discussion 如果采样率为8KHz则返回 AMR-NB 格式数据，如果采样率为16KHz则返回 AMR-WB 格式数据。
 */
- (NSData *)encodeWAVEToAMR:(NSData *)data;

@end

#endif
