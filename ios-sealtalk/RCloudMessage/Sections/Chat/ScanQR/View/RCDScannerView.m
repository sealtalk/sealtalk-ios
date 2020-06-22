//
//  RCDQRInfoHandle.h
//  SealTalk
//
//  Created by 张改红 on 2019/7/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDScannerView.h"
#import "objc/runtime.h"
#import "RCDQRCodeManager.h"
#import <Masonry/Masonry.h>
#define Scanner_Width 206                                     /** 扫描器宽度 */
#define Scanner_X (self.frame.size.width - Scanner_Width) / 2 /** 扫描器初始x值 */
#define Scanner_Y 118                                         /** 扫描器初始y值 */

NSString *const ScannerLineAnmationKey = @"ScannerLineAnmationKey"; /** 扫描线条动画Key值 */
CGFloat const Scanner_BorderWidth = 1.0f;                           /** 扫描器边框宽度 */
CGFloat const Scanner_CornerWidth = 3.0f;                           /** 扫描器棱角宽度 */
CGFloat const Scanner_CornerLength = 20.0f;                         /** 扫描器棱角长度 */
CGFloat const Scanner_LineHeight = 2.0f;                            /** 扫描器线条高度 */

CGFloat const FlashlightBtn_Width = 20.0f;  /** 手电筒按钮宽度 */
CGFloat const FlashlightLab_Height = 15.0f; /** 手电筒提示文字高度 */
CGFloat const TipLab_Height = 50.0f;        /** 扫描器下方提示文字高度 */

static char FLASHLIGHT_ON; /** 手电筒开关状态绑定标识符 */

@interface RCDScannerView ()

@property (nonatomic, strong) UIImageView *scannerLine;                   /** 扫描线条 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator; /** 加载指示器 */
@property (nonatomic, strong) UIButton *flashlightBtn;                    /** 手电筒按钮 */
@property (nonatomic, strong) UILabel *tipLab;                            /** 扫描器下方提示文字 */
@property (nonatomic, strong) UIButton *selectImageBtn;

@end

@implementation RCDScannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupUI];
    }
    return self;
}

- (void)_setupUI {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scannerLine];
    [self rcd_addScannerLineAnimation];
    [self addSubview:self.flashlightBtn];
    [self addSubview:self.tipLab];
    [self addSubview:self.selectImageBtn];
    [self.flashlightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(Scanner_Y + Scanner_Width + 14);
        make.left.width.equalTo(self);
        make.height.offset(24);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.flashlightBtn.mas_bottom).offset(15);
        make.left.width.equalTo(self);
        make.height.offset(20);
    }];
    [self.selectImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).offset(28);
        make.centerX.equalTo(self);
        make.width.offset(135);
        make.height.offset(35);
    }];
}

#pragma mark-- 手电筒点击事件
- (void)flashlightClicked:(UIButton *)button {
    button.selected = !button.selected;
    [self rcd_setFlashlightOn:self.flashlightBtn.selected];
}

/** 添加扫描线条动画 */
- (void)rcd_addScannerLineAnimation {

    // 若已添加动画，则先移除动画再添加
    [self.scannerLine.layer removeAllAnimations];

    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    lineAnimation.toValue =
        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, Scanner_Width - Scanner_LineHeight, 1)];
    lineAnimation.duration = 4;
    lineAnimation.repeatCount = HUGE;
    [self.scannerLine.layer addAnimation:lineAnimation forKey:ScannerLineAnmationKey];
    // 重置动画运行速度为1.0
    self.scannerLine.layer.speed = 1.0;
}

/** 暂停扫描器动画 */
- (void)rcd_pauseScannerLineAnimation {
    // 取出当前时间，转成动画暂停的时间
    CFTimeInterval pauseTime = [self.scannerLine.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
    self.scannerLine.layer.timeOffset = pauseTime;
    // 将动画的运行速度设置为0， 默认的运行速度是1.0
    self.scannerLine.layer.speed = 0;
}

/** 显示手电筒 */
- (void)rcd_showFlashlightWithAnimated:(BOOL)animated {
    self.flashlightBtn.selected = YES;
}

/** 隐藏手电筒 */
- (void)rcd_hideFlashlightWithAnimated:(BOOL)animated {
    self.flashlightBtn.selected = NO;
}

/** 添加指示器 */
- (void)rcd_addActivityIndicator {
    if (!self.activityIndicator) {
        self.activityIndicator =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.center = self.center;
        [self addSubview:self.activityIndicator];
    }
    [self.activityIndicator startAnimating];
}

/** 移除指示器 */
- (void)rcd_removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

/** 设置手电筒开关 */
- (void)rcd_setFlashlightOn:(BOOL)on {
    [RCDQRCodeManager rcd_FlashlightOn:on];
    self.flashlightBtn.selected = on;
    objc_setAssociatedObject(self, &FLASHLIGHT_ON, @(on), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/** 获取手电筒当前开关状态 */
- (BOOL)rcd_flashlightOn {
    return [objc_getAssociatedObject(self, &FLASHLIGHT_ON) boolValue];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 半透明区域
    [[UIColor colorWithWhite:0 alpha:0.7] setFill];
    UIRectFill(rect);

    // 透明区域
    CGRect scanner_rect = CGRectMake(Scanner_X, Scanner_Y, Scanner_Width, Scanner_Width);
    [[UIColor clearColor] setFill];
    UIRectFill(scanner_rect);

    // 边框
    UIBezierPath *borderPath =
        [UIBezierPath bezierPathWithRect:CGRectMake(Scanner_X, Scanner_Y, Scanner_Width, Scanner_Width)];
    borderPath.lineCapStyle = kCGLineCapRound;
    borderPath.lineWidth = Scanner_BorderWidth;
    [[UIColor clearColor] set];
    [borderPath stroke];

    for (int index = 0; index < 4; ++index) {

        UIBezierPath *tempPath = [UIBezierPath bezierPath];
        tempPath.lineWidth = Scanner_CornerWidth;
        [HEXCOLOR(0x0099ff) set];

        switch (index) {
        // 左上角棱角
        case 0: {
            [tempPath moveToPoint:CGPointMake(Scanner_X + Scanner_CornerLength, Scanner_Y)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y + Scanner_CornerLength)];
        } break;
        // 右上角
        case 1: {
            [tempPath moveToPoint:CGPointMake(Scanner_X + Scanner_Width - Scanner_CornerLength, Scanner_Y)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y + Scanner_CornerLength)];
        } break;
        // 左下角
        case 2: {
            [tempPath moveToPoint:CGPointMake(Scanner_X, Scanner_Y + Scanner_Width - Scanner_CornerLength)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X, Scanner_Y + Scanner_Width)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_CornerLength, Scanner_Y + Scanner_Width)];
        } break;
        // 右下角
        case 3: {
            [tempPath
                moveToPoint:CGPointMake(Scanner_X + Scanner_Width - Scanner_CornerLength, Scanner_Y + Scanner_Width)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width, Scanner_Y + Scanner_Width)];
            [tempPath addLineToPoint:CGPointMake(Scanner_X + Scanner_Width,
                                                 Scanner_Y + Scanner_Width - Scanner_CornerLength)];
        } break;
        default:
            break;
        }
        [tempPath stroke];
    }
}

- (CGFloat)scanner_x {
    return Scanner_X;
}

- (CGFloat)scanner_y {
    return Scanner_Y;
}

- (CGFloat)scanner_width {
    return Scanner_Width;
}

- (void)didClickSelectImageBtn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSelectImageButton)]) {
        [self.delegate didClickSelectImageButton];
    }
}

/** 扫描线条 */
- (UIImageView *)scannerLine {
    if (!_scannerLine) {
        _scannerLine = [[UIImageView alloc]
            initWithFrame:CGRectMake(Scanner_X + 20, Scanner_Y, Scanner_Width - 40, Scanner_LineHeight)];
        _scannerLine.image = [UIImage imageNamed:@"ScannerLine"];
    }
    return _scannerLine;
}

/** 扫描器下方提示文字 */
- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.textAlignment = NSTextAlignmentCenter;
        _tipLab.textColor = HEXCOLOR(0x939393);
        _tipLab.text = RCDLocalizedString(@"ScanQRInfo");
        _tipLab.font = [UIFont systemFontOfSize:13];
    }
    return _tipLab;
}

/** 手电筒开关 */
- (UIButton *)flashlightBtn {
    if (!_flashlightBtn) {
        _flashlightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashlightBtn addTarget:self
                           action:@selector(flashlightClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
        _flashlightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_flashlightBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_flashlightBtn setTitle:RCDLocalizedString(@"LightOn") forState:(UIControlStateNormal)];
        [_flashlightBtn setTitle:RCDLocalizedString(@"LightOff") forState:(UIControlStateSelected)];
    }
    return _flashlightBtn;
}

- (UIButton *)selectImageBtn {
    if (!_selectImageBtn) {
        _selectImageBtn = [[UIButton alloc] init];
        _selectImageBtn.font = [UIFont systemFontOfSize:13];
        _selectImageBtn.backgroundColor = HEXCOLOR(0x0195ff);
        [_selectImageBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_selectImageBtn setTitle:RCDLocalizedString(@"SelectImage") forState:(UIControlStateNormal)];
        _selectImageBtn.layer.masksToBounds = YES;
        _selectImageBtn.layer.cornerRadius = 4;
        [_selectImageBtn addTarget:self
                            action:@selector(didClickSelectImageBtn)
                  forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _selectImageBtn;
}
@end
