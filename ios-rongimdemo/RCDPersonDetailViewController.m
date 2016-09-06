//
//  RCDPersonDetailViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/9.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDPersonDetailViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDChatViewController.h"
#import "RCDHttpTool.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import <RongCallKit/RongCallKit.h>
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RCUserInfo.h>
#import "UIColor+RCColor.h"
#import "RCDFrienfRemarksViewController.h"

@interface RCDPersonDetailViewController () <UIActionSheetDelegate>
@property(nonatomic) BOOL inBlackList;
@property(nonatomic, strong) NSDictionary *subViews;
@property(nonatomic, strong) RCDUserInfo *friendInfo;
@property(nonatomic, strong) NSArray *constraintNameLabel;
@property(nonatomic, strong) UILabel *displayNameLabel;
@end

@implementation RCDPersonDetailViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [self setLayout];

  NSString *portraitUri;
  
  if (![self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    self.friendInfo = [[RCDataBaseManager shareInstance] getFriendInfo:self.userId];
    portraitUri = self.friendInfo.portraitUri;
    [self setLayoutForFriend];
    NSString *remarks = self.friendInfo.displayName;
    self.displayNameLabel = [[UILabel alloc] init];
    if (remarks != nil && ![remarks isEqualToString:@""]) {
      [self setLayoutIsHaveRemarks:YES];
    } else {
      [self setLayoutIsHaveRemarks:NO];
    }
  } else {
    portraitUri = [RCIM sharedRCIM].currentUserInfo.portraitUri;
    [self setLayoutForSelf];
  }
  self.lblName.font = [UIFont systemFontOfSize:16.f];
  self.lblName.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
  if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
      [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 30.f;
  } else {
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 5.f;
  }
  
  if (portraitUri.length == 0) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:self.friendInfo.userId
                             Nickname:self.friendInfo.name];
    UIImage *portrait = [defaultPortrait imageFromView];
    self.ivAva.image = portrait;
  } else {
    [self.ivAva
        sd_setImageWithURL:[NSURL URLWithString:portraitUri]
          placeholderImage:[UIImage imageNamed:@"icon_person"]];
  }

  __weak RCDPersonDetailViewController *weakSelf = self;
  [[RCIMClient sharedRCIMClient] getBlacklistStatus:self.friendInfo.userId
      success:^(int bizStatus) {
        weakSelf.inBlackList = (bizStatus == 0);

      }
      error:^(RCErrorCode status) {
        NSArray *array = [[RCDataBaseManager shareInstance] getBlackList];
        for (RCUserInfo *blackInfo in array) {
          if ([blackInfo.userId isEqualToString:weakSelf.friendInfo.userId]) {
            weakSelf.inBlackList = YES;
          }
        }
      }];

  self.conversationBtn.layer.borderWidth = 0.5;
  self.audioCallBtn.layer.borderWidth = 0.5;
  self.videoCallBtn.layer.borderWidth = 0.5;

  self.conversationBtn.layer.borderColor = [HEXCOLOR(0x0181dd) CGColor];
  self.audioCallBtn.layer.borderColor = [HEXCOLOR(0xc9c9c9) CGColor];
  self.videoCallBtn.layer.borderColor = [HEXCOLOR(0xc9c9c9) CGColor];
}

- (void)viewWillAppear:(BOOL)animated
{
  if (![self.userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
    self.friendInfo = [[RCDataBaseManager shareInstance] getFriendInfo:self.userId];
    NSString *remarks = self.friendInfo.displayName;
    if (remarks != nil && ![remarks isEqualToString:@""]) {
      [self setLayoutIsHaveRemarks:YES];
    } else {
      [self setLayoutIsHaveRemarks:NO];
    }
  }
}

- (IBAction)btnConversation:(id)sender {
  //创建会话
  RCDChatViewController *chatViewController =
      [[RCDChatViewController alloc] init];
  chatViewController.conversationType = ConversationType_PRIVATE;
  
  chatViewController.targetId = self.userId;
  chatViewController.title = self.lblName.text;
  chatViewController.needPopToRootView = YES;
  chatViewController.displayUserNameInCell = NO;
  [self.navigationController pushViewController:chatViewController
                                       animated:YES];
}

- (IBAction)btnVoIP:(id)sender {
  //语音通话
  [[RCCall sharedRCCall] startSingleCall:self.friendInfo.userId
                               mediaType:RCCallMediaAudio];
}

- (IBAction)btnVideoCall:(id)sender {
  //视频通话
  [[RCCall sharedRCCall] startSingleCall:self.friendInfo.userId
                               mediaType:RCCallMediaVideo];
}

- (void)rightBarButtonItemClicked:(id)sender {

  if (self.inBlackList) {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"取消黑名单", nil];
    [actionSheet showInView:self.view];
  } else {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"加入黑名单", nil];
    [actionSheet showInView:self.view];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
  case 0: {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    //黑名单
    __weak RCDPersonDetailViewController *weakSelf = self;
    if (!self.inBlackList) {
      hud.labelText = @"正在加入黑名单";
      [[RCIMClient sharedRCIMClient] addToBlacklist:self.friendInfo.userId
          success:^{
            weakSelf.inBlackList = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
            });
            [[RCDataBaseManager shareInstance]
                insertBlackListToDB:weakSelf.friendInfo];

          }
          error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
              UIAlertView *alertView =
                  [[UIAlertView alloc] initWithTitle:nil
                                             message:@"加入黑名单失败"
                                            delegate:nil
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil, nil];
              [alertView show];
            });

            weakSelf.inBlackList = NO;
          }];
    } else {
      hud.labelText = @"正在从黑名单移除";
      [[RCIMClient sharedRCIMClient] removeFromBlacklist:self.friendInfo.userId
          success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
            });
            [[RCDataBaseManager shareInstance]
                removeBlackList:weakSelf.userId];

            weakSelf.inBlackList = NO;
          }
          error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [hud hide:YES];
              UIAlertView *alertView =
                  [[UIAlertView alloc] initWithTitle:nil
                                             message:@"从黑名单移除失败"
                                            delegate:nil
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil, nil];
              [alertView show];
            });

            weakSelf.inBlackList = YES;
          }];
    }

  } break;
  }
}

- (void)setLayout
{
  
  
  self.subViews = NSDictionaryOfVariableBindings(_infoView,_ivAva,_bottomLine);
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_infoView(86.5)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:self.subViews]];
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_ivAva(65)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:self.subViews]];
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_ivAva(65)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:self.subViews]];
  
  [self.view
   addConstraint:[NSLayoutConstraint
                  constraintWithItem:_bottomLine
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:_infoView
                  attribute:NSLayoutAttributeBottom
                  multiplier:1
                  constant:0]];
  [self.view bringSubviewToFront:_bottomLine];
  
}

- (void)setLayoutForFriend
{
  self.videoCallBtn.hidden = NO;
  self.audioCallBtn.hidden = NO;
  
  UIView *remarksView = [[UIView alloc] init];
  remarksView.translatesAutoresizingMaskIntoConstraints = NO;
  remarksView.userInteractionEnabled = YES;
  remarksView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:remarksView];
  
  UITapGestureRecognizer *clickRemarksView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(gotoRemarksView:)];
  [remarksView addGestureRecognizer:clickRemarksView];
  
  UILabel *remarkLabel = [[UILabel alloc] init];
  remarkLabel.font = [UIFont systemFontOfSize:16.f];
  remarkLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
  remarkLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [remarksView addSubview:remarkLabel];
  remarkLabel.text = @"设置备注";
  
  UIImageView *rightArrow = [[UIImageView alloc] init];
  rightArrow.translatesAutoresizingMaskIntoConstraints = NO;
  rightArrow.image = [UIImage imageNamed:@"right_arrow"];
  [remarksView addSubview:rightArrow];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                            initWithImage:[UIImage imageNamed:@"config"]
                                            style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(rightBarButtonItemClicked:)];
  
  self.subViews = NSDictionaryOfVariableBindings(_infoView,_conversationBtn,remarksView);
  NSDictionary *remarksSubViews = NSDictionaryOfVariableBindings(remarkLabel,rightArrow);
  
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoView]-15-[remarksView(44)]-15-[_conversationBtn]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:self.subViews]];
  
  [self.view
   addConstraint:[NSLayoutConstraint
                  constraintWithItem:remarksView
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:_infoView
                  attribute:NSLayoutAttributeWidth
                  multiplier:1
                  constant:0]];
  
  [remarksView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[remarkLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:remarksSubViews]];
  
  [remarksView
   addConstraint:[NSLayoutConstraint
                  constraintWithItem:remarkLabel
                  attribute:NSLayoutAttributeCenterY
                  relatedBy:NSLayoutRelationEqual
                  toItem:remarksView
                  attribute:NSLayoutAttributeCenterY
                  multiplier:1
                  constant:0]];
  
  [remarksView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightArrow]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:remarksSubViews]];
  
  [remarksView
   addConstraint:[NSLayoutConstraint
                  constraintWithItem:rightArrow
                  attribute:NSLayoutAttributeCenterY
                  relatedBy:NSLayoutRelationEqual
                  toItem:remarksView
                  attribute:NSLayoutAttributeCenterY
                  multiplier:1
                  constant:0]];
}

- (void)setLayoutForSelf
{
  if (self.constraintNameLabel != nil) {
    [self.infoView removeConstraints:self.constraintNameLabel];
  }
  self.subViews = NSDictionaryOfVariableBindings(_infoView,_conversationBtn);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoView]-15-[_conversationBtn]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:self.subViews]];
  self.constraintNameLabel =@[[NSLayoutConstraint
                                 constraintWithItem:self.lblName
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.infoView
                                 attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                 constant:0]];
  self.lblName.text = [RCIM sharedRCIM].currentUserInfo.name;
  [self.infoView
   addConstraints:self.constraintNameLabel];
  [self.view setNeedsUpdateConstraints];
  [self.view updateConstraintsIfNeeded];
  [self.view layoutIfNeeded];
}

- (void)setLayoutIsHaveRemarks:(BOOL)isHaveRemarks
{
  if (self.constraintNameLabel != nil) {
    [self.infoView removeConstraints:self.constraintNameLabel];
  }
  if (isHaveRemarks == YES) {
    self.constraintNameLabel =@[[NSLayoutConstraint
                                   constraintWithItem:self.lblName
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.ivAva
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1
                                   constant:13.5]];
    self.displayNameLabel.hidden = NO;
    self.displayNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.displayNameLabel.font = [UIFont systemFontOfSize:12.f];
    self.displayNameLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.f];
    [self.infoView addSubview:self.displayNameLabel];
    self.displayNameLabel.text = [NSString stringWithFormat:@"昵称: %@",self.friendInfo.name];
    self.lblName.text = self.friendInfo.displayName;
    [self.infoView
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.displayNameLabel
                    attribute:NSLayoutAttributeBottom
                    relatedBy:NSLayoutRelationEqual
                    toItem:self.ivAva
                    attribute:NSLayoutAttributeBottom
                    multiplier:1
                    constant:-13.5]];
    
    [self.infoView
     addConstraint:[NSLayoutConstraint
                    constraintWithItem:self.displayNameLabel
                    attribute:NSLayoutAttributeLeft
                    relatedBy:NSLayoutRelationEqual
                    toItem:self.lblName
                    attribute:NSLayoutAttributeLeft
                    multiplier:1
                    constant:0]];
  } else {
    self.displayNameLabel.text = @"";
    self.constraintNameLabel =@[[NSLayoutConstraint
                                   constraintWithItem:self.lblName
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.infoView
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1
                                   constant:0]];
    self.lblName.text = self.friendInfo.name;
  }
  [self.infoView
   addConstraints:self.constraintNameLabel];
  [self.view setNeedsUpdateConstraints];
  [self.view updateConstraintsIfNeeded];
  [self.view layoutIfNeeded];
}

- (void)gotoRemarksView:(id)sender
{
  RCDFrienfRemarksViewController *vc = [[RCDFrienfRemarksViewController alloc] init];
  vc.friendInfo = self.friendInfo;
  [self.navigationController pushViewController:vc animated:YES];
}

@end
