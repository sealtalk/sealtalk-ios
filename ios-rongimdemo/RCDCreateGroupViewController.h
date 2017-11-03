//
//  RCDCreateGroupViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDCreateGroupViewController
    : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate>

+ (instancetype)createGroupViewController;

@property(nonatomic, strong) UIImageView *GroupPortrait;
@property(nonatomic, strong) UITextField *GroupName;
@property(nonatomic, strong) UIButton *DoneBtn;
@property(nonatomic, strong) NSMutableArray *GroupMemberIdList;
- (void)ClickDoneBtn:(id)sender;

@end
