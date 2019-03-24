//
//  RCDGroupAnnouncementViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/7/14.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupAnnouncementViewController.h"
#import "MBProgressHUD.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDGroupAnnouncementViewController ()

@property(nonatomic, strong) UIButton *rightBtn;

@property(nonatomic, strong) UILabel *rightLabel;

@property(nonatomic, strong) UIButton *leftBtn;

@property(nonatomic, strong) MBProgressHUD *hud;

@property(nonatomic) CGFloat heigh;

@end

@implementation RCDGroupAnnouncementViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.AnnouncementContent = [[UITextViewAndPlaceholder alloc] initWithFrame:CGRectZero];
        self.AnnouncementContent.delegate = self;
        self.AnnouncementContent.font = [UIFont systemFontOfSize:16.f];
        self.AnnouncementContent.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
        self.AnnouncementContent.myPlaceholder = RCDLocalizedString(@"Please_edit_the_group_announcement")
;
        self.AnnouncementContent.frame =
            CGRectMake(4.5, 8, self.view.frame.size.width - 5,
                       self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 90);
        self.heigh = self.AnnouncementContent.frame.size.height;
        [self.view addSubview:self.AnnouncementContent];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 0, 50, 34)];
    self.rightLabel.text = RCDLocalizedString(@"done")
;
    [self.rightBtn addSubview:self.rightLabel];
    [self.rightBtn addTarget:self action:@selector(clickRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    self.rightBtn.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = rightButton;

    self.leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(-6.5, 0, 50, 34)];
    leftLabel.text = RCDLocalizedString(@"cancel")
;
    [self.leftBtn addSubview:leftLabel];
    [leftLabel setTextColor:[UIColor whiteColor]];
    [self.leftBtn addTarget:self action:@selector(clickLeftBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftBtn];
    [self.leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftButton;

    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.title = RCDLocalizedString(@"group_announcement")
;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 类的私有方法
//键盘将要弹出
- (void)keyboardWillShow:(NSNotification *)aNotification {
    CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
        [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.AnnouncementContent.frame;
    frame.origin.y = 8;
    if (frame.size.height == self.heigh) {
        frame.size.height -= keyboardRect.size.height;
        if (frame.size.height != self.heigh) {
            frame.size.height -= 60;
        }
    }
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.AnnouncementContent.frame = frame;
    [UIView commitAnimations];
}

//键盘将要隐藏
- (void)keyboardWillHide:(NSNotification *)aNotification {
    //  CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration =
        [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.AnnouncementContent.frame;
    frame.size.height = self.heigh;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.AnnouncementContent.frame = frame;
    [UIView commitAnimations];
}

- (void)navigationButtonIsCanClick:(BOOL)isCanClick {
    if (isCanClick == NO) {
        self.leftBtn.userInteractionEnabled = NO;
        self.rightBtn.userInteractionEnabled = NO;
    } else {
        self.leftBtn.userInteractionEnabled = YES;
        self.rightBtn.userInteractionEnabled = YES;
    }
}

- (void)clickLeftBtn:(id)sender {
    [self navigationButtonIsCanClick:NO];
    if (self.AnnouncementContent.text.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:RCDLocalizedString(@"Exit_this_edit")
                                                       delegate:self
                                              cancelButtonTitle:RCDLocalizedString(@"Continue_editing")
                                              otherButtonTitles:RCDLocalizedString(@"quit"), nil];
        alert.tag = 101;
        [alert show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickRightBtn:(id)sender {
    [self navigationButtonIsCanClick:NO];
    BOOL isEmpty = [self isEmpty:self.AnnouncementContent.text];
    if (isEmpty == YES) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:RCDLocalizedString(@"The_announcement_will_notify_all_members_of_the_group")
                                                   delegate:self
                                          cancelButtonTitle:RCDLocalizedString(@"cancel")

                                          otherButtonTitles:RCDLocalizedString(@"send"), nil];
    alert.tag = 102;
    [alert show];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = [textView.text length];
    if (number == 0) {
        self.rightBtn.userInteractionEnabled = NO;
        [self.rightLabel setTextColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]];
    }
    if (number > 0) {
        self.rightBtn.userInteractionEnabled = YES;
        [self.rightLabel setTextColor:[UIColor whiteColor]];

        CGRect frame = self.AnnouncementContent.frame;

        CGSize maxSize = CGSizeMake(frame.size.width, MAXFLOAT);

        CGFloat height = [self.AnnouncementContent.text
                             boundingRectWithSize:maxSize
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName : self.AnnouncementContent.font}
                                          context:nil]
                             .size.height;
        frame.size.height = height;
    }
    if (number > 500) {
        textView.text = [textView.text substringToIndex:500];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self navigationButtonIsCanClick:YES];
    switch (alertView.tag) {
    case 101: {
        switch (buttonIndex) {
        case 1: {
            _AnnouncementContent.editable = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                           ^{
                               [self.navigationController popViewControllerAnimated:YES];
                           });
        } break;

        default:
            break;
        }
    } break;

    case 102: {
        switch (buttonIndex) {
        case 1: {
            self.AnnouncementContent.editable = NO;
            //发布中的时候显示转圈的进度
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.yOffset = -46.f;
            self.hud.minSize = CGSizeMake(120, 120);
            self.hud.color = [UIColor colorWithHexString:@"343637" alpha:0.5];
            self.hud.margin = 0;
            [self.hud show:YES];
            //发布成功后，使用自定义图片
            NSString *txt = [NSString stringWithFormat:@"%@\n%@", RCDLocalizedString(@"mention_all"),self.AnnouncementContent.text];
            //去除收尾的空格
            txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //去除收尾的换行
            txt = [txt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            RCTextMessage *announcementMsg = [RCTextMessage messageWithContent:txt];
            announcementMsg.mentionedInfo =
                [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All userIdList:nil mentionedContent:nil];
            [[RCIM sharedRCIM] sendMessage:ConversationType_GROUP
                targetId:self.GroupId
                content:announcementMsg
                pushContent:nil
                pushData:nil
                success:^(long messageId) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                                   dispatch_get_main_queue(), ^{
                                       self.hud.mode = MBProgressHUDModeCustomView;
                                       UIImageView *customView =
                                           [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Complete"]];
                                       customView.frame = CGRectMake(0, 0, 80, 80);
                                       self.hud.customView = customView;
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                                                      dispatch_get_main_queue(), ^{
                                                          //显示成功的图片后返回
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      });
                                   });
                }
                error:^(RCErrorCode nErrorCode, long messageId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:RCDLocalizedString(@"Group_announcement_failed_to_be_sent")
                                                                       delegate:nil
                                                              cancelButtonTitle:RCDLocalizedString(@"confirm")

                                                              otherButtonTitles:nil];
                        [alert show];
                    });
                }];

        } break;

        default:
            break;
        }
    } break;

    default:
        break;
    }
}

//判断内容是否全部为空格  yes 全部为空格  no 不是
- (BOOL)isEmpty:(NSString *)str {

    if (!str) {
        return YES;
    } else {
        // A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and
        // nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];

        // Returns a new string made by removing from both ends of the receiver characters contained in a given
        // character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];

        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
