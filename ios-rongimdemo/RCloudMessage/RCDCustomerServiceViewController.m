//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"
#import "RCDSettingBaseViewController.h"
@interface RCDCustomerServiceViewController ()
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
//@property (nonatomic, strong)NSString *commentId;
//@property (nonatomic)RCCustomerServiceStatus serviceStatus;
//@property (nonatomic)BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@end

@implementation RCDCustomerServiceViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self notifyUpdateUnreadMessageCount];
  /*
    UIButton *button =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIImageView *imageView =
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Private_Setting"]];
    imageView.frame = CGRectMake(15, 5,16 , 17);
    [button addSubview:imageView];
    [button addTarget:self
               action:@selector(rightBarButtonItemClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton =
    [[UIBarButtonItem alloc] initWithCustomView:button];
   */
    self.navigationItem.rightBarButtonItem = nil;
}

/*
- (void)rightBarButtonItemClicked:(id)sender {
  RCDSettingBaseViewController *settingVC =
      [[RCDSettingBaseViewController alloc] init];
  settingVC.conversationType = self.conversationType;
  settingVC.targetId = self.targetId;
  //清除聊天记录之后reload data
  __weak typeof(self) weakSelf = self;
  settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
    if (isSuccess) {
      [weakSelf.conversationDataRepository removeAllObjects];
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.conversationMessageCollectionView reloadData];
      });
    }
  };
  [self.navigationController pushViewController:settingVC animated:YES];
}
*/

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//客服VC左按键注册的selector是customerServiceLeftCurrentViewController，
//这个函数是基类的函数，他会根据当前服务时间来决定是否弹出评价，根据服务的类型来决定弹出评价类型。
//弹出评价的函数是commentCustomerServiceAndQuit，应用可以根据这个函数内的注释来自定义评价界面。
//等待用户评价结束后调用如下函数离开当前VC。
- (void)leftBarButtonItemPressed:(id)sender {
  //需要调用super的实现
  [super leftBarButtonItemPressed:sender];

  [self.navigationController popToRootViewControllerAnimated:YES];
}

//评价客服，并离开当前会话
//如果您需要自定义客服评价界面，请把本函数注释掉，并打开“应用自定义评价界面开始1/2”到“应用自定义评价界面结束”部分的代码，然后根据您的需求进行修改。
//如果您需要去掉客服评价界面，请把本函数注释掉，并打开下面“应用去掉评价界面开始”到“应用去掉评价界面结束”部分的代码，然后根据您的需求进行修改。
- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
                               commentId:(NSString *)commentId
                        quitAfterComment:(BOOL)isQuit {
  [super commentCustomerServiceWithStatus:serviceStatus
                                commentId:commentId
                         quitAfterComment:isQuit];
}

//＊＊＊＊＊＊＊＊＊应用去掉评价界面开始＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    if (isQuit) {
//        [self leftBarButtonItemPressed:nil];
//    }
//}
//＊＊＊＊＊＊＊＊＊应用去掉评价界面结束＊＊＊＊＊＊＊＊＊＊＊＊＊

//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始2＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    self.serviceStatus = serviceStatus;
//    self.commentId = commentId;
//    self.quitAfterComment = isQuit;
//    if (serviceStatus == 0) {
//        [self leftBarButtonItemPressed:nil];
//    } else if (serviceStatus == 1) {
//        UIAlertView *alert = [[UIAlertView alloc]
//        initWithTitle:@"请评价我们的人工服务"
//        message:@"如果您满意就按5，不满意就按1" delegate:self
//        cancelButtonTitle:@"5" otherButtonTitles:@"1", nil];
//        [alert show];
//    } else if (serviceStatus == 2) {
//        UIAlertView *alert = [[UIAlertView alloc]
//        initWithTitle:@"请评价我们的机器人服务"
//        message:@"如果您满意就按是，不满意就按否" delegate:self
//        cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
//        [alert show];
//    }
//}
//- (void)alertView:(UIAlertView *)alertView
//clickedButtonAtIndex:(NSInteger)buttonIndex {
//    //(1)调用evaluateCustomerService将评价结果传给融云sdk。
//    if (self.serviceStatus == RCCustomerService_HumanService) { //人工评价结果
//        if (buttonIndex == 0) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId dialogId:self.commentId
//            humanValue:5 suggest:nil];
//        } else if (buttonIndex == 1) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId dialogId:self.commentId
//            humanValue:0 suggest:nil];
//        }
//    } else if (self.serviceStatus == RCCustomerService_RobotService)
//    {//机器人评价结果
//        if (buttonIndex == 0) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId knownledgeId:self.commentId
//            robotValue:YES suggest:nil];
//        } else if (buttonIndex == 1) {
//            [[RCIMClient sharedRCIMClient]
//            evaluateCustomerService:self.targetId knownledgeId:self.commentId
//            robotValue:NO suggest:nil];
//        }
//    }
//    //(2)离开当前客服VC
//    if (self.quitAfterComment) {
//        [self leftBarButtonItemPressed:nil];
//    }
//}
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束2＊＊＊＊＊＊＊＊＊＊＊＊＊

- (void)notifyUpdateUnreadMessageCount {
  __weak typeof(&*self) __weakself = self;
  int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
    @(ConversationType_PRIVATE),
    @(ConversationType_DISCUSSION),
    @(ConversationType_APPSERVICE),
    @(ConversationType_PUBLICSERVICE),
    @(ConversationType_GROUP)
  ]];
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *backString = nil;
    if (count > 0 && count < 1000) {
      backString = [NSString stringWithFormat:@"返回(%d)", count];
    } else if (count >= 1000) {
      backString = @"返回(...)";
    } else {
      backString = @"返回";
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
    backImg.frame = CGRectMake(-6, 4, 10, 17);
    [backBtn addSubview:backImg];
    UILabel *backText =
        [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
    backText.text = backString; // NSLocalizedStringFromTable(@"Back",
                                // @"RongCloudKit", nil);
    //   backText.font = [UIFont systemFontOfSize:17];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:__weakself
                  action:@selector(customerServiceLeftCurrentViewController)
        forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =
        [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [__weakself.navigationItem setLeftBarButtonItem:leftButton];
  });
}

@end
