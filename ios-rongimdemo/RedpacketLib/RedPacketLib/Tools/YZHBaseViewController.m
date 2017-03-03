//
//  YZHBaseViewController.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/9.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZHBaseViewController.h"
#import "RPRedpacketSetting.h"


@interface YZHBaseViewController ()

@property (nonatomic) UIButton *leftButton;

@property (nonatomic) UIButton *rightButton;

@end

@implementation YZHBaseViewController

- (void)dealloc
{
    RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 32)];
    [titleView addSubview:self.titleLable];
    [titleView addSubview:self.subLable];
    self.navigationItem.titleView=titleView;
    [titleView sizeToFit];
    [self configViewStyle];
}

- (void)setNavgationBarBackgroundColor:(UIColor *)groundColor titleColor:(UIColor *)titleColor leftButtonTitle:(NSString *)leftButtonTitle rightButtonTitle:(NSString *)rightButtonTitle;
{
    [self.navigationController.navigationBar setBackgroundImage:rp_imageWithColor(groundColor) forBarMetrics:UIBarMetricsDefault];
    
    self.titleLable.textColor = titleColor;
    self.subLable.textColor   = titleColor;
    
    if (leftButtonTitle.length > 1) {
        [self.leftButton setTitleColor:titleColor forState:UIControlStateNormal];
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        self.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *btn_left = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        
        negativeSpacer.width = - 8;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_left, nil];
    }
    
    if (rightButtonTitle.length > 1) {
        
        [self.rightButton setTitleColor:titleColor forState:UIControlStateNormal];
        [self.rightButton setTitle:rightButtonTitle forState:UIControlStateNormal];
        [self.rightButton sizeToFit];
        self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        
        negativeSpacer.width = - 8;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_right, nil];
        
    }
//    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.navigationBar.tintColor = titleColor;
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : titleColor}];
        self.navigationController.navigationBar.translucent = NO;
    }

}

#pragma mark - ViewStyle
- (void)configViewStyle
{
    self.navigationController.navigationBar.barTintColor   = [RedpacketColorStore rp_textColorRed];
    self.navigationController.navigationBar.barStyle       = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent    = NO;
    self.navigationController.navigationBar.tintColor      = [RedpacketColorStore rp_textcolorYellow];
    self.navigationController.navigationBar.backIndicatorImage = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = rpRedpacketBundleImage(@"redpacket_navigationbar_return");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]};
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_leftButton addTarget:self action:@selector(clickButtonLeft) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton setFrame:CGRectMake(0, 0, 40, 20)];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_rightButton addTarget:self action:@selector(clickButtonRight) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton sizeToFit];
    }
    return _rightButton;
}

- (void)clickButtonRight
{
    
}

- (void)clickButtonLeft
{
    
}

- (void)setCuttingLineHidden:(BOOL)cuttingLineHidden
{
    _cuttingLineHidden = cuttingLineHidden;
    if (cuttingLineHidden) {
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        //设置透明的背景图，便于识别底部线条有没有被隐藏
        [navigationBar setBackgroundImage:[[UIImage alloc] init]
                           forBarPosition:UIBarPositionAny
                               barMetrics:UIBarMetricsDefault];
        //此处使底部线条失效
        [navigationBar setShadowImage:[UIImage new]];
    }
}

- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 195, 18)];
        _titleLable.font = [UIFont systemFontOfSize:17.0];
        _titleLable.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLable;
}

- (UILabel *)subLable
{
    if (!_subLable) {
        _subLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 21.5, 195, 11)];
        NSString *orgName = [RPRedpacketSetting shareInstance].redpacketOrgName;
        if (orgName.length > 0) {
            _subLable.text = rpString(@"%@红包服务", orgName);
        }else
        {
            _subLable.text =@"";
        }
        _subLable.font = [UIFont systemFontOfSize:10.0];
        _subLable.textAlignment = NSTextAlignmentCenter;
    }
    return _subLable;
}

- (void)netWorkErrorShow:(NSString *)error
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:error delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_clickErrorButton) {
        _clickErrorButton();
    }
}

@end
