//
//  RCDCreateGroupViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCreateGroupViewController.h"
#import "UIView+MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import "UIImage+RCImage.h"
#import <Masonry/Masonry.h>
#import "RCDGroupManager.h"
#import "RCDUploadManager.h"
#import "RCDForwardManager.h"
#import "NormalAlertView.h"
@interface RCDCreateGroupViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate,
                                            UINavigationControllerDelegate>
@property (nonatomic, strong) UIImageView *groupPortrait;
@property (nonatomic, strong) UITextField *groupName;
@property (nonatomic, strong) NSData *imageData;
@end

@implementation RCDCreateGroupViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviItem];
    [self addSubViews];
    [self registerNotification];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGRect captureRect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        UIImage *captureImage =
            [UIImage getSubImage:originImage Rect:captureRect imageOrientation:originImage.imageOrientation];
        UIImage *scaleImage = [UIImage scaleImage:captureImage toScale:0.8];
        self.imageData = UIImageJPEGRepresentation(scaleImage, 0.00001);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.groupPortrait.image = [UIImage imageWithData:self.imageData];
    ;
}

#pragma mark - Notification action
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve =
        [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         CGRect originalFrame = [UIScreen mainScreen].bounds;
                         if ([self.groupName isFirstResponder] &&
                             CGRectGetMaxY(self.groupName.frame) + [self getNaviAndStatusHeight] >
                                 keyboardBounds.origin.y) {
                             originalFrame.origin.y =
                                 originalFrame.origin.y - (CGRectGetMaxY(self.groupName.frame) +
                                                           [self getNaviAndStatusHeight] - keyboardBounds.origin.y);
                             self.view.frame = originalFrame;
                         }
                         [UIView commitAnimations];
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.5
                     animations:^{
                         [UIView setAnimationCurve:0];
                         CGRect originalFrame = self.view.frame;
                         originalFrame.origin.y = [self getNaviAndStatusHeight];
                         self.view.frame = originalFrame;
                         [UIView commitAnimations];
                     }];
}

#pragma mark - target action
- (void)clickDoneBtn {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.groupName resignFirstResponder];
    NSString *nameStr = [self.groupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self groupNameIsAvailable:nameStr]) {
        if (![self.groupMemberIdList containsObject:[RCIM sharedRCIM].currentUserInfo.userId]) {
            [self.groupMemberIdList addObject:[RCIM sharedRCIM].currentUserInfo.userId];
        }
        [self createGroup];
    }
}

- (void)hideKeyboard:(id)sender {
    [self.groupName resignFirstResponder];
}

#pragma mark - helper
- (void)addSubViews {
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

- (CGFloat)getNaviAndStatusHeight {
    CGFloat navHeight = 44.0f;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    return navHeight + statusBarHeight;
}

- (void)setNaviItem {
    //创建rightBarButtonItem
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:RCDLocalizedString(@"done")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(clickDoneBtn)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)pushToImagePickerController:(UIImagePickerControllerSourceType)sourceType {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = sourceType;
            } else {
                NSLog(@"模拟器无法连接相机");
            }
        } else {
            picker.sourceType = sourceType;
        }
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    });
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
        [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
            targetId:groupId
            content:message.content
            pushContent:nil
            pushData:nil
            success:^(long messageId) {
            }
            error:^(RCErrorCode nErrorCode, long messageId){
            }];
        [NSThread sleepForTimeInterval:0.3];
    }
    [manager forwardEnd];
}

- (void)showAlert:(NSString *)alertContent {
    [NormalAlertView showAlertWithTitle:nil
                                message:alertContent
                          describeTitle:nil
                           confirmTitle:RCDLocalizedString(@"confirm")
                                confirm:^{
                                }];
}

- (void)choosePortrait {
    [self.groupName resignFirstResponder];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *takePictureAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"take_picture")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [self pushToImagePickerController:UIImagePickerControllerSourceTypeCamera];
                               }];
    UIAlertAction *myAlbumAction =
        [UIAlertAction actionWithTitle:RCDLocalizedString(@"my_album")
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *_Nonnull action) {
                                   [self pushToImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
                               }];
    [RCKitUtility showAlertController:nil
                              message:nil
                       preferredStyle:UIAlertControllerStyleActionSheet
                              actions:@[ cancelAction, takePictureAction, myAlbumAction ]
                     inViewController:self];
}

- (BOOL)groupNameIsAvailable:(NSString *)nameStr {
    if ([nameStr length] == 0) {
        //群组名称不存在
        [self showAlert:RCDLocalizedString(@"group_name_can_not_nil")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    } else if ([nameStr length] < 2) {
        //群组名称需要大于2个字
        [self showAlert:RCDLocalizedString(@"Group_name_is_too_short")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    } else if ([nameStr length] > 10) {
        //群组名称需要小于10个字
        [self showAlert:RCDLocalizedString(@"Group_name_cannot_exceed_10_words")];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return NO;
    }
    return YES;
}

- (void)createGroup {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    if ([RCDForwardManager sharedInstance].isForward) {
        hud.labelText = RCDLocalizedString(@"PrepareGroup");
    } else {
        hud.labelText = RCDLocalizedString(@"creating_group");
    }
    [hud show:YES];
    if (self.imageData) {
        [RCDUploadManager uploadImage:self.imageData
                             complete:^(NSString *url) {
                                 [self createGroupWithPortraitUri:url];
                             }];
    } else {
        [self createGroupWithPortraitUri:nil];
    }
}

- (void)createGroupWithPortraitUri:(NSString *)portraitUri {
    NSString *nameStr = [self.groupName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [RCDGroupManager
        createGroup:nameStr
        portraitUri:portraitUri
          memberIds:self.groupMemberIdList
           complete:^(NSString *groupId, RCDGroupAddMemberStatus status) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (groupId) {
                       if (status == RCDGroupAddMemberStatusInviteeApproving) {
                           [self.view showHUDMessage:RCDLocalizedString(@"MemberInviteNeedConfirm")];
                       }

                       if ([RCDForwardManager sharedInstance].isForward) {
                           if ([RCDForwardManager sharedInstance].selectConversationCompleted) {
                               RCConversation *conversation = [[RCConversation alloc] init];
                               conversation.targetId = groupId;
                               conversation.conversationType = ConversationType_GROUP;
                               [RCDForwardManager sharedInstance].selectConversationCompleted([@[ conversation ] copy]);
                               [[RCDForwardManager sharedInstance] forwardEnd];
                           } else {
                               [self sendForwardMessage:groupId];
                           }
                       } else {
                           [self gotoChatView:groupId groupName:nameStr];
                       }
                       //关闭HUD
                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                   } else {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.navigationItem.rightBarButtonItem.enabled = YES;
                           //关闭HUD
                           [MBProgressHUD hideHUDForView:self.view animated:YES];
                           [self showAlert:RCDLocalizedString(@"create_group_fail")];
                       });
                   }
               });
           }];
}

#pragma mark - geter & setter
- (UIImageView *)groupPortrait {
    if (!_groupPortrait) {
        //群组头像的UIImageView
        _groupPortrait = [[UIImageView alloc] init];
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

- (UITextField *)groupName {
    if (!_groupName) {
        _groupName = [[UITextField alloc] init];
        _groupName.font = [UIFont systemFontOfSize:14];
        _groupName.placeholder = RCDLocalizedString(@"type_croup_name_hint");
        _groupName.textAlignment = NSTextAlignmentCenter;
        _groupName.delegate = self;
        _groupName.returnKeyType = UIReturnKeyDone;
        _groupName.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _groupName.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        NSAttributedString *attrString = [[NSAttributedString alloc]
            initWithString:_groupName.placeholder
                attributes:@{
                    NSForegroundColorAttributeName : [UIColor colorWithHexString:@"999999" alpha:1],
                    NSFontAttributeName : _groupName.font
                }];
        _groupName.attributedPlaceholder = attrString;
    }
    return _groupName;
}
@end
