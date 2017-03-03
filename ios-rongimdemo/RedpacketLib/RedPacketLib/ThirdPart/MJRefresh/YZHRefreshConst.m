//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
#import <UIKit/UIKit.h>

const CGFloat YZHMJRefreshHeaderHeight = 54.0;
const CGFloat YZHMJRefreshFooterHeight = 44.0;
const CGFloat YZHMJRefreshFastAnimationDuration = 0.25;
const CGFloat YZHMJRefreshSlowAnimationDuration = 0.4;

NSString *const YZHMJRefreshKeyPathContentOffset = @"contentOffset";
NSString *const YZHMJRefreshKeyPathContentInset = @"contentInset";
NSString *const YZHMJRefreshKeyPathContentSize = @"contentSize";
NSString *const YZHMJRefreshKeyPathPanState = @"state";

NSString *const YZHMJRefreshHeaderLastUpdatedTimeKey = @"MJRefreshHeaderLastUpdatedTimeKey";

NSString *const YZHMJRefreshHeaderIdleText = @"下拉可以刷新";
NSString *const YZHMJRefreshHeaderPullingText = @"松开立即刷新";
NSString *const YZHMJRefreshHeaderRefreshingText = @"正在刷新数据中...";

NSString *const YZHMJRefreshAutoFooterIdleText = @"点击或上拉加载更多";
NSString *const YZHMJRefreshAutoFooterRefreshingText = @"正在加载更多的数据...";
NSString *const YZHMJRefreshAutoFooterNoMoreDataText = @"已经全部加载完毕";

NSString *const YZHMJRefreshBackFooterIdleText = @"上拉可以加载更多";
NSString *const YZHMJRefreshBackFooterPullingText = @"松开立即加载更多";
NSString *const YZHMJRefreshBackFooterRefreshingText = @"正在加载更多的数据...";
NSString *const YZHMJRefreshBackFooterNoMoreDataText = @"已经全部加载完毕";