//
//  RCDPersonDetailViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/4/9.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RCUserInfo.h>
#import "RCDUserInfo.h"

@interface RCDPersonDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property(nonatomic, strong) NSString *userId;
@property(weak, nonatomic) IBOutlet UILabel *lblName;
@property(weak, nonatomic) IBOutlet UIImageView *ivAva;
@property(weak, nonatomic) IBOutlet UIButton *conversationBtn;
@property(weak, nonatomic) IBOutlet UIButton *audioCallBtn;
@property(weak, nonatomic) IBOutlet UIButton *videoCallBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@end
