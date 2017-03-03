//
//  RPValidateIdView.m
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPValidateIdView.h"
#import "RPLayout.h"
#import "UIView+YZHExtension.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"

@implementation RPValidateIdView

- (instancetype)init
{
    self =[super init];
    if (self) {
        [self loadSubViews];
        self.rp_height = 200;
    }
    return self;
}

- (void)loadSubViews
{// frame
    UILabel *topLabel = [self rp_addsubview:[UILabel class]];
    topLabel.text = @"请分别上传身份证正面和背面照片";
    topLabel.textColor = [UIColor whiteColor];
    topLabel.font = [UIFont systemFontOfSize:13.0];
    [topLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(20);
        make.centerX.equalTo(self.rpm_centerX).offset(0);
    }];
    
    UIView *cuttingLine = [self rp_addsubview:[UIView class]];
    cuttingLine.hidden = YES;
    cuttingLine.backgroundColor = [RedpacketColorStore rp_redButtonNormalColor];
    [cuttingLine rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(self.rpm_top).offset(69);
        make.centerX.equalTo(self.rpm_centerX);
        make.width.offset(4);
        make.bottom.equalTo(self.rpm_bottom).offset(-69);
    }];
    
    UILabel *leftLabel = [self rp_addsubview:[UILabel class]];
    leftLabel.text = @"身份证正面";
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = [UIFont systemFontOfSize:13.0];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    [leftLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-20);
        make.left.equalTo(self.rpm_left).offset(0);
        make.right.equalTo(self.rpm_centerX).offset(0);
    }];
    
    UILabel *rightLabel = [self rp_addsubview:[UILabel class]];
    rightLabel.text = @"身份证反面";
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont systemFontOfSize:13.0f];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    [rightLabel rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.bottom.equalTo(self.rpm_bottom).offset(-20);
        make.left.equalTo(self.rpm_centerX).offset(0);
        make.right.equalTo(self.rpm_right).offset(0);
    }];
    
    [self.imageViewLeft rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(topLabel.rpm_bottom).offset(10);
        make.left.equalTo(self.rpm_left).offset(15);
        make.right.equalTo(cuttingLine.rpm_left).offset(-3);
        make.bottom.equalTo(leftLabel.rpm_top).offset(-10);
    }];
    
    [self.imageViewRight rpm_makeConstraints:^(RPConstraintMaker *make) {
        make.top.equalTo(topLabel.rpm_bottom).offset(10);
        make.left.equalTo(cuttingLine.rpm_right).offset(3);
        make.right.equalTo(self.rpm_right).offset(-15);
        make.bottom.equalTo(rightLabel.rpm_top).offset(-10);
    }];
    // 赋值
    self.backgroundColor = [RedpacketColorStore rp_blueButtonNormalColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftImageViewTouched)];
    [self.imageViewLeft addGestureRecognizer:tap];
    self.imageViewLeft.userInteractionEnabled = YES;
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightImageViewTouched)];
    [self.imageViewRight addGestureRecognizer:tap];
    self.imageViewRight.userInteractionEnabled = YES;
    
    _leftImageViewtype = -1;
    self.leftImageViewtype = ValidateIDViewReady;
    
    _rightImageViewtype = -1;
    self.rightImageViewtype = ValidateIDViewReady;
}

- (UIImageView *)imageViewLeft
{
    if (!_imageViewLeft) {
        _imageViewLeft = [self rp_addsubview:[UIImageView class]];
    }
    return _imageViewLeft;
}

- (UIImageView *)imageViewRight
{
    if (!_imageViewRight) {
        _imageViewRight = [self rp_addsubview:[UIImageView class]];
    }
    return _imageViewRight;
}

- (void)leftImageViewTouched
{
    if (_imageViewTouched && _leftImageViewtype != ValidateIDViewUpload) {
        _imageViewTouched(YES);
        _isLeft = YES;
    }
}

- (void)rightImageViewTouched
{
    if (_imageViewTouched &&  _rightImageViewtype != ValidateIDViewUpload) {
        _imageViewTouched(NO);
        _isLeft = NO;
    }
}

- (void)setLeftImageViewtype:(ValidateIDViewType)leftImageViewtype
{
    if (_leftImageViewtype != leftImageViewtype) {
        _leftImageViewtype = leftImageViewtype;
        _isLeft = YES;
        [self refreshViewType:leftImageViewtype];
    }
}

- (void)setRightImageViewtype:(ValidateIDViewType)rightImageViewtype
{
    if (_rightImageViewtype != rightImageViewtype) {
        _rightImageViewtype = rightImageViewtype;
        _isLeft = NO;
        [self refreshViewType:rightImageViewtype];
    }
}

- (void)refreshViewType:(ValidateIDViewType)type
{
    UIView *view;
    switch (type) {
        case ValidateIDViewReady:
            view = [self readyUploadImageView];
            break;
            
        case ValidateIDViewUpload:
            view = [self uploadImageView];
            break;
            
        case ValidateIDViewSuccess:
            view = [self uploadImageView:YES];
            break;
            
        case ValidateIDViewFalie:
            view = [self uploadImageView:NO];
            break;
        case ValidateIDViewPickFinished:
            view = [self pickFinished];
            break;
        default:
            view = [self verifyFaileImageView];
            break;
    }
    
    if (_isLeft) {
        [_imageViewLeft.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.imageViewLeft addSubview:view];
        
    }else {
        [_imageViewRight.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.imageViewRight addSubview:view];
    }
}

- (void)refreshUploadImage:(UIImage *)image
{
    if (_isLeft) {
        self.leftImageViewtype = ValidateIDViewPickFinished;
        [self.imageViewLeft setImage:image];
        
    }else {
        self.rightImageViewtype = ValidateIDViewPickFinished;
        [self.imageViewRight setImage:image];
    }
}

#pragma mark -

- (UIView *)readyUploadImageView
{
    UIView *view = [UIView new];
    view.frame = self.imageViewRight.bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    imageView.image = rpRedpacketBundleImage(@"validate_IDCard_bord");
    [view addSubview:imageView];
    
    UIImageView *upimageView = [[UIImageView alloc] initWithImage:rpRedpacketBundleImage(@"validate_IDCard_upload")];
    [view addSubview:upimageView];
    [upimageView sizeToFit];
    upimageView.center = view.center;
    
    return view;
}

- (UIView *)uploadImageView
{
    UIView *view = [UIView new];
    view.frame = self.imageViewRight.bounds;
    
    UIView *alphaView = [[UIView alloc] initWithFrame:view.bounds];
    alphaView.backgroundColor = [UIColor blackColor];
    alphaView.alpha = .6f;
    [view addSubview:alphaView];
    
    CGFloat y = CGRectGetHeight(view.bounds);
    y = y / 2.0 - 25.0f;
    
    UIActivityIndicatorView *indicate = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicate startAnimating];
    indicate.frame = CGRectMake((CGRectGetWidth(view.bounds) - CGRectGetWidth(indicate.frame)) / 2.0f, y, 20, 20);
    [view addSubview:indicate];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(0, CGRectGetMaxY(indicate.frame) + 5, CGRectGetWidth(view.frame), 36.0f);
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 2;
    titleLabel.text = @"上传中...\n请耐心等待";
    [view addSubview:titleLabel];
    
    return view;
}
- (UIView *)pickFinished
{
    UIView *view = [UIView new];
    view.frame = self.imageViewRight.bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    imageView.image = rpRedpacketBundleImage(@"validate_IDCard_bord");
    [view addSubview:imageView];
    
    return view;
}

- (UIView *)uploadImageView:(BOOL)isSuccess
{
    UIImage *image = isSuccess ? rpRedpacketBundleImage(@"validate_IDCard_upload_success") : rpRedpacketBundleImage(@"validate_IDCard_upload_error");
    NSString *title = isSuccess ? @"上传成功" : @"上传失败\n请重新上传";
    
    return [self uploadImageView:image andText:title];
}

- (UIView *)verifyFaileImageView
{
    UIImage *image = rpRedpacketBundleImage(@"validate_IDCard_upload_error");
    NSString *title = @"审核失败\n请重新上传";
    
    return [self uploadImageView:image andText:title];
}

- (UIView *)uploadImageView:(UIImage *)image andText:(NSString *)text
{
    UIView *view = [UIView new];
    view.frame = self.imageViewRight.bounds;
    
    CGFloat y = CGRectGetHeight(view.bounds);
    y = y / 2.0 - 27.0f;
    
    UIView *alphaView = [[UIView alloc] initWithFrame:view.bounds];
    alphaView.backgroundColor = [UIColor blackColor];
    alphaView.alpha = .6f;
    [view addSubview:alphaView];
    
    UIImageView *indicate = [[UIImageView alloc] initWithImage:image];
    indicate.frame = CGRectMake((CGRectGetWidth(view.bounds) - CGRectGetWidth(indicate.frame)) / 2.0f, y, 22, 22);
    [view addSubview:indicate];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(0, CGRectGetMaxY(indicate.frame) + 5, CGRectGetWidth(view.frame), 36.0f);
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = text;
    [view addSubview:titleLabel];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _isLeft = YES;
    [self refreshViewType:_leftImageViewtype];
    
    _isLeft = NO;
    [self refreshViewType:_rightImageViewtype];
}


@end
