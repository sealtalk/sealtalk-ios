//
//  HTWebViewController.m
//  HTWebView
//
//  Created by Mr.Yang on 13-8-2.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "HTWebViewController.h"
#import "WebViewConfig.h"
#import "RedpacketErrorLoger.h"
#import "RedpacketErrorView.h"
#import "RPRedpacketSetting.h"
#import "RPRedpacketTool.h"


#pragma mark -
#pragma mark ExtensionMethod
/*
@interface UIViewController () <NavigationBarShouldPopItemProtocol>


@end

@implementation UIViewController (popItem)

- (BOOL)navigationBarShouldPopItem
{
    return YES;
}

@end

@implementation UINavigationController (PopItem)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    BOOL shouldPop = YES;
    
    YZHBaseViewController *topVc = (YZHBaseViewController *)[self topViewController];
    if (topVc && [topVc respondsToSelector:@selector(navigationBarShouldPopItem)]){
        shouldPop = [topVc navigationBarShouldPopItem];
        
        if ([topVc isKindOfClass:[YZHBaseViewController class]] && shouldPop) {
            [self popViewControllerAnimated:YES];
        }else{
            return shouldPop;
        }
    }
    
    return shouldPop;
}

@end

*/
#pragma mark -
#pragma mark HTWebProgressView

@interface HTWebProgressView : UIView

@property (nonatomic, assign)   CGFloat progressValue;
@property (nonatomic, strong)   UIColor *tintColor;

@end


@implementation HTWebProgressView


- (id)init
{
    self = [super init];
    
    if (self) {
        [self initVariables];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initVariables];
    }
    
    return self;
}

- (void)initVariables
{
    _tintColor = [UIColor greenColor];
    _progressValue = 0.0f;
}

- (void)setProgressValue:(CGFloat)progressValue
{
    if (progressValue > 1.0f) {
        progressValue = 1.0f;
    }
    
    if (progressValue < .0f) {
        progressValue = .0f;
    }
    
    CGRect rect = self.frame;
    static CGFloat width;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = rect.size.width;
    });

    if (progressValue > _progressValue) {
        _progressValue = progressValue;
        rect.size.width = width * _progressValue;
        self.frame = rect;
    }
}

@end


#pragma mark - 
#pragma mark HTWebViewDelegate

@protocol HTWebViewDelegate <NSObject>

- (void)webView:(HTWebView *)webView didReceiveDataPresent:(CGFloat)persent;

@end


#pragma mark -
#pragma mark HTWebView

@interface UIWebView ()

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end




@interface HTWebView ()

@property (nonatomic, assign) id <HTWebViewDelegate> progressDelegate;

@end

@implementation HTWebView
{
    CGFloat _totalCount;
    NSInteger _receiveCount;
}

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource
{
    [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    
    return @(_totalCount++);
}

- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    
    _receiveCount++;
    if (_progressDelegate && [_progressDelegate respondsToSelector:@selector(webView:didReceiveDataPresent:)]) {
        [_progressDelegate webView:self didReceiveDataPresent:_receiveCount/_totalCount ];
    }

    if (_receiveCount == _totalCount) {
        _receiveCount = 0.0;
        _totalCount = 0.0;
    }
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource
{
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    
    _receiveCount++;
    if (_progressDelegate && [_progressDelegate respondsToSelector:@selector(webView:didReceiveDataPresent:)]) {
        [_progressDelegate webView:self didReceiveDataPresent:(CGFloat)_receiveCount/(CGFloat)_totalCount ];
    }
    
    if (_receiveCount == _totalCount) {
        _receiveCount = 0.0;
        _totalCount = 0.0;
    }
}

@end
#pragma mark -
#pragma mark HTWebViewController

@interface HTWebViewController () <HTWebViewDelegate>
{
    BOOL _loadError;
}

@property (nonatomic, assign)   BOOL loadData;
@property (nonatomic, strong)   HTWebProgressView *progressView;
@property (nonatomic, strong)   NSMutableDictionary *headerDic;
@property (nonatomic, strong)   RedpacketErrorView *errorView;

@end


@implementation HTWebViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavgationBar];
}

/**
 *  NavigationBar 处理操作
 */
- (void)setNavgationBar
{
    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 32)];
    [titleView addSubview:self.titleLable];
    [titleView addSubview:self.subLable];
    self.navigationItem.titleView=titleView;
    [titleView sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    CGSize imageSize = CGSizeMake(100, 100);
//    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
//    [[UIColor whiteColor] set];
//    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
//    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:rp_imageWithColor([UIColor whiteColor]) forBarMetrics:UIBarMetricsDefault];
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 195, 18)];
        _titleLable.font = [UIFont systemFontOfSize:17.0];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor = [UIColor whiteColor];
    }
    return _titleLable;
}

- (UILabel *)subLable
{
    if (!_subLable) {
        _subLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 21.5, 195, 11)];
        NSString *orgName = [RPRedpacketSetting shareInstance].redpacketOrgName;
        _subLable.text = [NSString stringWithFormat:@"%@红包服务", orgName];
        _subLable.font = [UIFont systemFontOfSize:10.0];
        _subLable.textAlignment = NSTextAlignmentCenter;
        _subLable.textColor = [UIColor whiteColor];
    }
    return _subLable;
}

#pragma mark - ht_URLHook

- (void)ht_urlHookWithRequest:(NSURLRequest *)request
{
    [self userActionCallBackWithRequest:request];
}

//  TODO: rewrite in subClass
- (void)userActionCallBackWithRequest:(NSURLRequest *)request
{

}

- (void)setUrl:(NSURL *)url
{
    if (![_url.absoluteString isEqualToString:url.absoluteString]) {
        _url = url;
        [self refresh:url];
    }
}

- (void)loadListRequest
{
    [self refresh:_url];
}

- (void)refresh:(NSURL *)url
{
    if (!url.absoluteString || url.absoluteString.length == 0) {
        return;
    }
    
    if (!_progressView) {
        
        CGFloat topHight = self.navigationController.navigationBar.hidden ? 0.0f : 64.0f;
        topHight = 0;
        _progressView = [[HTWebProgressView alloc] initWithFrame:CGRectMake(0, topHight, CGRectGetWidth(self.view.frame), 3)];

        _progressView.backgroundColor = ht_hexColor(defaultColor_progressViewColor);
    }
    
    _progressView.hidden = NO;
    _loadError = NO;
    _progressView.progressValue = .06f;
    
    if (!_webView) {
        _webView = [[HTWebView alloc] initWithFrame:self.view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = ht_hexColor(defaultColor_webViewBackGroudColor);
        _webView.progressDelegate = self;
        
        [self.view addSubview:_webView];
        [_webView addSubview:_progressView];
    }
    
    if (_loadData) {
        [_webView loadData:[NSData dataWithContentsOfURL:_url] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:_url];
        _webView.scalesPageToFit = NO;
        
    }else {
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
        urlRequest.allHTTPHeaderFields = [self addRequestHeader:urlRequest.allHTTPHeaderFields];
        [_webView loadRequest:urlRequest];
    }
}

- (void)setHeaderObject:(id)anObject forKey:(id)aKey
{
    [self.headerDic setValue:anObject forKey:aKey];
}

- (NSMutableDictionary *)headerDic
{
    if (!_headerDic) {
        _headerDic = [NSMutableDictionary dictionary];
    }
    
    return _headerDic;
}

- (NSDictionary *)addRequestHeader:(NSDictionary *)headerDic
{
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:headerDic];
    
    if (!_headerDic) {
        _headerDic = [NSMutableDictionary dictionary];
    }
    
    for (NSString *key in [_headerDic allKeys]) {
        id obj = [_headerDic objectForKey:key];
        
        [mutDic setValue:obj forKey:key];
    }
    
    return mutDic;
}

#pragma mark - WebViewDelegate

- (void)webView:(HTWebView *)webView didReceiveDataPresent:(CGFloat)persent
{
    if (persent < .06f || _loadError) {
        return;
    }
    
    _progressView.progressValue = persent;
    
    if (persent >= 1.0f) {
        _progressView.hidden = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _loadError = YES;
    _progressView.hidden = YES;

    [[RedpacketErrorLoger sharedLoger] addWebviewError:webView.request.URL.description andErrorMsg:error.description];
    [[RedpacketErrorLoger sharedLoger] update];
    
    [self showRedpacketErrorView];
}

- (void)showRedpacketErrorView
{
    [_errorView removeFromSuperview];
    RedpacketErrorView *view = [[RedpacketErrorView alloc] initWithFrame:self.view.bounds];
    _errorView = view;
    [self.view addSubview:_errorView];
    
    __weak HTWebViewController *weakSelf = self;
    [view setButtonClickBlock:^{
        [weakSelf.errorView removeFromSuperview];
        [weakSelf refresh:weakSelf.url];
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.errorView removeFromSuperview];
}


@end
