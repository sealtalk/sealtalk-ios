//
//  RCDCreateGroupViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDCreateGroupViewController
    : UIViewController <UITextFieldDelegate, UIActionSheetDelegate,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate>
@property(weak, nonatomic) IBOutlet UIImageView *GroupPortrait;
@property(weak, nonatomic) IBOutlet UITextField *GroupName;
@property(weak, nonatomic) IBOutlet UIButton *DoneBtn;
@property(strong, nonatomic) NSMutableArray *GroupMemberIdList;
- (IBAction)ClickDoneBtn:(id)sender;

@end
