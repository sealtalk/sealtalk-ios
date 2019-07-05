//
//  RCDCreateGroupViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCreateGroupViewController.h"
#import "DefaultPortraitView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import "UIImage+RCImage.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import "RCDUploadManager.h"
#import "RCDForwardManager.h"
#import "NormalAlertView.h"
@interface RCDCreateGroupViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, strong) UIImageView *groupPortrait;
@property(nonatomic, strong) UITextField *groupName;
@property(nonatomic, strong) NSData *imageData;
@end

@implementation RCDCreateGroupViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviItem];
    [self addSubViews];
    [self registerNotification];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    switch (buttonIndex) {
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                NSLog(@"模拟器无法连接相机");
            }
            [self presentViewController:picker animated:YES completion:nil];
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        UIImage *captureImage = [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        self.imageData = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.groupPortrait.image = [UIImage imageWithData:self.imageData];;
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:curve];
        CGRect originalFrame = [UIScreen mainScreen].bounds;
        if([self.groupName isFirstResponder] && CGRectGetMaxY(self.groupName.frame)+[self getNaviAndStatusHeight] > keyboardBounds.origin.y){
            originalFrame.origin.y = originalFrame.origin.y-(CGRectGetMaxY(self.groupName.frame)+[self getNaviAndStatusHeight]-keyboardBounds.origin.y);
            self.view.frame = originalFrame;
        }
        [UIView commitAnimations];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationCurve:0];
        CGRect originalFrame = self.view.frame;
        originalFrame.origin.y = [self getNaviAndStatusHeight];
        self.view.frame = originalFrame;
        [UIView commitAnimations];
    }];
}

#pragma mark - target action
- (void)clickDoneBtn{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.groupName resignFirstResponder];
    
    NSString *nameStr = [self.groupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self groupNameIsAvailable:nameStr]) {
        if (![self.groupMemberIdList containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
             [self.groupMemberIdList addObject:[RCIM sharedRCIM].currentUserInfo.userId];
        }
        [self createGroup:nameStr];
    }
}

- (void)hideKeyboard:(id)sender {
    [self.groupName resignFirstResponder];
}

#pragma mark - helper
- (void)addSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    //给整个view添加手势，隐藏键盘
    UITapGestureRecognizer *resetBottomTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:resetBottomTapGesture];
    
    UIView *blueLine = [[UIView alloc] init];
    blueLine.backgroundColor = [UIColor colorWithRed:0 green:135 / 255.0 blue:251 / 255.0 alpha:1];
    
    [self.view addSubview:self.groupPortrait];
    [self.view addSubview:self.groupName];
    [self.view addSubview:blueLine];

    [self.groupPortrait mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(80);
        make.width.height.offset(100);
    }];
    
    [self.groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.groupPortrait.mas_bottom).offset(120);
        make.width.offset(200);
        make.height.offset(30);
    }];
    
    [blueLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.groupName.mas_bottom).offset(-5);
        make.width.offset(240);
        make.height.offset(1);
    }];
}

- (CGFloat)getNaviAndStatusHeight{
    CGFloat navHeight = 44.0f;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    return navHeight + statusBarHeight;
}

- (void)setNaviItem{
    //创建rightBarButtonItem
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"done")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(clickDoneBtn)];
    item.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
    self.navigationItem.rightBarButtonItem = item;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)gotoChatView:(NSString *)groupId groupName:(NSString *)groupName {
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] init];
    chatVC.needPopToRootView = YES;
    chatVC.targetId = groupId;
    chatVC.conversationType = ConversationType_GROUP;
    chatVC.userName = groupName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:chatVC animated:YES];
    });
}

- (void)sendForwardMessage:(NSString *)groupId {
    RCDForwardManager *manager = [RCDForwardManager sharedInstance];
    for (RCMessageModel *message in manager.selectedMessages) {
        [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP targetId:groupId content:message.content pushContent:nil pushData:nil success:^(long messageId) {
        } error:^(RCErrorCode nErrorCode, long messageId) {
        }];
        [NSThread sleepForTimeInterval:0.3];
    }
    [manager forwardEnd];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil message:alertContent describeTitle:nil confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
    }];
}

- (void)choosePortrait {
    [self.groupName resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:RCDLocalizedString(@"cancel")
                                  
                                               destructiveButtonTitle:RCDLocalizedString(@"take_picture")
                                  
                                                    otherButtonTitles:RCDLocalizedString(@"my_album"), nil];
    [actionSheet showInView:self.view];
}

- (NSString *)createDefaultPortrait:(NSString *)groupId groupName:(NSString *)groupName {
    UIImage *portrait = [DefaultPortraitView portraitView:groupId name:groupName];
    NSString *filePath = [self getIconCachePath:[NSString stringWithFormat:@"group%@.png", groupId]];
    BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath atomically:YES];
    if (result == YES) {
        NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
        return [portraitPath absoluteString];
    }
    return nil;
}

- (NSString *)getIconCachePath:(NSString *)fileName {
    NSString *cachPath =
    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath =
    [cachPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CachedIcons/%@",
                                              fileName]]; // 保存文件的名称
    NSString *dirPath = [cachPath stringByAppendingPathComponent:[NSString stringWithFormat:@"CachedIcons"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dirPath]) {
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

- (BOOL)groupNameIsAvailable:(NSString *)nameStr{
    if ([nameStr length] == 0) {
        //群组名称不存在
        [self showAlert:RCDLocalizedString(@"group_name_can_not_nil")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    }else if ([nameStr length] < 2) {
        //群组名称需要大于2个字
        [self showAlert:RCDLocalizedString(@"Group_name_is_too_short")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    }else if ([nameStr length] > 10) {
        //群组名称需要小于10个字
        [self showAlert:RCDLocalizedString(@"Group_name_cannot_exceed_10_words")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    }
    return YES;
}

- (void)createGroup:(NSString *)nameStr{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    if ([RCDForwardManager sharedInstance].isForward) {
        hud.labelText = RCDLocalizedString(@"PrepareGroup");
    } else {
        hud.labelText = RCDLocalizedString(@"creating_group");
    }
    [hud show:YES];
    [RCDGroupManager createGroup:nameStr memberIds:self.groupMemberIdList complete:^(NSString * groupId) {
        if (groupId) {
            if (self.imageData) {
                [RCDUploadManager uploadImage:self.imageData complete:^(NSString *url) {
                    if (url.length > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [RCDGroupManager setGroupPortrait:url groupId:groupId complete:^(BOOL success) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (success == YES) {
                                        if ([RCDForwardManager sharedInstance].isForward) {
                                            [self sendForwardMessage:groupId];
                                        } else {
                                            [self gotoChatView:groupId groupName:nameStr];
                                        }
                                        //关闭HUD
                                        [hud hide:YES];
                                    }else{
                                        self.navigationItem.rightBarButtonItem.enabled = YES; //关闭HUD
                                        [hud hide:YES];
                                        [self showAlert:RCDLocalizedString(@"create_group_fail")];
                                    }
                                });
                            }];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.navigationItem.rightBarButtonItem.enabled = YES;
                            //关闭HUD
                            [hud hide:YES];
                            [self showAlert:RCDLocalizedString(@"create_group_fail")];
                        });
                    }
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    if ([RCDForwardManager sharedInstance].isForward) {
                        [self sendForwardMessage:groupId];
                    } else {
                        [self gotoChatView:groupId groupName:nameStr];
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [self showAlert:RCDLocalizedString(@"create_group_fail")];
            });
        }
    }];
}

#pragma mark - geter & setter
- (UIImageView *)groupPortrait{
    if (!_groupPortrait) {
        //群组头像的UIImageView
        _groupPortrait = [[UIImageView alloc]init];
        _groupPortrait.image = [UIImage imageNamed:@"AddPhotoDefault"];
        _groupPortrait.layer.masksToBounds = YES;
        _groupPortrait.layer.cornerRadius = 5.f;
        //为头像设置点击事件
        _groupPortrait.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleClick =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePortrait)];
        [_groupPortrait addGestureRecognizer:singleClick];
    }
    return _groupPortrait;
}

-(UITextField *)groupName{
    if (!_groupName) {
        _groupName = [[UITextField alloc] init];
        _groupName.font = [UIFont systemFontOfSize:14];
        _groupName.placeholder = RCDLocalizedString(@"type_croup_name_hint");
        _groupName.textAlignment = NSTextAlignmentCenter;
        _groupName.delegate = self;
        _groupName.returnKeyType = UIReturnKeyDone;
    }
    return _groupName;
}
@end
