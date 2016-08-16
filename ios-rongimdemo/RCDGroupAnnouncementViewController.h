//
//  RCDGroupAnnouncementViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextViewAndPlaceholder.h"

@interface RCDGroupAnnouncementViewController : UIViewController<UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITextViewAndPlaceholder *AnnouncementContent;

@property (nonatomic, strong) NSString *GroupId;

@end
