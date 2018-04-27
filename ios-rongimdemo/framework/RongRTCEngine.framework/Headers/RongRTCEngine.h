//
//  RongRTCEngine.h
//  RongRTCEngine
//
//  Created by Tao Li on 2016/11/17.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView VIEW_CLASS;

#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView VIEW_CLASS;

#endif

typedef NS_ENUM(NSInteger, RongRtcWarningCode) {
  RongRtc_Warn_Pending = 20,
  RongRtc_Warn_NoAvailableChannel = 103,
  RongRtc_Warn_LookupChannelTimeout = 104,
  RongRtc_Warn_LookupChannelRejected = 105,
  RongRtc_Warn_OpenChannelTimeout = 106,
  RongRtc_Warn_OpenChannelRejected = 107,
  RongRtc_Warn_Adm_RuntimePlayoutWarning = 1014,
  RongRtc_Warn_Adm_RuntimeRecordingWarning = 1016,
  RongRtc_Warn_Adm_RecordAudioSilence = 1019,
  RongRtc_Warn_Adm_PlaybackMalfunction = 1020,
  RongRtc_Warn_Adm_RecordMalfunction = 1021,
  RongRtc_Warn_Adm_Interruption = 1025,
  RongRtc_Warn_Adm_RouteChange = 1026,
  RongRtc_Warn_Apm_Howling = 1051,
};


typedef NS_ENUM(NSInteger, RongRtcErrorCode) {
  RongRtc_Error_NoError = 0,
  RongRtc_Error_Failed = 1,
  RongRtc_Error_InvalidArgument = 2,
  RongRtc_Error_NotReady = 3,
  RongRtc_Error_NotSupported = 4,
  RongRtc_Error_Refused = 5,
  RongRtc_Error_BufferTooSmall = 6,
  RongRtc_Error_NotInitialized = 7,
  RongRtc_Error_InvalidView = 8,
  RongRtc_Error_NoPermission = 9,
  RongRtc_Error_TimedOut = 10,
  RongRtc_Error_Canceled = 11,
  RongRtc_Error_TooOften = 12,
  RongRtc_Error_BindSocket = 13,
  RongRtc_Error_NetDown = 14,
  RongRtc_Error_NoBufs = 15,
  RongRtc_Error_InitVideo = 16,
  RongRtc_Error_JoinChannelRejected = 17,
  RongRtc_Error_LeaveChannelRejected = 18,
  RongRtc_Error_AlreadyInUse = 19,
  
  RongRtc_Error_InvalidAppId = 101,
  RongRtc_Error_InvalidChannelName = 102,
  RongRtc_Error_ChannelKeyExpired = 109,
  RongRtc_Error_InvalidChannelKey = 110,
  RongRtc_Error_ConnectionInterrupted = 111, // only used in web sdk
  RongRtc_Error_ConnectionLost = 112, // only used in web sdk
  RongRtc_Error_NotInChannel = 113,
  RongRtc_Error_SizeTooLarge = 114,
  RongRtc_Error_BitrateLimit = 115,
  RongRtc_Error_TooManyDataStreams = 116,
  RongRtc_Error_DecryptionFailed = 120,
  
  RongRtc_Error_LoadMediaEngine = 1001,
  RongRtc_Error_StartCall = 1002,
  RongRtc_Error_StartCamera = 1003,
  RongRtc_Error_StartVideoRender = 1004,
  RongRtc_Error_Adm_GeneralError = 1005,
  RongRtc_Error_Adm_JavaResource = 1006,
  RongRtc_Error_Adm_SampleRate = 1007,
  RongRtc_Error_Adm_InitPlayout = 1008,
  RongRtc_Error_Adm_StartPlayout = 1009,
  RongRtc_Error_Adm_StopPlayout = 1010,
  RongRtc_Error_Adm_InitRecording = 1011,
  RongRtc_Error_Adm_StartRecording = 1012,
  RongRtc_Error_Adm_StopRecording = 1013,
  RongRtc_Error_Adm_RuntimePlayoutError = 1015,
  RongRtc_Error_Adm_RuntimeRecordingError = 1017,
  RongRtc_Error_Adm_RecordAudioFailed = 1018,
  RongRtc_Error_Adm_Play_Abnormal_Frequency = 1020,
  RongRtc_Error_Adm_Record_Abnormal_Frequency = 1021,
  RongRtc_Error_Adm_Init_Loopback  = 1022,
  RongRtc_Error_Adm_Start_Loopback = 1023,
  RongRtc_Error_Vdm_Camera_Not_Authorized = 1501,
  // 1025, as warning for interruption of adm on ios
  // 1026, as warning for route change of adm on ios
};

typedef NS_ENUM(NSInteger, RongRtcChannelProfile) {
  RongRtc_ChannelProfile_Free = 0,
  RongRtc_ChannelProfile_Broadcaster = 1,
  RongRtc_ChannelProfile_Audience = 2,
};

typedef NS_ENUM(NSInteger, RongRtcVideoProfile) {
  // res       fps  kbps
  RongRtc_VideoProfile_Invalid = -1,
  RongRtc_VideoProfile_120P = 0,         // 160x120   15   65
#if TARGET_OS_IPHONE
  RongRtc_VideoProfile_120P_3 = 2,		// 120x120   15   50
  RongRtc_VideoProfile_180P = 10,		// 320x180   15   140
  RongRtc_VideoProfile_180P_3 = 12,		// 180x180   15   100
  RongRtc_VideoProfile_180P_4 = 13,		// 240x180   15   120
#endif
  RongRtc_VideoProfile_240P = 20,		// 320x240   15   200
#if TARGET_OS_IPHONE
  RongRtc_VideoProfile_240P_3 = 22,		// 240x240   15   140
  RongRtc_VideoProfile_240P_4 = 23,		// 424x240   15   220
#endif
  RongRtc_VideoProfile_360P = 30,		// 640x360   15   400
#if TARGET_OS_IPHONE
  RongRtc_VideoProfile_360P_3 = 32,		// 360x360   15   260
#endif
  RongRtc_VideoProfile_360P_4 = 33,		// 640x360   30   600
  RongRtc_VideoProfile_360P_6 = 35,		// 360x360   30   400
  RongRtc_VideoProfile_360P_7 = 36,		// 480x360   15   320
  RongRtc_VideoProfile_360P_8 = 37,		// 480x360   30   490
  RongRtc_VideoProfile_480P = 40,		// 640x480   15   500
#if TARGET_OS_IPHONE
  RongRtc_VideoProfile_480P_3 = 42,		// 480x480   15   400
#endif
  RongRtc_VideoProfile_480P_4 = 43,		// 640x480   30   750
  RongRtc_VideoProfile_480P_6 = 45,		// 480x480   30   600
  RongRtc_VideoProfile_480P_8 = 47,		// 848x480   15   610
  RongRtc_VideoProfile_480P_9 = 48,		// 848x480   30   930
  RongRtc_VideoProfile_720P = 50,		// 1280x720  15   1130
  RongRtc_VideoProfile_720P_3 = 52,		// 1280x720  30   1710
  RongRtc_VideoProfile_720P_5 = 54,		// 960x720   15   910
  RongRtc_VideoProfile_720P_6 = 55,		// 960x720   30   1380
  RongRtc_VideoProfile_1080P = 60,		// 1920x1080 15   2080
  RongRtc_VideoProfile_1080P_3 = 62,		// 1920x1080 30   3150
  RongRtc_VideoProfile_1080P_5 = 64,		// 1920x1080 60   4780
  RongRtc_VideoProfile_1440P = 66,		// 2560x1440 30   4850
  RongRtc_VideoProfile_1440P_2 = 67,		// 2560x1440 60   7350
  RongRtc_VideoProfile_4K = 70,			// 3840x2160 30   8190
  RongRtc_VideoProfile_4K_3 = 72,		// 3840x2160 60   13500
  RongRtc_VideoProfile_DEFAULT = RongRtc_VideoProfile_360P,
};

typedef NS_ENUM(NSUInteger, RongRtcQuality) {
  RongRtc_Quality_Unknown = 0,
  RongRtc_Quality_Excellent = 1,
  RongRtc_Quality_Good = 2,
  RongRtc_Quality_Poor = 3,
  RongRtc_Quality_Bad = 4,
  RongRtc_Quality_VBad = 5,
  RongRtc_Quality_Down = 6,
};

typedef NS_ENUM(NSUInteger, RongRtcUserOfflineReason) {
  RongRtc_UserOffline_Quit = 0,
  RongRtc_UserOffline_Dropped = 1,
};

typedef NS_ENUM(NSUInteger, RongRtcLogFilter) {
  RongRtc_LogFilter_Console = 0x08000,
  RongRtc_LogFilter_Debug = 0x0800,
  RongRtc_LogFilter_Info = 0x0001,
  RongRtc_LogFilter_Warn = 0x0002,
  RongRtc_LogFilter_Error = 0x0004,
  RongRtc_LogFilter_Critical = 0x0008,
};


typedef NS_ENUM(NSUInteger, RongRtcRenderMode) {
  /**
   Hidden(1): If the video size is different than that of the display window, crops the borders of the video (if the video is bigger) or stretch the video (if the video is smaller) to fit it in the window.
   */
  RongRtc_Render_Hidden = 1,
  
  /**
   RongRtc_Render_Fit(2): If the video size is different than that of the display window, resizes the video proportionally to fit the window.
   */
  RongRtc_Render_Fit = 2,
  
  /**
   RongRtc_Render_Adaptive(3)：If both callers use the same screen orientation, i.e., both use vertical screens or both use horizontal screens, the RongRtc_Render_Hidden mode applies; if they use different screen orientations, i.e., one vertical and one horizontal, the RongRtc_Render_Fit mode applies.
   */
  RongRtc_Render_Adaptive = 3,
};

typedef NS_ENUM(NSUInteger, RongRtcQualityReportFormat) {
  RongRtc_QualityReportFormat_Json = 0,
  RongRtc_QualityReportFormat_Html = 1,
};

#if (!(TARGET_OS_IPHONE) && (TARGET_OS_MAC))

typedef NS_ENUM(NSInteger, RongRtcDeviceType) {
  RongRtc_DeviceType_Audio_Unknown = -1,
  RongRtc_DeviceType_Audio_Recording = 0,
  RongRtc_DeviceType_Audio_Playout = 1,
  RongRtc_DeviceType_Video_Render = 2,
  RongRtc_DeviceType_Video_Capture = 3,
};

__attribute__((visibility("default"))) @interface RongRtcDeviceInfo : NSObject

@property (assign, nonatomic) int index;
@property (assign, nonatomic) RongRtcDeviceType type; // 0: recording, 1: playback, 2: capture
@property (copy, nonatomic) NSString* deviceId; //
@property (copy, nonatomic) NSString* deviceName; //
@end

#endif


__attribute__((visibility("default"))) @interface RongRtcVideoCanvas : NSObject

/**
 *  The video display view. The SDK does not maintain the lifecycle of the view.
 The view can be safely released after calling leaveChannel with a returned value.
 The SDK keeps a cache of the view value, so 'setupLocalVideo' to set the view value to NULL could be able to clear cache before switching or releasing view.
 */
@property (strong, nonatomic) VIEW_CLASS* view;
@property (assign, nonatomic) RongRtcRenderMode renderMode; // the render mode of view: hidden, fit and adaptive
@property (copy, nonatomic) NSString *userId; // the user id of view
@end


__attribute__((visibility("default"))) @interface RongRtcStats : NSObject
@property (assign, nonatomic) NSUInteger duration;
@property (assign, nonatomic) NSUInteger txBytes;
@property (assign, nonatomic) NSUInteger rxBytes;
@property(assign, nonatomic) NSUInteger users;
@end

__attribute__((visibility("default"))) @interface RongRtcLocalVideoStats : NSObject
@property (assign, nonatomic) NSUInteger sentBitrate;
@property (assign, nonatomic) NSUInteger sentFrameRate;
@end

__attribute__((visibility("default"))) @interface RongRtcRemoteVideoStats : NSObject
@property (copy, nonatomic) NSString *userId;
@property (assign, nonatomic) NSUInteger delay;
@property (assign, nonatomic) NSUInteger width;
@property (assign, nonatomic) NSUInteger height;
@property (assign, nonatomic) NSUInteger receivedBitrate;
@property (assign, nonatomic) NSUInteger receivedFrameRate;
@end

__attribute__((visibility("default"))) @interface RongRtcAudioVolumeInfo : NSObject
@property (copy, nonatomic) NSString *userId;
@property (assign, nonatomic) NSUInteger volume;
@end






@class RongRTCEngine;
@protocol RongRTCEngineDelegate <NSObject>
@optional

/**
 *  The warning occurred in SDK. The APP could igonre the warning, and the SDK could try to resume automically.
 *
 *  @param engine      The engine kit
 *  @param warningCode The warning code
 */
- (void)rtcEngine:(RongRTCEngine *)engine didOccurWarning:(RongRtcWarningCode)warningCode;

/**
 *  The error occurred in SDK. The SDK couldn't resume to normal state, and the app need to handle it.
 *
 *  @param engine    The engine kit
 *  @param errorCode The error code
 */
- (void)rtcEngine:(RongRTCEngine *)engine didOccurError:(RongRtcErrorCode)errorCode;

/**
 *  The sdk reports the volume of a speaker. The interface is disable by default, and it could be enable by API "enableAudioVolumeIndication"
 *
 *  @param engine      The engine kit
 *  @param speakers    RongRtcAudioVolumeInfos array
 *  @param totalVolume The total volume of speakers
 */
- (void)rtcEngine:(RongRTCEngine *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray*)speakers totalVolume:(NSInteger)totalVolume;

/**
 *  Event of the first local frame starts rendering on the screen.
 *
 *  @param engine  The engine kit
 *  @param size    The size of local video stream
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)rtcEngine:(RongRTCEngine *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

/**
 *  Event of the first frame of remote user is decoded successfully.
 *
 *  @param engine  The engine kit
 *  @param userId     The remote user id
 *  @param size    The size of video stream
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)rtcEngine:(RongRTCEngine *)engine firstRemoteVideoDecodedOfUser:(NSString *)userId size:(CGSize)size elapsed:(NSInteger)elapsed;

/**
 *  Event of the first frame of remote user is rendering on the screen.
 *
 *  @param engine  The engine kit
 *  @param userId     The remote user id
 *  @param size    The size of video stream
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)rtcEngine:(RongRTCEngine *)engine firstRemoteVideoFrameOfUser:(NSString *)userId size:(CGSize)size elapsed:(NSInteger)elapsed;

/**
 *  Event of remote user joined
 *
 *  @param engine  The engine kit
 *  @param userId     The remote user id
 *  @param elapsed The elapsed time(ms) from the beginning of the session.
 */
- (void)rtcEngine:(RongRTCEngine *)engine didJoinedOfUser:(NSString *)userId elapsed:(NSInteger)elapsed;

/**
 *  Event of remote user offlined
 *
 *  @param engine The engine kit
 *  @param userId    The remote user id
 *  @param reason Reason of user offline, quit or drop
 */
- (void)rtcEngine:(RongRTCEngine *)engine didOfflineOfUser:(NSString *)userId reason:(RongRtcUserOfflineReason)reason;

/**
 *  Event of remote user audio muted or unmuted
 *
 *  @param engine The engine kit
 *  @param muted  Mute or unmute
 *  @param userId    The remote user id
 */
- (void)rtcEngine:(RongRTCEngine *)engine didAudioMuted:(BOOL)muted byUser:(NSString *)userId;

/**
 *  Event of remote user video muted or unmuted
 *
 *  @param engine The engine kit
 *  @param muted  Muted or unmuted
 *  @param userId    The remote user id
 */
- (void)rtcEngine:(RongRTCEngine *)engine didVideoMuted:(BOOL)muted byUser:(NSString *)userId;

/**
 *  Event of remote user video muted or unmuted
 *
 *  @param engine The engine kit
 *  @param enabled  enable or disable
 *  @param userId    The remote user id
 */
- (void)rtcEngine:(RongRTCEngine *)engine didVideoEnabled:(BOOL)enabled byUser:(NSString *)userId;

/**
 *  The statistics of remote video stream. Update every two seconds.
 *
 *  @param engine            The engine kit
 *  @param stats             The stats
 */
- (void)rtcEngine:(RongRTCEngine *)engine remoteVideoStats:(RongRtcRemoteVideoStats*)stats;

/**
 *  Event of camera opened
 *
 *  @param engine The engine kit
 */
- (void)rtcEngineCameraDidReady:(RongRTCEngine *)engine;

/**
 *  Event of camera stopped
 *
 *  @param engine The engine kit
 */
- (void)rtcEngineVideoDidStop:(RongRTCEngine *)engine;

/**
 *  Event of disconnected with server. This event is reported at the moment SDK loses connection with server.
 *  In the mean time SDK automatically tries to reconnect with the server until APP calls leaveChannel.
 *
 *  @param engine The engine kit
 */
- (void)rtcEngineConnectionDidInterrupted:(RongRTCEngine *)engine;

/**
 *  Event of loss connection with server. This event is reported after the connection is interrupted and exceed the retry period (10 seconds by default).
 *  In the mean time SDK automatically tries to reconnect with the server until APP calls leaveChannel.
 *
 *  @param engine The engine kit
 */
- (void)rtcEngineConnectionDidLost:(RongRTCEngine *)engine;

/**
 *  Event of the user joined the channel.
 *
 *  @param engine  The engine kit
 *  @param channel The channnel name
 *  @param userId     The remote user id
 *  @param elapsed The elapsed time (ms) from session beginning
 */
- (void)rtcEngine:(RongRTCEngine *)engine didJoinChannel:(NSString*)channel withUser:(NSString *)userId elapsed:(NSInteger) elapsed;

/**
 *  Event of the user rejoined the channel
 *
 *  @param engine  The engine kit
 *  @param channel The channel name
 *  @param userId     The user id
 *  @param elapsed The elapsed time (ms) from session beginning
 */
- (void)rtcEngine:(RongRTCEngine *)engine didRejoinChannel:(NSString*)channel withUser:(NSString *)userId elapsed:(NSInteger) elapsed;

/**
 *  Statistics of rtc engine status. Updated every two seconds.
 *
 *  @param engine The engine kit
 *  @param stats  The statistics of rtc status, including duration, sent bytes and received bytes
 */
- (void)rtcEngine:(RongRTCEngine *)engine reportRtcStats:(RongRtcStats*)stats;

/**
 *  The statistics of the call when leave channel
 *
 *  @param engine The engine kit
 *  @param stats  The statistics of the call, including duration, sent bytes and received bytes
 */
- (void)rtcEngine:(RongRTCEngine *)engine didLeaveChannelWithStats:(RongRtcStats*)stats;

/**
 *  The audio quality of the user. updated every two seconds.
 *
 *  @param engine  The engine kit
 *  @param userId     The id of user
 *  @param quality The audio quality
 *  @param delay   The delay from the remote user
 *  @param lost    The percentage of lost packets
 */
- (void)rtcEngine:(RongRTCEngine *)engine audioQualityOfUser:(NSString *)userId quality:(RongRtcQuality)quality delay:(NSUInteger)delay lost:(NSUInteger)lost;

/**
 *  The network quality of local user.
 *
 *  @param engine  The engine kit
 *  @param txQuality The network quality
 *  @param rxQuality The network quality
 */
- (void)rtcEngine:(RongRTCEngine *)engine networkQuality:(NSString *)userId txQuality:(RongRtcQuality)txQuality rxQuality:(RongRtcQuality)rxQuality;

/**
 *  The network quality of lastmile test.
 *
 *  @param engine  The engine kit
 *  @param quality The network quality
 */
- (void)rtcEngine:(RongRTCEngine *)engine lastmileQuality:(RongRtcQuality)quality;

#if (!(TARGET_OS_IPHONE) && (TARGET_OS_MAC))
/**
 *  the notificaitoin of device added removed
 *
 *  @param engine The engine kit
 *  @param deviceId   the identification of device
 *  @param deviceType type of device: -1: audio unknown; 0: audio recording ; 1: audio playout ; 2: render; 4: capture
 *  @param state      state of device: 0: added; 1: removed
 */
- (void)rtcEngine:(RongRTCEngine *)engine device:(NSString*) deviceId type:(RongRtcDeviceType) deviceType stateChanged:(NSInteger) state;
#endif

/**
 *  Event of API call executed
 *
 *  @param engine The engine kit
 *  @param api    The API description
 *  @param error  The error code
 */
- (void)rtcEngine:(RongRTCEngine *)engine didApiCallExecute:(NSString*)api error:(NSInteger)error;

- (void)rtcEngine:(RongRTCEngine *)engine didRefreshRecordingServiceStatus:(NSInteger)status;

/**
 *  receive custom data from remote user
 *
 *  @param engine The engine kit
 *  @param userId    The remote user id
 *  @param streamId The stream id
 *  @param data   The user defined data
 */
- (void)rtcEngine:(RongRTCEngine *)engine receiveStreamMessageFromUser:(NSString *)userId streamId:(NSInteger)streamId data:(NSData*)data;
- (void)rtcEngine:(RongRTCEngine *)engine didOccurStreamMessageErrorFromUser:(NSString *)userId streamId:(NSInteger)streamId error:(NSInteger)error missed:(NSInteger)missed cached:(NSInteger)cached;
@end




@interface RongRTCEngine : NSObject

/**
 *  Get the version of Rong SDK.
 *
 *  @return string, sdk version
 */
+ (NSString *)getSdkVersion;

/**
 *  Get the version of Media Engine
 *
 *  @return string, engine version
 */
+ (NSString *)getMediaEngineVersion;


/**
 *  Initializes the RongRtcEngineKit object.
 *
 *  @param appKey      The vendor key is issued to the application developers by Rong.
 *  @param delegate    Engine delegate
 *
 *  @return an object of RongRtcEngineKit class
 */
+ (instancetype)sharedEngineWithAppKey:(NSString*)appKey
                             delegate:(id<RongRTCEngineDelegate>)delegate;


+ (void)destroy;


/** BEGIN OF COMMON METHODS */

/**
 *  Create an open UDP socket to the RongRtcEngineKit cloud service to join a channel.
 Users in the same channel can talk to each other with same vendor key.
 Users using different vendor keys cannot call each other.
 The method is asynchronous.
 *
 *  @param channelKey        Channel key generated by APP using sign certificate.
 *  @param channelName       Joining in the same channel indicates those clients have entered in one room.
 *  @param userId            This argument is the unique ID for each member in one channel.
 *  @param joinSuccessBlock  join success callback, if failure, didErrorHappend will invoke
 *
 *  @return 0 when executed successfully, and return minus value when failed.
 */
- (int)joinChannelByKey:(NSString *)channelKey
            channelName:(NSString *)channelName
                 userId:(NSString *)userId
            joinSuccess:(void(^)(NSInteger elapsed))joinSuccessBlock;

/**
 *  lets the user leave a channel, i.e., hanging up or exiting a call.
 After joining a channel, the user must call the leaveChannel method to end the call before joining another one.
 It is synchronous, i.e., it only returns until the call ends and all resources are released.
 *  @param leaveChannelBlock indicate the statistics of this call, from joinChannel to leaveChannel, including duration, tx bytes and rx bytes in the call.
 *
 *  @return 0 if executed successfully, or return minus value if failed.
 */
- (int)leaveChannel:(void(^)(RongRtcStats* stat))leaveChannelBlock;

/**
 *  Enables video mode.  Switches from audio to video mode.
 It could be called during a call and before entering a channel.
 *
 *  @return 0 when this method is called successfully, or minus value when this method failed.
 */
- (int)enableVideo;

/**
 *  Disable video mode. Switch from video to audio mode.
 It could be called during a call and before entering a channel.
 *
 *  @return 0 when this method is called successfully, or minus value when this method failed.
 */
- (int)disableVideo;

/**
 *  start local video preview, while not sending data to server
 *
 *  @return 0 when this method is called successfully, or minus value when this method failed.
 */
- (int)startPreview;

/**
 *  stop local video preview
 *
 *  @return 0 when this method is called successfully, or minus value when this method failed.
 */
- (int)stopPreview;
/** END OF COMMON METHODS */

/** BEGIN OF AUDIO METHODS */


/**
 *  Enable / Disable speaker of device
 *
 *  @param enableSpeaker YES: Switches to speakerphone. NO: Switches to headset.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;

/**
 *  test if the speakerphone is enabled or not.
 *
 *  @return YES when speakerphone is enabled. NO when speakerphone is not enabled.
 */
- (BOOL)isSpeakerphoneEnabled;

/**
 *  Enables to report to the application about the volume of the speakers.
 *
 *  @param interval Specifies the time interval between two consecutive volume indications.
 <=0: Disables volume indication.
 >0 : The volume indication interval in milliseconds. Recommandation: >=200ms.
 *  @param smooth   The smoothing factor. Recommended: 3.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)enableAudioVolumeIndication:(NSInteger)interval
                            smooth:(NSInteger)smooth;


/**
 *  Start recording conversation to file specified by the file path.
 *
 *  @param filePath file path to save recorded conversation.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)startAudioRecording:(NSString*)filePath;


/**
 *  Stop conversation recording
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)stopAudioRecording;

- (int)startAudioMixing:(NSString*) filePath
               loopback:(BOOL) loopback
                replace:(BOOL) replace
                  cycle:(NSInteger) cycle;
- (int)stopAudioMixing;


/**
 *  Start screen capture
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)startScreenCapture:(NSUInteger)windowId;


/**
 *  Stop screen capture
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)stopScreenCapture;


- (int)setScreenCaptureId:(NSUInteger)windowId;

/**
 *  Mutes / Unmutes local audio.
 *
 *  @param mute true: Mutes the local audio. false: Unmutes the local audio.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)muteLocalAudioStream:(BOOL)mute;


/**
 *  Mutes / Unmutes all remote audio.
 *
 *  @param mute true: Mutes all remote received audio. false: Unmutes all remote received audio.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */

- (int)muteAllRemoteAudioStreams:(BOOL)mute;

- (int)muteRemoteAudioStream:(NSUInteger)uid
                        mute:(BOOL)mute;

/** END OF AUDIO METHODS */

/** BEGIN OF VIDIO METHODS */

/**
 *  Set up the local video view. The video canvus is initialized with video display setting. And it could be called before entering a channel.
 *
 *  @param local the canvas is composed of view, renderMode and uid. How to initialize 'local'? please take a look at 'RongRtcVideoCanvas'
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setupLocalVideo:(RongRtcVideoCanvas*)local;


/**
 *  Set up the remote video view. The video canvus is initialized with video display setting. It could be called after receiving the remote video streams to configure the video settings.
 *
 *  @param remote the canvas is composed of view, renderMode and uid. How to initialize 'remote'? please take a look at 'RongRtcVideoCanvas'
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setupRemoteVideo:(RongRtcVideoCanvas*)remote;


/**
 *  Configure display setting of local view. And it could be called mutiple times during a call.
 *
 *  @param mode There are Hidden(1), Fit(2) and Adaptive(3) mode. Please take a look at definition of enum RongRtcRenderMode
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setLocalRenderMode:(RongRtcRenderMode) mode;


/**
 *  Configure display setting of remote view. And it could be called mutiple times during a call.
 *
 *  @param uid  The user id of remote view.
 *  @param mode There are Hidden(1), Fit(2) and Adaptive(3) mode. Please take a look at definition of enum RongRtcRenderMode
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setRemoteRenderMode: (NSUInteger)uid
                      mode:(RongRtcRenderMode) mode;


/**
 *  Switches between front and back cameras.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)switchCamera;

/**
 *  set video profile, including resolution, fps, kbps
 *
 *  @param profile enumeration definition about the video resolution, fps and max kbps
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setVideoProfile:(RongRtcVideoProfile)profile;


/**
 *  Enable / disable sending local video streams to the network.
 *
 *  @param mute YES: stop sending local video stream to the network, NO: start sending local video stream.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)muteLocalVideoStream:(BOOL)mute;


/**
 *  Enables / disables playing all remote callers’ video streams.
 *
 *  @param mute YES: stop playing, NO: start playing.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)muteAllRemoteVideoStreams:(BOOL)mute;

/**
 *  Enable / disable a remote user's video stream
 *
 *  @param uid  The remote user id
 *  @param mute YES: discard the video stream from remote user, NO: start receiving remote video stream.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)muteRemoteVideoStream:(NSUInteger)uid
                        mute:(BOOL)mute;

/** END OF VIDIO METHODS */

/**
 *  Specifies the SDK output log file.
 *
 *  @param filePath The full file path of the log file.
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setLogFile:(NSString*)filePath;

/**
 *  Specifiy the log level of output
 *
 *  @param filter The log level
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setLogFilter:(NSUInteger)filter;

/**
 *  Set the role of user: such as broadcaster, audience and free(as broadcaster and audience at the same time)
 *
 *  @param profile the role of user
 *
 *  @return 0 when executed successfully. return minus value if failed.
 */
- (int)setChannelProfile:(RongRtcChannelProfile)profile;

/**
	* Specify encryption mode of AES encryption algorithm.
	* @param [in] encryptionMode
	*        encryption mode of AES algorithm, could be one of the following:
	*          "aes-128-xts", "aes-256-xts".
	*          The default value is "aes-128-xts". specify NULL value will use default encryption mode.
	* @return return 0 if success or an error code
	*/
- (int)setEncryptionMode:(NSString*)encryptionMode;

/**
	* Specifying encryption secret enables built-in AES-128 encryption. Leaving channel will clear the secret specified in last channel
	* @param [in] secret
	*        secret to enable encryption
	* @return return 0 if success or an error code
	*/
- (int)setEncryptionSecret:(NSString*)secret;

- (int) startRecordingService:(NSString*)recordingKey;
- (int) stopRecordingService:(NSString*)recordingKey;
- (int) refreshRecordingServiceStatus;
@end


