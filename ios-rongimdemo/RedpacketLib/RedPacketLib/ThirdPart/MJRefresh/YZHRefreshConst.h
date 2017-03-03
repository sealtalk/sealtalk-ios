//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>
#import <objc/message.h>

// 弱引用
#define YZHMJWeakSelf __weak typeof(self) weakSelf = self;

// 日志输出
#ifdef DEBUG
#define YZHMJRefreshLog(...) NSLog(__VA_ARGS__)
#else
#define YZHMJRefreshLog(...)
#endif

// 过期提醒
#define YZHMJRefreshDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 运行时objc_msgSend
#define YZHMJRefreshMsgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define YZHMJRefreshMsgTarget(target) (__bridge void *)(target)

// RGB颜色
#define YZHMJRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 文字颜色
#define YZHMJRefreshLabelTextColor YZHMJRefreshColor(90, 90, 90)

// 字体大小
#define YZHMJRefreshLabelFont [UIFont boldSystemFontOfSize:14]

// 图片路径
#define YZHMJRefreshSrcName(file) [@"YZHRefresh.bundle" stringByAppendingPathComponent:file]
#define YZHMJRefreshFrameworkSrcName(file) [@"Frameworks/MJRefresh.framework/YZHRefresh.bundle" stringByAppendingPathComponent:file]

// 常量
UIKIT_EXTERN const CGFloat YZHMJRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat YZHMJRefreshFooterHeight;
UIKIT_EXTERN const CGFloat YZHMJRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat YZHMJRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const YZHMJRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const YZHMJRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const YZHMJRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const YZHMJRefreshKeyPathPanState;

UIKIT_EXTERN NSString *const YZHMJRefreshHeaderLastUpdatedTimeKey;

UIKIT_EXTERN NSString *const YZHMJRefreshHeaderIdleText;
UIKIT_EXTERN NSString *const YZHMJRefreshHeaderPullingText;
UIKIT_EXTERN NSString *const YZHMJRefreshHeaderRefreshingText;

UIKIT_EXTERN NSString *const YZHMJRefreshAutoFooterIdleText;
UIKIT_EXTERN NSString *const YZHMJRefreshAutoFooterRefreshingText;
UIKIT_EXTERN NSString *const YZHMJRefreshAutoFooterNoMoreDataText;

UIKIT_EXTERN NSString *const YZHMJRefreshBackFooterIdleText;
UIKIT_EXTERN NSString *const YZHMJRefreshBackFooterPullingText;
UIKIT_EXTERN NSString *const YZHMJRefreshBackFooterRefreshingText;
UIKIT_EXTERN NSString *const YZHMJRefreshBackFooterNoMoreDataText;

// 状态检查
#define YZHMJRefreshCheckState \
YZHRefreshState oldState = self.state; \
if (state == oldState) return; \
[super setState:state];
