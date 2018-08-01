/*!
 @header BlinkEngine.h
 @author BailingCloud
 @version 2.0.1_20180727163342_dev_meeting_dev_rce_562b2f5
 @Copyright © 2018年 BailingCloud. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

#define SDKCompileInfo @"2.0.1_20180727163342_dev_meeting_dev_rce_562b2f5"

//宏定义说明, 设置视频聊天参数时的Key值, 详见SetVideoParameters:方法
#define kAudioOnly      @"AudioOnly"
#define kVideoProfile   @"VideoProfile"
#define kMaxBandWidth   @"MaxBandWidth"
#define kUserType       @"UserType"
#define kCloseCamera    @"CloseCamera"
#define kGPUFilter      @"GPUFilter"


/**
 *定义分辨率与帧率
 */
typedef NS_ENUM(NSInteger, BlinkVideoProfile)
{
    /**
     *无效
     */
    Blink_VideoProfile_Invalid   = -1,
    /**
     *分辨率:256x144,  帧率:15
     */
    Blink_VideoProfile_256_144P      = 0,
    /**
     *分辨率:256x144,  帧率:24
     */
    Blink_VideoProfile_256_144P_1    = 1,
    /**
     *分辨率:256x144,  帧率:30
     */
    Blink_VideoProfile_256_144P_2    = 2,
    /**
     *分辨率:320x240,  帧率:15
     */
    Blink_VideoProfile_320_240P      = 10,
    /**
     *分辨率:320x240,  帧率:24
     */
    Blink_VideoProfile_320_240P_1    = 11,
    /**
     *分辨率:320x240,  帧率:30
     */
    Blink_VideoProfile_320_240P_2    = 12,
    /**
     *分辨率:480x360,  帧率:15
     */
    Blink_VideoProfile_480_360P      = 20,
    /**
     *分辨率:480x360,  帧率:24
     */
    Blink_VideoProfile_480_360P_1    = 21,
    /**
     *分辨率:480x360,  帧率:30
     */
    Blink_VideoProfile_480_360P_2    = 22,
    
    /**
     *分辨率:640x360,  帧率:15
     */
    Blink_VideoProfile_640_360P      = 30,
    /**
     *分辨率:640x360,  帧率:24
     */
    Blink_VideoProfile_640_360P_1    = 31,
    /**
     *分辨率:640x360,  帧率:30
     */
    Blink_VideoProfile_640_360P_2    = 32,
    /**
     *分辨率:640x480,  帧率:15
     */
    Blink_VideoProfile_640_480P      = 40,
    /**
     *分辨率:640x480,  帧率:24
     */
    Blink_VideoProfile_640_480P_1    = 41,
    /**
     *分辨率:640x480,  帧率:30
     */
    Blink_VideoProfile_640_480P_2    = 42,
    /**
     *分辨率:720x480,  帧率:15
     */
    Blink_VideoProfile_720_480P      = 50,
    /**
     *分辨率:720x480,  帧率:24
     */
    Blink_VideoProfile_720_480P_1    = 51,
    /**
     *分辨率:720x480,  帧率:30
     */
    Blink_VideoProfile_720_480P_2    = 52,
    /**
     *分辨率:1280x720,  帧率:15
     */
    Blink_VideoProfile_1280_720P      = 60,
    /**
     *分辨率:1280x720,  帧率:24
     */
    Blink_VideoProfile_1280_720P_1    = 61,
    /**
     *分辨率:1280x720,  帧率:30
     */
    Blink_VideoProfile_1280_720P_2    = 62,
    /**
     *分辨率:1920x1080,  帧率:15
     */
    Blink_VideoProfile_1920_1080P      = 70,
    /**
     *分辨率:1920x1080,  帧率:24
     */
    Blink_VideoProfile_1920_1080P_1    = 71,
    /**
     *分辨率:1920x1080,  帧率:30
     */
    Blink_VideoProfile_1920_1080P_2    = 72
};

/**
 *远端/本地视频显示类型
 */
typedef NS_ENUM(NSInteger, BlinkVideoViewDisplayType)
{
    /**
     *在自定义frame中全屏显示视频, 可能会切掉两边超出原视频比例的视频
     */
    Blink_VideoViewDisplay_FullScreen,
    /**
     *在自定义frame中显示全部视频, 如果自定义CGSize与原比例不同会显示黑边
     */
    Blink_VideoViewDisplay_CompleteView
};

typedef NS_ENUM(NSInteger, BlinkConnectionState)
{
    /**
     *系统连接状态, 已连接
     */
    Blink_ConnectionState_Connected,
    /**
     *系统连接状态, 已断开
     */
    Blink_ConnectionState_Disconnected
};

typedef NS_ENUM(NSInteger, BlinkScreenSharingState)
{
    /**
     *屏幕共享关闭
     */
    Blink_ScreenSharing_Off = 0,
    /**
     *屏幕共享打开
     */
    Blink_ScreenSharing_On = 1
};

typedef NS_ENUM(NSInteger, BlinkUserType)
{
    /**
     *正常音视频用户
     */
    Blink_User_Normal = 1,
    /**
     *观察者用户
     */
    Blink_User_Observer = 2,
    /**
     *主持人
     */
    Blink_User_Host = 3
};

typedef NS_ENUM(NSInteger, BlinkAudioVideoType)
{
    /**
     *关闭视频, 仅音频
     */
    Blink_User_Only_Audio = 0,
    /**
     *打开音频+视频, 音频+视频
     */
    Blink_User_Audio_Video = 1,
    /**
     *关闭音频, 仅视频
     */
    Blink_User_Only_Video = 2,
    /**
     *关闭音频+视频, 无
     */
    Blink_User_Audio_Video_None = 3
};

typedef NS_ENUM(NSInteger, Blink_Authority_Type)
{
    /**
     *观察者请求变更为正常用户发言
     */
    Blink_Authority_Normal = 1,
    /**
     *正常用户成为主持人
     */
    Blink_Authority_Host = 2,
    /**
     *获取邀请连接
     */
    Blink_Authority_Invite = 3
};

typedef NS_ENUM(NSInteger, Blink_Capability_Type)
{
    /**
     *将正常用户降级为观察者
     */
    Blink_Capability_Degrade = 1,
    /**
     *邀请观察者发言,将观察升级为正常用户
     */
    Blink_Capability_Upgrade = 2,
    /**
     *移除与会人员
     */
    Blink_Capability_Remove = 3
};

typedef NS_ENUM(NSInteger, Blink_Device_Type)
{
    /**
     *无
     */
    Blink_Device_None = 0,
    /**
     *摄像头
     */
    Blink_Device_Camera = 1,
    /**
     *麦克风
     */
    Blink_Device_Micphone = 2,
    /**
     *摄像头+麦克风
     */
    Blink_Device_CameraMicphone = 3
};

typedef NS_ENUM(NSInteger, Blink_Answer_Type)
{
    /**
     *邀请观察者发言
     */
    Blink_Answer_Upgrade = 1,
    /**
     *观察者主动要求发言
     */
    Blink_Answer_Normal = 2,
    /**
     *邀请打开设备 Blink_Device_Type
     */
    Blink_Answer_InviteOpen = 3,
    /**
     *将正常用户降级为观察者
     */
    Blink_Answer_Degrade = 4,
    /**
     *邀请关闭设备 Blink_Device_Type
     */
    Blink_Answer_InviteClose = 5
};

typedef NS_ENUM(NSInteger, Blink_Accept_Type)
{
    /**
     *同意
     */
    Blink_Accept_YES = 1,
    /**
     *拒绝
     */
    Blink_Accept_NO = 2,
    /**
     *忙碌
     */
    Blink_Accept_Busy = 4
};

@class BlinkEngine;

/**
 *BlinkEngineDelegate 定义
 */
@protocol BlinkEngineDelegate <NSObject>

@optional
#pragma mark - 用户操作
/*!
 @method
 @abstract 系统连接状态回调方法. 初始化成功后, 通过此方法返回Blink_ConnectionState_Connected. 如果出现断开连接情况还会返回Blink_ConnectionState_Disconnected, 重连成功后返回Blink_ConnectionState_Connected, 以正确反应系统连接状态. 如果连接一直不成功会不停的尝试连接直至成功.
 @param state 系统连接状态
 */
- (void)blinkEngine:(BlinkEngine *)engine onConnectionStateChanged:(BlinkConnectionState)state;

/*!
 @method
 @abstract 调用加入聊天室joinChannel:方法后, 通过此方法返回加入状态
 @param success Yes:加入成功  NO:加入失败
 */
- (void)blinkEngine:(BlinkEngine *)engine onJoinComplete:(BOOL)success;

/*!
 @method
 @abstract 调用leaveChannel方法自己离开聊天室后, 通过此方法返回离开状态
 @param success Yes:离开成功  NO:离开失败
 */
- (void)blinkEngine:(BlinkEngine *)engine onLeaveComplete:(BOOL)success;

/*!
 @method
 @abstract 自己已在聊天室中, 其他用户加入聊天室时, 有用户A进入
 @param userId 新加入用户ID
 @param userName 用户名
 @param type 用户类型
 @param avType 0关闭视频仅有音频 1视频和音频
 */
- (void)blinkEngine:(BlinkEngine *)engine onUserJoined:(NSString *)userId userName:(NSString *)userName  userType:(BlinkUserType)type audioVideoType:(BlinkAudioVideoType)avType screenSharingStatus:(BlinkScreenSharingState)screenSharingStatus;

/*!
 @method
 @abstract 自己已在聊天室中, 其他用户加入聊天室时, 用户A的视频流已添加的回调, 在此之后可调用createRemoteVideoViewFrame:forUser:withDisplayType:
 @param userId 新加入用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine OnNotifyUserVideoCreated:(NSString *)userId;

/*!
 @method
 @abstract 自己已在聊天室中, 其他用户离开时, 通过userId可知是哪个用户已离开, 据此移除该用户视频
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onUserLeft:(NSString *)userId;

/*!
 @method
 @abstract 自己已在聊天室中, 其他用户修改音视频类型后, 通过userId可知是哪个用户打开/关闭视频, 据此处理视频是否显示
 @param userId 用户ID
 @param avType 0关闭视频仅有音频 1视频和音频
 */
- (void)blinkEngine:(BlinkEngine *)engine onUser:(NSString *)userId audioVideoType:(BlinkAudioVideoType)avType;

/*!
 @method
 @abstract 自己已在聊天室中且聊天室中至少还有一个远程用户, - (void)requestWhiteBoardURL 请求白板页面的HTTP URL之后的回调
 @param url Web白板连接
 */
- (void)blinkEngine:(BlinkEngine *)engine onWhiteBoardURL:(NSString *)url;

/*!
 @method
 @abstract 自己已在聊天室中查询该房间内是否已经创建白板, - (void)requestWhiteBoardExist 之后的回调
 @param isExist YES:存在 NO:不存在
 */
- (void)blinkEngine:(BlinkEngine *)engine onWhiteBoardExist:(BOOL)isExist;

/*!
 @method
 @abstract 自己已在聊天室中, 其他人创建白板后收到的回调
 @param userId 创建白板的用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyWhiteBoardCreateBy:(NSString *)userId;

/*!
 @method
 @abstract 自己本地调用 controlAudioVideoDevice:open: 后, 自己收到的信令发送成功与否的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onControlAudioVideoDevice:(NSInteger)code;

/*!
 @method
 @abstract 某与会人调用  - (NSInteger)controlAudioVideoDevice:(Blink_Device_Type)type open:(BOOL)isOpen  打开/关闭指定设备类型后, 其他与会人员收到的回调
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyControlAudioVideoDevice:(Blink_Device_Type)type withUserID:(NSString *)userId open:(BOOL)isOpen;

#pragma mark - Meeting
/*!
 @method
 @abstract 观察请求升级成正常用户后, 观察者收到的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onObserverRequestBecomeNormalUser:(NSInteger)code;

/*!
 @method
 @abstract 已在房间中的用户, 调用 - (void)inviteUser 方法后的回调, 以反馈信令是否发送成功
 @param url 邀请连接
 */
- (void)blinkEngine:(BlinkEngine *)engine onGetInviteURL:(NSString *)url responseCode:(NSInteger)code;

/*!
 @method
 @abstract 正常用户, 调用 - (NSInteger)normalUserRequestHostAuthority 方法后的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onNormalUserRequestHostAuthority:(NSInteger)code;

/*!
 @method
 @abstract 某正常用户成为主持人后, 其他与会人员收到的回调
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyNormalUserRequestHostAuthority:(NSString *)userId;

/*!
 @method
 @abstract 主持人调用 - (NSInteger)degradeNormalUserToObserver:(NSString *)userID 后, 主持人收到的信令发送成功与否的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onDegradeNormalUserToObserver:(NSInteger)code;

/*!
 @method
 @abstract 自己已在聊天室中, 自己或其他用户被降级为观察者时, 通过userId可知是哪个用户已被降级, 据此处理该用户
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyDegradeNormalUserToObserver:(NSString *)userId;

/*!
 @method
 @abstract 主持人调用 - (NSInteger)upgradeObserverToNormalUser:(NSString *)userID 后, 主持人收到的信令发送成功与否的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onUpgradeObserverToNormalUser:(NSInteger)code;

/*!
 @method
 @abstract 自己是观察者且已在聊天室中, 主持人邀请自己升级成为正常用户时的回调, 在此回调中需要给出应答, 即:调用 - (NSInteger)answerHostControlUserDevice:(NSString *)userID withDeviceType:(Blink_Device_Type)dType status:(BOOL)isAccept
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyUpgradeObserverToNormalUser:(NSString *)userId;

/*!
 @method
 @abstract 主持人调用 - (void)removeUser:(NSString *)userID 后, 主持人收到的信令发送成功与否的回调, 以反馈信令是否发送成功
 */
- (void)blinkEngine:(BlinkEngine *)engine onRemoveUser:(NSInteger)code;

/*!
 @method
 @abstract 自己已在聊天室中, 主持人将自己移出会议室时收到此回调
 @param userId 离开用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyRemoveUser:(NSString *)userId;

/*!
 @method
 @abstract 自己已在聊天室中, 其他用户打开/关闭屏幕共享
 @param userId 打开/关闭屏幕共享的用户ID
 @param isOpen Yes:打开  NO:关闭
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyScreenSharing:(NSString *)userId open:(BOOL)isOpen;

/*!
 @method
 @abstract 观察者用户请求主持人成为正常用户后, 主持人收到的回调
 @param userId 用户ID
 @param type 授权类型
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyObserverRequestBecomeNormalUser:(NSString *)userId authorityType:(Blink_Authority_Type)type;

/*!
 @method
 @abstract 所有与会人员收到的, 某正常用户打开或关闭麦克风/摄像头的回调
 @param userId 用户ID
 @param hostId 主持人ID
 @param dType 操作的设备类型
 @param isOpen 是否打开
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyHostControlUserDevice:(NSString *)userId host:(NSString *)hostId deviceType:(Blink_Device_Type)dType open:(BOOL)isOpen;

/*!
 @method
 @abstract 主持人调用 - (NSInteger)hostControlUserDevice:(NSString *)userID withDeviceType:(Blink_Device_Type)dType status:(BOOL)isOpen 后收到, 将某正常用户打开或关闭指定设备的成功的回调, 以反馈信令是否发送成功
 @param userId 用户ID
 @param dType 操作的设备类型
 */
- (void)blinkEngine:(BlinkEngine *)engine onHostControlUserDevice:(NSString *)userId withDeviceType:(Blink_Device_Type)dType responseCode:(NSInteger)code;

/*!
 @method
 @abstract 主持人邀请观察者升级成正常用户, 观察者做出接受/拒绝之后, 给主持人的回调
 @param userId 用户ID
 @param isAccept 是否接受
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerUpgradeObserverToNormalUser:(NSString *)userId status:(BOOL)isAccept;

/*!
 @method
 @abstract 观察者向主持人请求成为正常用户, 主持人做出接受/拒绝之后之后, 给观察者的回调
 @param userId 用户ID
 @param acceptType 是否接受
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerObserverRequestBecomeNormalUser:(NSString *)userId status:(Blink_Accept_Type)acceptType;

/*!
 @method
 @abstract 主持人打开/关闭与会某正常用户的麦克风/摄像头, 某正常用户做出接受/拒绝之后之后, 给主持人的回调
 @param userId 用户ID
 @param dType 设备类型
 @param isAccept 是否接受
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerHostControlUserDevice:(NSString *)userId withAnswerType:(Blink_Answer_Type)type withDeviceType:(Blink_Device_Type)dType status:(BOOL)isAccept;
/*!
 @method
 @abstract 主持人将正常用户降级为观察者, 正常用户做出接受/拒绝之后, 给除该用户以外其他与会人的回调
 @param userId 用户ID
 @param isAccept 是否接受
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyAnswerDegradeNormalUserToObserver:(NSString *)userId status:(BOOL)isAccept;

#pragma mark - AudioVideo
/*!
 @method
 @abstract 所有设备完成准备,UI中可进行状态设置
 */
- (void)blinkEngineOnAudioDeviceReady:(BlinkEngine *)engine;

/*!
 @method
 @abstract 耳机插入/拨出时, 回调此方法
 @param enable Yes:扬声器打开  NO:扬声器关闭
 */
- (void)blinkEngine:(BlinkEngine *)engine onOutputAudioPortSpeaker:(BOOL)enable;

/*!
 @method
 @abstract 探测麦克风/相机权限后, 返回的麦克风/相机权限信息
 @param enableAudio Yes:已打开权限  NO:已关闭权限
 @param enableVideo Yes:已打开权限  NO:已关闭权限
 */
- (void)blinkEngine:(BlinkEngine *)engine onAudioAuthority:(BOOL)enableAudio onVideoAuthority:(BOOL)enableVideo;

/*!
 @method
 @abstract 返回userId用户videoView及其分辨率. 当videoView分辨率发生多次变化时, 此方法会被多次调用.
 @param videoView 远端用户视频View
 @param size 远端用户的视频分辨率,例如:640*480
 @param userId 用户ID
 */
- (void)blinkEngine:(BlinkEngine *)engine onRemoteVideoView:(UIView *)videoView vidoeSize:(CGSize)size remoteUserID:(NSString*)userId;

/*!
 @method
 @abstract 自定义GPU滤镜,将参数中的buffer进行处理后return. 
           需要自定义滤镜时, 需要在setVideoParameters方法中将kGPUFilter设置为YES, 并且实现此delegate方法.
           如果仅将kGPUFilter设置为YES而不实现此方法,则使用默认滤镜.
 @param buffer GPU滤镜buffer
 */
- (CMSampleBufferRef)blinkEngine:(BlinkEngine *)engine onGPUFilterSource:(CMSampleBufferRef)buffer;

/*!
 @method
 @abstract 当丢包率大于等于所设置的值时,通过此方法回调,并返回此次丢包率
 @param lost 取值范围0~100, 代表丢包率0%~100%
 */
- (void)blinkEngine:(BlinkEngine *)engine onNetworkSentLost:(NSInteger)lost;

/*!
 @method
 @abstract 当丢包率大于等于所设置的值时,通过此方法回调,并返回此次丢包率
 @param lost 取值范围0~100, 代表丢包率0%~100%
 */
- (void)blinkEngine:(BlinkEngine *)engine onNetworkReceiveLost:(NSInteger)lost;

/*!
 @method
 @abstract 传递本地和远端的声音大小, 取值: 0-9
 @param levelArray 保存NSDictionary, 包括自己的音量
 */
- (void)blinkEngine:(BlinkEngine *)engine onNotifyUserAudioLevel:(NSArray *)levelArray;

@end


__attribute__((visibility("default"))) @interface BlinkEngine : NSObject

/*!
 @property delegate
 @abstract BlinkEgnine delegate
 */
@property (nonatomic, weak) id<BlinkEngineDelegate> delegate;

/*!
 @property isExecuteDelegateInMainQueue 是否在主线程中运行回调的delegate方法
 @abstract delegate方法是否在Main Queue中进行回调
 */
@property (nonatomic, assign) BOOL isExecuteDelegateInMainQueue;

/*!
 @property engineTLSCertificateData 在JoinChannel之前设置本地证书NSData,需要使用TLS加密时设置,默认为nil,不使用TLS
 */
@property (nonatomic, strong) NSData *engineTLSCertificateData;

/*!
 @property isSendLostReport 设置网络丢包率是否上报,当设置为Yes时通过 blinkEngine:onNetworkSentLost: 回调方法通知丢包值,取值范围0~100, 代表丢包率0%~100%
 @abstract Yes:上报 NO:不上报 默认值:NO
 */
@property (nonatomic, assign) BOOL isSendLostReport;


/*!
 @property isReceiveLostReport 设置网络接收丢包率是否上报,当设置为Yes时通过 blinkEngine:onNetworkReceiveLost: 回调方法通知丢包值,取值范围0~100, 代表丢包率0%~100%
 @abstract Yes:上报 NO:不上报 默认值:NO
 */
@property (nonatomic, assign) BOOL isReceiveLostReport;

/*!
 @method
 @abstract 初始化方法, serverURL: cmp.blinkcloud.cn:80 私有云可自定义. 此初始化方法不会进行探测流程
 @param serverURL 导航配置服务器URL
 */
- (instancetype)initEngine:(NSString *)serverURL;

/*!
 @method
 @abstract BlinkEngine单例, 不可用做BlinkEngine的初始化, 仅用来初始化之后获取BlinkEngine对象
 */
+ (BlinkEngine *)sharedBlinkEngine;

/*!
 @method
 @abstract 返回当前SDK版本号
 */
+ (NSString *)sdkVersion;

/*!
 @method
 @abstract 必须在调用joinChannel:前设置本地视频参数才能生效, 不设置则使用默认值
 @param parameters  kAudioOnly:    是否为纯音频, 默认值为NO
                    kVideoProfile: 本地视频分辨率, 默认值为Blink_VideoProfile_480P
                    kMaxBandWidth: 最大码率, 默认值为600
                    kUserType:     用户类型, 默认值为Blink_User_Normal
                    kCloseCamera:  是否关闭视频显示, 默认值为1,不关闭视频
                    kGPUFilter:    是否打开滤镜, 默认为NO,不使用滤镜
 */
- (void)setVideoParameters:(NSDictionary *)parameters;

/*!
 @method
 @abstract joinChannel调用之后此方法, 可确定以正常用户加入后, 是否为当前房间主持人
 @return 用户类型
 */
- (BlinkUserType)getUserType;

/*!
 @method
 @abstract 加入聊天室
 @param channel 不同聊天室的唯一标识
 @param token 通过HTTP的POST方式查询回来的字符串
 @param userID 用户ID
 */
- (void)joinChannel:(NSString*)channel withKeyToken:(NSString *)token withUserID:(NSString *)userID withUserName:(NSString *)userName;

/*!
 @method
 @abstract 单独发送JoinChannel消息
 @param userID 用户ID
 */
- (void)sendJoinChannelMessage:(NSString *)userID;

/*!
 @method
 @abstract 单独发送JoinChannel消息
 @param userID 用户标识唯一ID
 @param channel 不同聊天室的唯一标识
 */
- (void)sendJoinChannelMessage:(NSString *)userID withChannel:(NSString *)channel;

/*!
 @method
 @abstract 离开当前聊天室
 */
- (void)leaveChannel;

/*!
 @method
 @abstract joinChannel之后修改本地发送视频的分辨率
 @param videoProfile 视频分辨率
 */
- (void)changeVideoSize:(BlinkVideoProfile)videoProfile;

/*!
 @method
 @abstract 加入房间前或加入房间后, 设置是否打开默认美颜
 @param isFilter YES:打开 NO:关闭
 */
- (void)setUseDefaultGPUFilter:(BOOL)isFilter;

/*!
 @method
 @abstract 请求白板页面HTTP URL, 自己已在聊天室中且聊天室中至少还有一个远程用户, 在请求之后会异步通过delegate中的blinkEngine: onWhiteBoardURL:方法返回白板页面的URL
 */
- (void)requestWhiteBoardURL;

/*!
 @method
 @abstract 请求白板页面是否存在, 在请求之后会异步通过delegate中的blinkEngine: onWhiteBoardExist:方法返回是否存在
 */
- (void)requestWhiteBoardExist;

/*!
 @method
 @abstract 根据自定义frame和视频的显示类型, 创建本地视频View
 @param frame 自定义本地视频的frame  type:本地视频显示类型
 @param type 本地视频显示类型
 */
- (UIView *)createLocalVideoViewFrame:(CGRect)frame withDisplayType:(BlinkVideoViewDisplayType)type;

/*!
 @method
 @abstract 根据userId确定某个远端用户, 用自定义frame和视频的显示类型type, 创建远端视频View
 @param frame 自定义本地视频的frame
 @param userId 某个远端用户
 @param type 本地视频显示类型
 */
- (UIView *)createRemoteVideoViewFrame:(CGRect)frame forUser:(NSString *)userId withDisplayType:(BlinkVideoViewDisplayType)type;

/*!
 @method
 @abstract 根据所选BlinkVideoViewDisplayType, 重新设置本地视频, 需要变换本地视频View frame时使用
 @param frame 自定义本地视频的frame
 @param type 本地视频显示类型
 */
- (UIView *)changeLocalVideoViewFrame:(CGRect)frame withDisplayType:(BlinkVideoViewDisplayType)type;

/*!
 @method
 @abstract 根据所选BlinkVideoViewDisplayType, 重新设置远端视频, 需要变换远端视频View frame时使用
 @param frame 自定义远端视频的frame
 @param userId 需要修改frame的视频的用户userId
 @param type 远端视频显示类型
 */
- (UIView *)changeRemoteVideoViewFrame:(CGRect)frame withUserID:(NSString *)userId withDisplayType:(BlinkVideoViewDisplayType)type;

#pragma mark - Meeting
/*!
 @method
 @abstract 观察者调用, 请求发言(需要主持人应答)
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)observerRequestBecomeNormalUser;

/*!
 @method
 @abstract 任何与会人员调用, 已在房间里的用户获取邀请链接
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)getInviteURL;

/*!
 @method
 @abstract 与会正常用户调用, 请求获取主持人权限
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)normalUserRequestHostAuthority;

/*!
 @method
 @abstract 主持人调用发起, 将正常用户降级为观察者
 @param userID 用户标识唯一ID
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)degradeNormalUserToObserver:(NSString *)userID;

/*!
 @method
 @abstract 主持人调用发起, 将观察者升级为正常用户(需要被操作的观察者应答)
 @param userID 用户标识唯一ID
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)upgradeObserverToNormalUser:(NSString *)userID;

/*!
 @method
 @abstract 主持人调用, 移除与会人员
 @param userID 用户标识唯一ID
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)removeUser:(NSString *)userID;

/*!
 @method
 @abstract 主持人调用, 操作与会人员麦克风/摄像头的打开/关闭, 需要被操作人通过 - (NSInteger)answerHostControlUserDevice:(NSString *)userID withDeviceType:(Blink_Device_Type)dType open:(BOOL)isOpen status:(BOOL)isAccept; 给出应答
 @param userID 用户标识唯一ID
 @param type 设备类型
 @param isOpen 是否打开
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)hostControlUserDevice:(NSString *)userID withDeviceType:(Blink_Device_Type)type open:(BOOL)isOpen;

/*!
 @method
 @abstract 主持人邀请观察者升级成正常用户时, 观察者的应答调用
 @param userID 用户标识唯一ID
 @param isAccept 是否接受
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)answerUpgradeObserverToNormalUser:(NSString *)userID status:(BOOL)isAccept;

/*!
 @method
 @abstract 观察者向主持人申请升级成正常用户时, 主持人的应答调用
 @param userID 用户标识唯一ID
 @param isAccept 是否接受
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)answerObserverRequestBecomeNormalUser:(NSString *)userID status:(Blink_Accept_Type)isAccept;

/*!
 @method
 @abstract 麦克风/摄像头被主持人打开/关闭时, 被打开/关闭人的应答调用
 @param userID 用户标识唯一ID
 @param dType 设备类型
 @param isAccept 是否接受
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)answerHostControlUserDevice:(NSString *)userID withDeviceType:(Blink_Device_Type)dType open:(BOOL)isOpen status:(BOOL)isAccept;

/*!
 @method
 @abstract 主持人将正常用户降级为观察者时, 观察者的应答调用
 @param userID 用户标识唯一ID
 @param isAccept 是否接受
 @return 0:成功 1:参数错误 2:状态错误
 */
- (NSInteger)answerDegradeNormalUserToObserver:(NSString *)userID status:(BOOL)isAccept;

#pragma mark - UI切换操作
/*!
 @method
 @abstract 切换前后摄像头
 */
- (void)switchCamera;

/*!
 @method
 @abstract 打开/关闭本地视频,UI操作并通过代理 blinkEngine:onUser:audioVideoType: 通知其他用户视频已关闭
 @param enable Yes:关闭本地视频  NO:打开本地视频
 */
- (void)closeLocalVideo:(BOOL)enable;

- (void)subscribeStreamForTiny:(NSArray *)tinyStreamUserIDs forOrigin:(NSString *)originStreamUserID;

- (void)setVideoSizeForTinyStream:(CGFloat)width height:(CGFloat) height;

/*!
 @method
 @abstract 打开/关闭本地视频,通过信令通知服务端.
 @param avType Blink_User_Only_Audio:关闭本地视频,仅音频  Blink_User_Audio_Video:打开本地视频
 */
- (void)modifyAudioVideoType:(BlinkAudioVideoType)avType;

/*!
 @method
 @abstract 打开/关闭本地音频/视频, 通过信令通知服务端.
 @param type 操作的音视频设备类型
 @param isOpen YES:打开 NO:关闭
 */
- (NSInteger)controlAudioVideoDevice:(Blink_Device_Type)type open:(BOOL)isOpen;

/*!
 @method
 @abstract 打开/关闭外放声音
 @param enable Yes:开启声音  NO:关闭声音
 */
- (void)switchSpeaker:(BOOL)enable;

/*!
 @method
 @abstract 打开/关闭麦克风
 @param enable Yes:静音,麦克风不收录声音  NO:不静音,麦克风可以收录声音
 */
- (void)muteMicrophone:(BOOL)enable;

#pragma mark - 录制
/*!
 @method
 @abstract 开始录制
 @param filePath 录制文件保存路径
 */
- (NSInteger)startRecording:(NSString *)filePath;

/*!
 @method
 @abstract 停止录制
 */
- (NSInteger)stopRecording;

#pragma mark - 日志
/*!
 @method
 @abstract 设置Blink日志文件位置, 不需要指定文件名, 只能在[BlinkEngine alloc]之前设置才能生效
 @param path 沙盒路径
 */
+ (void)setBlinkLogPath:(NSString *)path;

@end
