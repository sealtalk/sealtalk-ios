//
//  RCDFriendInvitationTableViewCell.m
//  RCloudMessage
//
//  Created by litao on 15/7/30.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDFriendInvitationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RCDHttpTool.h"
#import "AFHttpTool.h"
#import "RCDataBaseManager.h"
#import "MBProgressHUD.h"

@interface RCDFriendInvitationTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UIView *additionInfo;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;


@end

@implementation RCDFriendInvitationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onAgree:(id)sender {

    __weak __typeof(self)weakSelf = self;
    
    RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)weakSelf.model.content;
    if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId .length ==0) {
        return;
    }
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    hud.labelText = @"添加中...";
    [AFHttpTool processRequestFriend:_contactNotificationMsg.sourceUserId withIsAccess:YES success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"已添加好友！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
            
            [alertView show];
            [weakSelf.acceptButton setEnabled:NO];
        });

    } failure:^(NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"添加失败！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
            [alertView show];
            [weakSelf.acceptButton setEnabled:YES];
        });
    }];
}

- (void)setModel:(RCMessage *)model {
    _model = model;
    if (![model.content isMemberOfClass:[RCContactNotificationMessage class]])
    {
        return;
    }
    RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)model.content;
    self.message.text = _contactNotificationMsg.message;
    if (_contactNotificationMsg.sourceUserId == nil || _contactNotificationMsg.sourceUserId.length == 0) {
        return;
    }
    NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:_contactNotificationMsg.sourceUserId];
    if (_cache_userinfo) {
        self.userName.text = _cache_userinfo[@"username"];
        [self.portrait sd_setImageWithURL:[NSURL URLWithString:_cache_userinfo[@"portraitUri"]] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    } else {
        self.userName.text = [NSString stringWithFormat:@"user<%@>", _contactNotificationMsg.sourceUserId];
        [self.portrait setImage:[UIImage imageNamed:@"icon_person"]];
    }

    __weak RCDFriendInvitationTableViewCell *weakSelf = self;
    RCDUserInfo *_userInfo = [[RCDUserInfo alloc] initWithUserId:_contactNotificationMsg.sourceUserId name:@"" portrait:@""];
    [RCDHTTPTOOL isMyFriendWithUserInfo:_userInfo completion:^(BOOL isFriend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.model.messageId != model.messageId) {
                return ;
            }
            if (isFriend) {
                [weakSelf.acceptButton setEnabled:NO];
            } else {
                [weakSelf.acceptButton setEnabled:YES];
            }
        });
    }];
}
@end
