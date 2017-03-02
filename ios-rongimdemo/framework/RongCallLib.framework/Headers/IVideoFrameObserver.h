#ifndef _ivideoframeobserve_h
#define _ivideoframeobserve_h

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/IAgoraMediaEngine.h>


/*
 视频前后处理用这个头文件

 1.
 必须使用C++，继承IVideoFrameObserver，实现需要的虚接口。需要对采集的图像处理的（前处理），在onCaptureVideoFrame中进行。需要对接收图像处理的（后处理），在onRenderVideoFrame中进行。3个函数都需要返回true
 2.      使用RCRegisterVideoFrameObserver注册实现了虚接口的类的对象
 3. 图像的格式是YUV420，程序只能修改buffer的内容，不能修改buffer的地址和大小
 4. 如果要使用外置视频源，useExternalResource为true，然后在onCaptureVideoFrame中把自己捕获的数据写入。
 */

#ifdef __cplusplus
extern "C" {
#endif
int agoraRegisterVideoFrameObserver(agora::media::IVideoFrameObserver *observer,
    bool useExternalResource = false, bool localPreview = true);
  
int agoraRegisterAudioFrameObserver(agora::media::IAudioFrameObserver* observer);
  
NSString *rcGetUserIdFromAgoraUID(int uid);
#ifdef __cplusplus
}
#endif
#endif
