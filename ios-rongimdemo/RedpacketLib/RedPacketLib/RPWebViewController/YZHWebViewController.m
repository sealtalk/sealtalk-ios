//
//  YZHWebViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHWebViewController.h"
#import "RPRedpacketUser.h"
#import "RPRedpacketTool.h"


#define __YZHRedpacketJDPayScheme   @"redpacket"


@interface YZHWebViewController ()

@property (nonatomic, strong)   NSMutableArray *requestUrls;

@property (nonatomic, assign)   BOOL shouldClose;

@end

@implementation YZHWebViewController

- (BOOL)navigationBarShouldPopItem
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        
        return NO;
    }
    
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self changeViewStyle];
    
    UIDevice *device = [UIDevice currentDevice];
    RPRedpacketUser *user = [RPRedpacketUser currentUser];
    [self setHeaderObject:device.identifierForVendor.UUIDString forKey:@"device-id"];
    [self setHeaderObject:user.userToken forKey:@"x-auth-token"];
    
    NSTimeInterval interval = [[NSDate date ] timeIntervalSince1970] * 1000;
    srand(interval);
    double random =  arc4random() % 1000 + 1000;
    NSString *requestId = [NSString stringWithFormat:@"%.0f%.0f", interval, random];
    [self setHeaderObject:requestId forKey:@"request-id"];

    [self addCloseBarButtonItem];
}

- (NSMutableArray *)requestUrls
{
    if (!_requestUrls) {
        _requestUrls = [NSMutableArray array];
    }
    
    return _requestUrls;
}

#pragma mark -
- (void)dismiss
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)closeBarButtonSender:(UIButton *)button
{
    //  返回
    if([self.webView canGoBack] && !_shouldClose) {
        [self.webView goBack];
        
    }else {
        [self dismiss];
    }
}

- (void)addCloseBarButtonItem
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [backButton setTitleColor:[RedpacketColorStore rp_textColorBlack] forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(closeBarButtonSender:) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *closeBtn = [[UIButton alloc]init];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [closeBtn setTitleColor:[RedpacketColorStore rp_textColorBlack] forState:UIControlStateNormal];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn sizeToFit];
    closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    negativeSpacer.width = - 8;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_right, nil];

}

- (void)clickCloseBtn
{
    [self dismiss];
}

- (void)changeViewStyle
{
    self.navigationController.navigationBar.tintColor                        = [UIColor whiteColor];
    self.navigationController.navigationBar.backIndicatorImage               = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    self.navigationController.navigationBar.titleTextAttributes              = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]};
    
    self.view.backgroundColor = rp_hexColor(0xefefef);
    
    [self changeBackBarButton];
}

- (void)changeBackBarButton
{
    UIBarButtonItem *returnButtonItem     = [[UIBarButtonItem alloc] init];
    returnButtonItem.title                = @"后退";
    self.navigationItem.backBarButtonItem = returnButtonItem;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    RPDebug(@"requestWebURL:%@", request.URL);
    
    _shouldClose = [self shouldCloseWindow:request.URL.description];
    
    if ([request.URL.description isEqualToString:@"/app/welcome"]) {
        [self dismiss];
    }
    
    NSString *scheme = [request.URL scheme];
    if ([scheme isEqualToString:__YZHRedpacketJDPayScheme]) {
        //  关闭当前页 并发送红包
        if (_redpacketSendLuckMoneySuccess) {
            _redpacketSendLuckMoneySuccess([self dictWithJDPayCallBackUrl:request.URL]);
        }
        
        return NO;
    }
    
    [self.requestUrls addObject:request.URL];
    
    return YES;
}

- (BOOL)shouldCloseWindow:(NSString *)urlStr
{
    NSArray *array = @[@"/app/hongbao/reset/pwsuccess",
                       @"/app/welcome",
                       @"/app/hongbao/wallet",
                      ];
    
    for (NSString *string in array) {
        if ([urlStr rangeOfString:string].length != 0) {
            return YES;
        }
    }
    
    return NO;
}

//  1.关闭  2.返回
- (void)changeBackItemTitleClose:(BOOL)shouldClose
{
    //shouldClose = ![self.webView canGoBack] || shouldClose;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    NSString *title = shouldClose ? @"关闭" : @"返回";
    button.tag = shouldClose ? 1 : 2;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeBarButtonSender:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (NSDictionary *)dictWithJDPayCallBackUrl:(NSURL *)url
{
    NSString *urlStr = url.description;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *array = [urlStr componentsSeparatedByString:@"?"];
    
    if (array.count > 1) {
        NSString *urlParamStr = array[1];
        array = [urlParamStr componentsSeparatedByString:@"&"];
        
        for (NSString *paramStr in array) {
            NSArray *array = [paramStr componentsSeparatedByString:@"="];
            
            NSAssert(array.count == 2, @"解析param 出错~");
            
            if (array.count == 2) {
                [dict setValue:array[1] forKey:array[0]];
            }
        }
        
        return dict;
    }
    
    return nil;
}

@end
