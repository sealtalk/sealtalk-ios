//
//  RCDCreateGroupViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCreateGroupViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDGroupMemberCollectionViewCell.h"
#import "RCDHttpTool.h"
#import "RCDUserInfo.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>
#import "UIColor+RCColor.h"

// 是否iPhone5
#define isiPhone5                                                              \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(640, 1136),                              \
                           [[UIScreen mainScreen] currentMode].size)           \
       : NO)
// 是否iPhone4
#define isiPhone4                                                              \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
       ? CGSizeEqualToSize(CGSizeMake(640, 960),                               \
                           [[UIScreen mainScreen] currentMode].size)           \
       : NO)

@interface RCDCreateGroupViewController () {
  NSData *data;
  UIImage *image;
  //    NSMutableArray *memberIdsList;
  MBProgressHUD *hud;
  CGFloat deafultY;
}

@end

@implementation RCDCreateGroupViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.DoneBtn.hidden = YES;

  self.GroupPortrait.layer.masksToBounds = YES;
  self.GroupPortrait.layer.cornerRadius = 5.f;

  //为头像设置点击事件
  self.GroupPortrait.userInteractionEnabled = YES;
  UITapGestureRecognizer *singleClick =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(chosePortrait)];
  [self.GroupPortrait addGestureRecognizer:singleClick];

  //    //动态取邀请成员的数量
  //    NSInteger membersCount = [self.GroupMemberList count];
  //    self.InviteMemberCount.text = [NSString
  //    stringWithFormat:@"被邀请成员(%ld)",(long)membersCount];
  //
  //    self.GroupMembers.backgroundColor = [UIColor clearColor];
  //
  //    memberIdsList = [[NSMutableArray alloc] init];

  _GroupName.delegate = self;
  _GroupName.returnKeyType = UIReturnKeyDone;

  UITapGestureRecognizer *resetBottomTapGesture =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(hideKeyboard:)];
  [self.view addGestureRecognizer:resetBottomTapGesture];

  UIBarButtonItem *item =
      [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(ClickDoneBtn:)];
  item.tintColor = [RCIM sharedRCIM].globalNavigationBarTintColor;
  self.navigationItem.rightBarButtonItem = item;

  deafultY = self.navigationController.navigationBar.frame.size.height +
             [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (isiPhone5) {
    [self moveView:-40];
  }
  if (isiPhone4) {
    [self moveView:-80];
  }
  return YES;
}

//#pragma mark - UICollectionView Delegate
//- (NSInteger)collectionView:(UICollectionView *)collectionView
//numberOfItemsInSection:(NSInteger)section;
//{
//    return [self.GroupMemberList count];
//}
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
//cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"RCDGroupMemberCollectionViewCell";
//    RCDGroupMemberCollectionViewCell *cell = (RCDGroupMemberCollectionViewCell
//    *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
//    forIndexPath:indexPath];
//    RCUserInfo *user = [self.GroupMemberList objectAtIndex:indexPath.row];
//    cell.NicknameLabel.text = user.name;
//    [cell.NicknameLabel
//     setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
//    if ([RCIM sharedRCIM].globalConversationAvatarStyle ==
//    RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle ==
//    RC_USER_AVATAR_CYCLE) {
//        cell.PortraitImageView.layer.masksToBounds = YES;
//        cell.PortraitImageView.layer.cornerRadius = 20.f;
//    }
//    else
//    {
//        cell.PortraitImageView.layer.masksToBounds = YES;
//        cell.PortraitImageView.layer.cornerRadius = 5.f;
//    }
//
//    if ([user.portraitUri isEqualToString:@""]) {
//        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
//        initWithFrame:CGRectMake(0, 0, 100, 100)];
//        [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
//        UIImage *portrait = [defaultPortrait imageFromView];
//        cell.PortraitImageView.image = portrait;
//    }
//    else
//    {
//
//        [cell.PortraitImageView sd_setImageWithURL:[NSURL
//        URLWithString:user.portraitUri] placeholderImage:[UIImage
//        imageNamed:@"icon_person"]];
//    }
//    [memberIdsList addObject:user.userId];
//    return cell;
//}

- (IBAction)ClickDoneBtn:(id)sender {
  self.navigationItem.rightBarButtonItem.enabled = NO;
  [self moveView:deafultY];
  [_GroupName resignFirstResponder];

  NSString *nameStr = [self.GroupName.text copy];
  nameStr = [nameStr
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

  //群组名称需要大于2位
  if ([nameStr length] == 0) {
    [self Alert:@"群组名称不能为空"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
  //群组名称需要大于2个字
  else if ([nameStr length] < 2) {
    [self Alert:@"群组名称过短"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
  //群组名称需要小于10个字
  else if ([nameStr length] > 10) {
    [self Alert:@"群组名称不能超过10个字"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  } else {
    BOOL isAddedcurrentUserID = false;
    for (NSString *userId in _GroupMemberIdList) {
      if ([userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        isAddedcurrentUserID = YES;
      } else {
        isAddedcurrentUserID = NO;
      }
    }
    if (isAddedcurrentUserID == NO) {
      [_GroupMemberIdList addObject:[RCIM sharedRCIM].currentUserInfo.userId];
    }

    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
    hud.labelText = @"创建中...";
    [hud show:YES];

    [[RCDHttpTool shareInstance]
        createGroupWithGroupName:nameStr
                 GroupMemberList:_GroupMemberIdList
                        complete:^(NSString *groupId) {

                          if (groupId) {
                            if (image != nil) {
                              [RCDHTTPTOOL
                                  uploadImageToQiNiu:[RCIM sharedRCIM]
                                                         .currentUserInfo.userId
                                  ImageData:data
                                  success:^(NSString *url) {
                                    RCGroup *groupInfo = [RCGroup new];
                                    groupInfo.portraitUri = url;
                                    groupInfo.groupId = groupId;
                                    groupInfo.groupName = nameStr;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      [RCDHTTPTOOL
                                          setGroupPortraitUri:url
                                                      groupId:groupId
                                                     complete:^(BOOL result) {
                                                       [[RCIM sharedRCIM]
                                                           refreshGroupInfoCache:
                                                               groupInfo
                                                                     withGroupId:
                                                                         groupId];
                                                       if (result == YES) {

                                                         [self.navigationController
                                                             popToRootViewControllerAnimated:
                                                                 YES]; //关闭HUD
                                                         [hud hide:YES];
                                                       }
                                                       if (result == NO) {
                                                         self.navigationItem
                                                             .rightBarButtonItem
                                                             .enabled =
                                                             YES; //关闭HUD
                                                         [hud hide:YES];
                                                         [self Alert:@"创"
                                                                     @"建群组"
                                                                     @"失败，"
                                                                     @"请检查"
                                                                     @"你的网"
                                                                     @"络设置"
                                                                     @"。"];
                                                       }
                                                     }];
                                    });

                                  }
                                  failure:^(NSError *err) {
                                    self.navigationItem.rightBarButtonItem
                                        .enabled = YES;
                                    //关闭HUD
                                    [hud hide:YES];
                                    [self Alert:@"创"
                                                @"建群组失败，请检查你的网络设"
                                                @"置。"];
                                  }];
                            } else {

                              RCGroup *groupInfo = [RCGroup new];
                              groupInfo.portraitUri =
                                  [self createDefaultPortrait:groupId
                                                    GroupName:nameStr];
                              groupInfo.groupId = groupId;
                              groupInfo.groupName = nameStr;
                              [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo
                                                           withGroupId:groupId];
                              [self.navigationController
                                  popToRootViewControllerAnimated:YES];
                            }
                          } else {
                            [hud hide:YES];
                            self.navigationItem.rightBarButtonItem.enabled =
                                YES;
                            [self Alert:@"创"
                                        @"建群组失败，请检查你的网络设置。"];
                          }
                        }];
  }
}

- (void)Alert:(NSString *)alertContent {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:alertContent
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)chosePortrait {
  [self moveView:deafultY];
  [_GroupName resignFirstResponder];
  UIActionSheet *actionSheet =
      [[UIActionSheet alloc] initWithTitle:nil
                                  delegate:self
                         cancelButtonTitle:@"取消"
                    destructiveButtonTitle:@"拍照"
                         otherButtonTitles:@"我的相册", nil];
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    didDismissWithButtonIndex:(NSInteger)buttonIndex {
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.allowsEditing = YES;
  picker.delegate = self;

  switch (buttonIndex) {
  case 0:
    if ([UIImagePickerController
            isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [UIApplication sharedApplication].statusBarHidden = NO;

  NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

  if ([mediaType isEqual:@"public.image"]) {
    UIImage *originImage =
        [info objectForKey:UIImagePickerControllerEditedImage];

    UIImage *scaleImage = [self scaleImage:originImage toScale:0.8];

    //        if (UIImagePNGRepresentation(scaleImage) == nil)
    //        {
    //            data = UIImageJPEGRepresentation(scaleImage, 0.00001);
    //        }
    //        else
    //        {
    //            data = UIImagePNGRepresentation(scaleImage);
    //        }
    data = UIImageJPEGRepresentation(scaleImage, 0.00001);
  }

  image = [UIImage imageWithData:data];
  [self dismissViewControllerAnimated:YES completion:nil];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.GroupPortrait.image = image;
  });
}

- (UIImage *)scaleImage:(UIImage *)Image toScale:(float)scaleSize {
  UIGraphicsBeginImageContext(
      CGSizeMake(Image.size.width * scaleSize, Image.size.height * scaleSize));
  [Image drawInRect:CGRectMake(0, 0, Image.size.width * scaleSize,
                               Image.size.height * scaleSize)];
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return scaledImage;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [_GroupName resignFirstResponder];
  [self moveView:deafultY];
  return YES;
}

- (void)hideKeyboard:(id)sender {
  [self moveView:deafultY];
  [_GroupName resignFirstResponder];
}

//移动屏幕
- (void)moveView:(CGFloat)Y {

  [UIView beginAnimations:nil context:nil];
  self.view.frame =
      CGRectMake(0, Y, self.view.frame.size.width, self.view.frame.size.height);
  [UIView commitAnimations];
}

- (NSString *)createDefaultPortrait:(NSString *)groupId
                          GroupName:(NSString *)groupName {
  DefaultPortraitView *defaultPortrait =
      [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  [defaultPortrait setColorAndLabel:groupId Nickname:groupName];
  UIImage *portrait = [defaultPortrait imageFromView];

  NSString *filePath = [self
      getIconCachePath:[NSString stringWithFormat:@"group%@.png", groupId]];

  BOOL result =
      [UIImagePNGRepresentation(portrait) writeToFile:filePath atomically:YES];
  if (result == YES) {
    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
    return [portraitPath absoluteString];
  }
  return nil;
}

- (NSString *)getIconCachePath:(NSString *)fileName {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0]
      stringByAppendingPathComponent:
          [NSString
              stringWithFormat:@"CachedIcons/%@", fileName]]; // 保存文件的名称

  NSString *dirPath = [[paths objectAtIndex:0]
      stringByAppendingPathComponent:[NSString
                                         stringWithFormat:@"CachedIcons"]];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:dirPath]) {
    [fileManager createDirectoryAtPath:dirPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
  }
  return filePath;
}
@end
