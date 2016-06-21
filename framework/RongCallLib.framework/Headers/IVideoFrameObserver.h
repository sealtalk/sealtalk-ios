#ifndef _ivideoframeobserve_h
#define _ivideoframeobserve_h
namespace RongCloud
{
  namespace media
  {

    class IVideoFrameObserver
    {
    public:
      virtual bool onCaptureVideoFrame(const unsigned char** yBuffer, const unsigned char** uBuffer, const unsigned char** vBuffer,
        unsigned int& width, unsigned int& height,
        unsigned int& yStride, unsigned int& uStride, unsigned int& vStride) = 0;
      virtual bool onRenderVideoFrame(const unsigned char** yBuffer, const unsigned char** uBuffer, const unsigned char** vBuffer,
        unsigned int& width, unsigned int& height,
        unsigned int& yStride, unsigned int& uStride, unsigned int& vStride) = 0;
      virtual bool onExternalVideoFrame(const unsigned char** yBuffer, const unsigned char** uBuffer, const unsigned char** vBuffer,
        unsigned int& width, unsigned int& height,
        unsigned int& yStride, unsigned int& uStride, unsigned int& vStride) = 0;
    };

  }
}

/*
 视频前后处理用这个头文件
 
 1.      必须使用C++，继承IVideoFrameObserver，实现需要的虚接口。需要对采集的图像处理的（前处理），在onCaptureVideoFrame中进行。需要对接收图像处理的（后处理），在onRenderVideoFrame中进行。3个函数都需要返回true
 2.      使用registerVideoFrameObserver注册实现了虚接口的类的对象
 3.      图像的格式是YUV420，程序只能修改buffer的内容，不能修改buffer的地址和大小
 */

#ifdef __cplusplus
extern "C"
{
#endif
    int RCRegisterVideoFrameObserver(RongCloud::media::IVideoFrameObserver *observer, bool useExternalResource = false, bool localPreview = true);
#ifdef __cplusplus
}
#endif
#endif
