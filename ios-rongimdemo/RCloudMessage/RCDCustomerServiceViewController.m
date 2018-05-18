//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"
#import "RCDSettingBaseViewController.h"
#import "RCDCSAnnounceView.h"
#import "RCDCSEvaluateView.h"
#import "RCDCSEvaluateModel.h"
@interface RCDCustomerServiceViewController ()<RCDCSAnnounceViewDelegate,RCDCSEvaluateViewDelegate>
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
@property (nonatomic, strong)NSString *commentId;
@property (nonatomic)RCCustomerServiceStatus serviceStatus;
@property (nonatomic)BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@property (nonatomic,copy) NSString *announceClickUrl;

@property (nonatomic,strong) RCDCSEvaluateView *evaluateView;
//key为星级；value为RCDCSEvaluateModel对象
@property (nonatomic,strong)NSMutableDictionary *evaStarDic;
@property (nonatomic,strong) RCDCSAnnounceView *announceView;
@end

@implementation RCDCustomerServiceViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self notifyUpdateUnreadMessageCount];
  
  self.evaStarDic = [NSMutableDictionary dictionary];
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
  
  [[RCIMClient sharedRCIMClient] getHumanEvaluateCustomerServiceConfig:^(NSDictionary *evaConfig) {
    NSArray *array = [evaConfig valueForKey:@"evaConfig"];
      dispatch_async(dispatch_get_main_queue(), ^{
          if (array) {
              for (NSDictionary *dic in array) {
                  RCDCSEvaluateModel *model = [RCDCSEvaluateModel modelWithDictionary:dic];
                  [self.evaStarDic setObject:model forKey:[NSString stringWithFormat:@"%d",model.score]];
              }
          }
      });
  }];
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
//- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//                               commentId:(NSString *)commentId
//                        quitAfterComment:(BOOL)isQuit {
//  [super commentCustomerServiceWithStatus:serviceStatus
//                                commentId:commentId
//                         quitAfterComment:isQuit];
//}

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
-
(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
    if (self.evaStarDic.count == 0) {
        [super commentCustomerServiceWithStatus:serviceStatus commentId:commentId quitAfterComment:isQuit];
        return;
    }
    self.serviceStatus = serviceStatus;
    self.commentId = commentId;
    self.quitAfterComment = isQuit;
    if (serviceStatus == 0) {
        [self leftBarButtonItemPressed:nil];
    } else if (serviceStatus == 1) {
        //人工评价结果
      [self.evaluateView show];
    } else if (serviceStatus == 2) {
        //机器人评价结果
        UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:@"请评价我们的机器人服务"
        message:@"如果您满意就按是，不满意就按否" delegate:self
        cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    //(1)调用evaluateCustomerService将评价结果传给融云sdk。
    if (self.serviceStatus == RCCustomerService_RobotService)
    {//机器人评价结果
        if (buttonIndex == 0) {
            [[RCIMClient sharedRCIMClient]
            evaluateCustomerService:self.targetId knownledgeId:self.commentId
            robotValue:YES suggest:nil];
        } else if (buttonIndex == 1) {
            [[RCIMClient sharedRCIMClient]
            evaluateCustomerService:self.targetId knownledgeId:self.commentId
            robotValue:NO suggest:nil];
        }
    }
    //(2)离开当前客服VC
    if (self.quitAfterComment) {
        [self leftBarButtonItemPressed:nil];
    }
}

//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

- (void)announceViewWillShow:(NSString *)announceMsg announceClickUrl:(NSString *)announceClickUrl{
  self.announceClickUrl = announceClickUrl;
  
  self.announceView.content.text = announceMsg;
  if (announceClickUrl.length == 0) {
    self.announceView.hiddenArrowIcon = YES;
  }
}

#pragma mark -- RCDCSAnnounceViewDelegate
- (void)didTapViewAction{
  if (self.announceClickUrl.length > 0) {
    [RCKitUtility openURLInSafariViewOrWebView:self.announceClickUrl base:self];
  }
}
//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

#pragma mark -- RCDCSEvaluateViewDelegate

- (void)didSubmitEvaluate:(RCCSResolveStatus)solveStatus star:(int)star tagString:(NSString *)tagString suggest:(NSString *)suggest{
  [[RCIMClient sharedRCIMClient] evaluateCustomerService:self.targetId dialogId:nil starValue:star suggest:suggest resolveStatus:solveStatus tagText:tagString extra:nil];
  if (self.quitAfterComment) {
    [self leftBarButtonItemPressed:nil];
  }
}

- (void)dismissEvaluateView{
  [self.evaluateView hide];
  if (self.quitAfterComment) {
    [self leftBarButtonItemPressed:nil];
  }
}

- (RCDCSEvaluateView *)evaluateView{
  if (!_evaluateView) {
    _evaluateView = [[RCDCSEvaluateView alloc] initWithEvaStarDic:self.evaStarDic];
    _evaluateView.delegate = self;
  }
  return _evaluateView;
}

- (RCDCSAnnounceView *)announceView{
  if (!_announceView) {
    CGRect rect = self.conversationMessageCollectionView.frame;
    rect.origin.y += 44;
    rect.size.height -= 44;
    self.conversationMessageCollectionView.frame = rect;
    _announceView = [[RCDCSAnnounceView alloc] initWithFrame:CGRectMake(0,rect.origin.y-44, self.view.frame.size.width,44)];
    _announceView.delegate = self;
    [self.view addSubview:_announceView];
  }
  return _announceView;
}
@end
