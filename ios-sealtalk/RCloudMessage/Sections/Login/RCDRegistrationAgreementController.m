//
//  RCDRegistrationAgreementController.m
//  SealTalk
//
//  Created by 张改红 on 2021/3/30.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDRegistrationAgreementController.h"
#import <WebKit/WebKit.h>
@interface RCDRegistrationAgreementController ()
@property (nonatomic, strong)  WKWebView *webView;
@end

@implementation RCDRegistrationAgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"注册条款";
    self.view.backgroundColor = HEXCOLOR(0xffffff);
    [self.view addSubview:self.webView];
    // 获取路径
    NSString * path = [[NSBundle mainBundle] pathForResource:RCDLocalizedString(@"Registration_Agreement") ofType:@"html"];
    // 创建URL
    NSURL * url = [NSURL fileURLWithPath:path];
    // 创建NSURLRequest
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    // 加载
    [self.webView loadRequest:request];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc]
            initWithFrame:self.view.bounds];
        _webView.scrollView.contentInset = (UIEdgeInsets){8, 8, 8, 8};
        _webView.backgroundColor =
            [UIColor colorWithRed:242.f / 255.f green:242.f / 255.f blue:243.f / 255.f alpha:1.f];
    }
    return _webView;
}


@end
