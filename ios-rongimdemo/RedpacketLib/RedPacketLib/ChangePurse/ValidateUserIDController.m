//
//  ValidateUserIDController.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/6/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "ValidateUserIDController.h"
//#import "ValidateIDView.h"
#import "RPValidateIdView.h"
#import "RedpacketColorStore.h"
#import "UIAlertView+YZHAlert.h"
#import "RedpacketDataRequester.h"
#import "NSBundle+RedpacketBundle.h"


@interface ValidateUserIDController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong)  RPValidateIdView *headerView;
@property (nonatomic, assign)  BOOL isLeft;

@property (nonatomic, assign)  BOOL isLeftUploadSuccess;
@property (nonatomic, assign)  BOOL isRightUploadSuccess;

@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *rightImage;

@property (nonatomic, assign) UIButton *confirmButton;


@end

@implementation ValidateUserIDController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [RedpacketColorStore rp_backGroundColor];
    
    self.titleLable.text = @"验证身份";
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor  = [RedpacketColorStore rp_backGroundColor];
    _headerView = [[RPValidateIdView alloc]init];
//    _headerView = [[[NSBundle RedpacketBundle] loadNibNamed:NSStringFromClass([ValidateIDView class]) owner:self options:nil] lastObject];
    
    /*
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _headerView.rp_width = width;
    if (width >= 414) {
        _headerView.rp_height = 200.0f;
    }else if (width >= 375){
        _headerView.rp_height = 180.0f;
    }
    
    [_headerView updateConstraintsIfNeeded];
    */
    
    self.tableView.tableHeaderView = _headerView;
    rpWeakSelf;
    [_headerView setImageViewTouched:^(BOOL isLeft) {
        [weakSelf showActionSheet];
        weakSelf.isLeft = isLeft;
        
    }];
}

- (void)uploadImage
{
    if (_rightImage && _leftImage) {
        [self.view rp_showHudWaitingView:YZHPromptTypeWating];
        rpWeakSelf;
        RedpacketDataRequester *requset = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
            [weakSelf alertWithWatingReview];
            
        } andFaliureBlock:^(NSString *error, NSInteger code) {
            [weakSelf.view rp_showHudErrorView:error];
            
        }];
        
        [requset uploadUserIDPhoto:_rightImage andImageOtherSide:_leftImage];
    }
}

- (void)showActionSheet
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加照片" message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camerAction = [UIAlertAction actionWithTitle:@"来自相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showImagePicker:YES];
        }];
        
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"来自照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showImagePicker:NO];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:camerAction];
        [alertController addAction:libraryAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"添加照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相机", @"来自照片", nil];
        [action showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self showImagePicker:YES];
        
    }else if (buttonIndex == 1) {
        [self showImagePicker:NO];
        
    }else {
        
    }
}

- (void)showImagePicker:(BOOL)isCamer
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    if (isCamer) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    if (!isCamer || [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (UIView *)cameraOverlayView
{
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    
    return view;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo
{
    if (_headerView.isLeft) {
        _leftImage = image;
    }else {
        _rightImage = image;
    }
    
    if (_rightImage && _leftImage) {
        self.confirmButton.enabled = YES;
    }
    
    [self.headerView refreshUploadImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 45)];
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(15, 15, 200, 15);
    titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    if (section == 0) {
        titleLabel.text = @"身份证照片要求";
    }else {
        titleLabel.text = @"拍摄示例";
    }
    
    CGFloat height = 1 / [UIScreen mainScreen].scale;
    
    [view addSubview:titleLabel];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 45 - height, CGRectGetWidth(self.view.frame) - 15, height)];
    line.backgroundColor = [RedpacketColorStore rp_lineColorLightGray];
    [view addSubview:line];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.rp_width, 0)];
    
    CGFloat height = 25.0f;
    if (_isValidateFalid) {
        UILabel *textlabel = [UILabel new];
        textlabel.font = [UIFont systemFontOfSize:15.0f];
        textlabel.textColor = [RedpacketColorStore rp_textColorRed];
        textlabel.frame = CGRectMake(15, height, CGRectGetWidth(self.view.frame) - 30, 40);
        textlabel.textAlignment = NSTextAlignmentCenter;
        textlabel.text = _validateMsg;
        [view addSubview:textlabel];
        
        height += textlabel.rp_height + 10;
    }
    
    UIButton *button = [self submitButton];
    [button setTitle:@"提交审核" forState:UIControlStateNormal];
    button.rp_top = height;
    [view addSubview:button];
    
    view.rp_height = height + button.rp_height + 15.0f;
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        BOOL isError = YES;
        if (isError) {
            return 134.0f;
        }
        
        return 84;
    }
    
    return .01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 64.0f;
        
    }else {
        UIImageView *image  = [UIImageView new];
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.image = rpRedpacketBundleImage(@"validate_idCard");
        CGSize size = [image sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 30.0f, NSIntegerMax)];
        return size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"需要本人有效二代身份证进行身份认证;\n拍摄时确保身份证边框完整，字体清晰，亮度均匀;";
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.textLabel.textColor = [RedpacketColorStore rp_textColorBlack6];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    }else {
        return [self imageCell];
    }
    
}

- (void)submitButtonClicked
{
    [self uploadImage];
}

#pragma mark - 

- (void)alertWithWatingReview
{
    if (_finishBlock) {
        _finishBlock();
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"上传成功，请等待审核" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    [alert setRp_completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert show];
}

#pragma mark - Views

- (UITableViewCell *)imageCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *image  = [UIImageView new];
    image.contentMode = UIViewContentModeScaleAspectFit;
    image.image = rpRedpacketBundleImage(@"validate_idCard");
    CGSize size = [image sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 30.0f, NSIntegerMax)];
    image.frame = CGRectMake(15, 15, CGRectGetWidth(self.view.bounds) - 30.0f, size.height);
    
    [cell.contentView addSubview:image];
    
    return cell;
}

- (UIButton *)submitButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton = button;
    button.frame = CGRectMake(15, 0, CGRectGetWidth(self.view.frame) - 30, 44);
    button.layer.cornerRadius = 3.0f;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:[self createImageWithColor:[RedpacketColorStore rp_blueButtonNormalColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self createImageWithColor:[RedpacketColorStore rp_blueButtonHightColor]] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self createImageWithColor:[RedpacketColorStore rp_blueDisableColor]] forState:UIControlStateDisabled];
    button.enabled = NO;
    
    return button;
}

- (UIImage *)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end
