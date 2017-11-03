//
//  RCDPersonDetailViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/4/9.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUserInfo.h"
#import <RongIMLib/RCUserInfo.h>
#import <UIKit/UIKit.h>

@interface RCDPersonDetailViewController : UIViewController

@property(nonatomic, strong) UIView *infoView;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) UILabel *lblName;
@property(nonatomic, strong) UIImageView *ivAva;
@property(nonatomic, strong) UIButton *conversationBtn;
@property(nonatomic, strong) UIButton *audioCallBtn;
@property(nonatomic, strong) UIButton *videoCallBtn;
@property(nonatomic, strong) UIView *bottomLine;

@end
