//
//  RCDEditGroupNameViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/28.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDEditGroupNameViewController.h"
#import "RCDCommonDefine.h"
#import "RCDHttpTool.h"
#import "RCDUIBarButtonItem.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"

@interface RCDEditGroupNameViewController ()

@property(nonatomic, strong) RCDUIBarButtonItem *rightBtn;

@end

@implementation RCDEditGroupNameViewController

+ (instancetype)editGroupNameViewController {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    CGFloat screenWidth = RCDscreenWidth;

    // backgroundView
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, screenWidth, 44)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];

    // groupNameTextField
    self.view.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:244 / 255.0 alpha:1];
    CGFloat groupNameTextFieldWidth = screenWidth - 8 - 8;
    self.groupNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, groupNameTextFieldWidth, 44)];
    self.groupNameTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.groupNameTextField.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.groupNameTextField];
    _groupNameTextField.delegate = self;

    //自定义rightBarButtonItem
    self.rightBtn = [[RCDUIBarButtonItem alloc] initWithbuttonTitle:RCDLocalizedString(@"save")

                                                         titleColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                                                        buttonFrame:CGRectMake(0, 0, 50, 30)
                                                             target:self
                                                             action:@selector(clickDone:)];
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    self.navigationItem.rightBarButtonItems = [self.rightBtn setTranslation:self.rightBtn translation:-11];
}

- (void)setGroupInfo:(RCDGroupInfo *)groupInfo {
    _groupInfo = groupInfo;
    self.groupNameTextField.text = groupInfo.groupName;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickDone:(id)sender {
    [self.rightBtn buttonIsCanClick:NO
                        buttonColor:[UIColor colorWithHexString:@"9fcdfd" alpha:1.0]
                      barButtonItem:self.rightBtn];
    NSString *nameStr = [_groupNameTextField.text copy];
    nameStr = [nameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    //群组名称需要大于2位
    if ([nameStr length] == 0) {
        [self Alert:RCDLocalizedString(@"group_name_can_not_nil")];
        return;
    }
    //群组名称需要大于2个字
    if ([nameStr length] < 2) {
        [self Alert:RCDLocalizedString(@"Group_name_is_too_short")];
        return;
    }
    //群组名称需要小于10个字
    if ([nameStr length] > 10) {
        [self Alert:RCDLocalizedString(@"Group_name_cannot_exceed_10_words")];
        return;
    }

    [RCDHTTPTOOL
        renameGroupWithGoupId:_groupInfo.groupId
                    groupName:nameStr
                     complete:^(BOOL result) {
                         if (result == YES) {
                             RCGroup *groupInfo = [RCGroup new];
                             groupInfo.groupId = _groupInfo.groupId;
                             groupInfo.groupName = nameStr;
                             groupInfo.portraitUri = _groupInfo.portraitUri;
                             [[RCIM sharedRCIM] refreshGroupInfoCache:groupInfo withGroupId:_groupInfo.groupId];
                             RCDGroupInfo *tempGroupInfo =
                                 [[RCDataBaseManager shareInstance] getGroupByGroupId:groupInfo.groupId];
                             tempGroupInfo.groupName = nameStr;
                             [[RCDataBaseManager shareInstance] insertGroupToDB:tempGroupInfo];
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         if (result == NO) {
                             [self Alert:RCDLocalizedString(@"Group_name_modification_failed")];
                         }
                     }];
}

- (void)Alert:(NSString *)alertContent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:alertContent
                                                   delegate:self
                                          cancelButtonTitle:RCDLocalizedString(@"confirm")

                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
    [self.rightBtn buttonIsCanClick:YES buttonColor:[UIColor whiteColor] barButtonItem:self.rightBtn];
    return YES;
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

@end
