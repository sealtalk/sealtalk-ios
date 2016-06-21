//
//  RCDAddFriendViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/4/16.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RCUserInfo.h>

@interface RCDAddFriendViewController : UIViewController

@property (nonatomic,strong) RCUserInfo *targetUserInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *ivAva;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIButton *startChat;

@end
