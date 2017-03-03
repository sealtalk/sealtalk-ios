//
//  RedpacketViewControl.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketViewControl.h"
#import "UIView+YZHPrompting.h"
#import "RedpacketColorStore.h"
#import "RedPacketDetailViewController.h"
#import "YZTransparent.h"
#import "UIView+YZHAnimation.h"
#import "RedpacketDataRequester.h"
#import "NSDictionary+YZHExtern.h"
#import "RedpacketWebController.h"
#import "RedpacketMessageModel.h"
#import "NSDictionary+YZHExtern.h"
#import "ChangePurseViewController.h"
#import "RedpacketWebController.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketUser.h"
#import "RPSendRedPacketViewController.h"
#import "RPRedpackeNavgationController.h"
#import "RPSendRedPacketViewController.h"
#import "RPSendAmountPacketViewController.h"
#import "RedpacketTypeBaseHandle.h"
#import "TransferViewController.h"
#import "TransferDetailViewController.h"
#import "RPSoundPlayer.h"
#import "YZHRedpacketBridge+Private.h"
#import "RedpacketErrorCode.h"
#import "UIViewController+RP_Private.h"
#import "UIAlertView+YZHAlert.h"
#import "RedpacketViewControl+RedpacketID.h"
#import "RPRedpacketSetting.h"

#ifdef AliAuthPay
#import "RPAlipayAuth.h"
#import "RPReceiptsInAlipayViewController.h"
#import "RPAliPayEmpower.h"
#endif

#define __NoneCurrtViewController__         @"请设置FromViewController参数"
#define __NoneDelegateOfMembersRedpacket__  @"定向红包没有设置Delegate,设置位于RedpacketViewControl中的Delegate"
#define __NoneConversationInfo__            @"请设置当前聊天对象ReveciverInfo"
#define __NoneRedpacketSendBlock__          @"请设置发红包成功后的回调SendBlock"
#define __NoneRedpacketGrabBlock__          @"请设置发红包成功后的回调GrabBlock"
#define __AnValiableTransferFunction__      @"此版本不支持转账功能"


@interface RedpacketViewControl ()<RedpacketHandleDelegate,RPSendAmountPacketViewControllerDelegate>

@property (nonatomic, copy) RedpacketGrabBlock            redpacketGrabBlock;
@property (nonatomic, copy) RedpacketSendBlock            redpacketSendBlock;
@property (nonatomic, strong) RedpacketTypeBaseHandle     *redpacketHandle;
@property (nonatomic, weak) UIViewController * fromViewController;
@property (nonatomic, strong) RedpacketUserInfo *converstationInfo;
@property (nonatomic, copy)RedpacketAdvertisementAction advertisementAction;

@property (nonatomic, copy) RedpacketIDGenerateBlock generateBlock;
@property (nonatomic, copy) RedpacketCheckRedpacketStatusBlock checkRedpacketStatusBlock;
//  红包
@end


@implementation RedpacketViewControl

- (void)dealloc {
    RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [RPSoundPlayer regisitSoundId];
    }
    return self;
}

+ (void)redpacketTouchedWithMessageModel:(RedpacketMessageModel *)messageModel
                      fromViewController:(UIViewController *)fromViewController
                      redpacketGrabBlock:(RedpacketGrabBlock)grabTouch
                     advertisementAction:(RedpacketAdvertisementAction)advertisementAction{

    NSAssert(fromViewController, __NoneCurrtViewController__);
    switch (messageModel.redpacketType) {
        case RedpacketTransfer: {
            TransferDetailViewController *transferController = [[TransferDetailViewController alloc]init];
            transferController.model = messageModel;
            RPRedpackeNavgationController *navigationController = [[RPRedpackeNavgationController alloc] initWithRootViewController:transferController];
            [fromViewController presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        default:{
            if (messageModel.redpacketType != RedpacketTypeAmount && messageModel.redpacketType != RedpacketTypeMember) {
                messageModel.redpacketReceiver = [RPRedpacketUser currentUser].currentUserInfo;
            }
            RedpacketViewControl * control = fromViewController.rp_control;
            if (!fromViewController.rp_control) {
                control = [RedpacketViewControl new];
                fromViewController.rp_control = control;
            }
            control.fromViewController = fromViewController;
            control.redpacketGrabBlock = grabTouch;
            control.advertisementAction = advertisementAction;
            
            __weak typeof(control) weakControl = control;
            
            [fromViewController.view rp_showHudWaitingView:YZHPromptTypeWating];
            [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
                if (code == 0) {
                    [RedpacketTypeBaseHandle handleWithMessageModel:messageModel success:^(RedpacketTypeBaseHandle *handle) {
                        [fromViewController.view rp_removeHudInManaual];
                        weakControl.redpacketHandle = handle;
                        weakControl.redpacketHandle.fromViewController = fromViewController;
                        weakControl.redpacketHandle.delegate = weakControl;
                        [weakControl.redpacketHandle getRedpacketDetail];
                        
                    } failure:^(NSString *errorMsg, NSInteger errorCode) {
                        if (code == NSIntegerMax) {
                            [fromViewController.view rp_showHudErrorView:errorMsg];
                        }else {
                            [fromViewController.view rp_removeHudInManaual];
                            [[[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] show];
                        }
                    }];
                }else {
                    [fromViewController.view rp_showHudErrorView:msg];
                }
            }];
            break;
        }
    }
}

//  拆红包
- (void)sendGrabRedpacketRequest:(RedpacketMessageModel *)messageModel {
    rpWeakSelf;
    [weakSelf.fromViewController.view rp_showHudWaitingView:YZHPromptTypeWating];
    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *infoDic) {
        [weakSelf.fromViewController.view rp_removeHudInManaual];
        
        RedpacketMessageModel *model = messageModel;
        model.redpacketDetailDic = infoDic;
        model.redpacketReceiver = messageModel.currentUser;
        
        //  mark？？ 这个和下边的重复？？
        [weakSelf.redpacketHandle showRedPacketDetailViewController:model arguments:nil];
        
        //拼手气红包需要拆分显示
        switch (messageModel.redpacketType) {
            case RedpacketTypeRand:
            case RedpacketTypeMember:
                [weakSelf.redpacketHandle getRedpacketDetail];
                break;
            case RedpacketTypeAmount:
                weakSelf.redpacketHandle.messageModel.redpacketStatusType = RedpacketStatusTypeGrabFinish;
                [weakSelf.redpacketHandle getRedpacketDetail];
                break;
            default:
                break;
        }
        
        if (messageModel.redpacketType != RedpacketTypeAmount) {
             [weakSelf.redpacketHandle removeRedPacketView];
        }
       
        RPAssert(weakSelf.redpacketGrabBlock, __NoneRedpacketGrabBlock__);
        if (weakSelf.redpacketGrabBlock) {
            model.messageType = RedpacketMessageTypeTedpacketTakenMessage;
            //播放声音
            [RPSoundPlayer playRedpacketOpenSound];
            weakSelf.redpacketGrabBlock(model);
        }

    } andFaliureBlock:^(NSString *error, NSInteger code) {

        if (code != RedpacketUnAliAuthed) {
            [weakSelf.redpacketHandle removeRedPacketView];
        }else {
#ifdef AliAuthPay
            [weakSelf.redpacketHandle removeRedPacketView:NO];
            [weakSelf.fromViewController.view rp_removeHudInManaual];

            [RPAliPayEmpower aliEmpowerSuccess:^{
                [weakSelf.fromViewController.view rp_removeHudInManaual];
            } failure:^(NSString *errorString) {
                [weakSelf.fromViewController.view rp_showHudErrorView:error];
            }];

            return ;
#endif
        }
        
        [weakSelf.fromViewController.view rp_removeHudInManaual];

        if (code == NSIntegerMax) {
            [weakSelf.fromViewController.view rp_showHudErrorView:error];
            
        } else {
            if (code == RedpacketHBCompleted) {//需要将数字改成type类型
                //出现拆红包界面 但是拆开的时候没有了，则为这个code
                RedpacketBoxStatusType boxStatusType;
                if (messageModel.redpacketType == RedpacketTypeAvg || messageModel.redpacketType == RedpacketTypeRandpri) {
                    
                    boxStatusType = RedpacketBoxStatusTypeAvgRobbing;
                }else if (messageModel.redpacketType == RedpacketTypeRand)
                {
                    boxStatusType = RedpacketBoxStatusTypeRandRobbing;
                }
                
                [weakSelf.redpacketHandle setingPacketViewWith:messageModel boxStatusType:boxStatusType closeButtonBlock:^(RPRedpacketPreView *packetView) {
                    [weakSelf.redpacketHandle removeRedPacketView];
                } submitButtonBlock:^(RedpacketBoxStatusType boxStatusType, RPRedpacketPreView *packetView) {
                    if (packetView.boxStatusType == RedpacketBoxStatusTypeRandRobbing) {
                        [weakSelf.redpacketHandle showRedPacketDetailViewController:weakSelf.redpacketHandle.messageModel arguments:nil];
                    } else {
                        [weakSelf.redpacketHandle getRedpacketDetail];
                    }
                    //[weakSelf.redpacketHandle removeRedPacketView];

                }];
            }else if (code == RedpacketHBGetReceivedBefore)//需要将数字改成type类型
            {
                [weakSelf.redpacketHandle showRedPacketDetailViewController:messageModel arguments:nil];
                
            }else{
                [weakSelf.fromViewController.view rp_showHudErrorView:error];
            }
        }
        
    }];
    
    [request requestGrabRedpacketResult:messageModel];
}

- (void)convertRedpacketViewcontrollerFromViewController:(UIViewController *)fromController {
    [self.class presentRedpacketViewController:RPRedpacketControllerTypeSingle
                               fromeController:fromController groupMemberCount:0
                         withRedpacketReceiver:self.converstationInfo
                               andSuccessBlock:self.redpacketSendBlock
                 withFetchGroupMemberListBlock:nil
                   andGenerateRedpacketIDBlock:self.generateBlock];
}

- (void)advertisementRedPacketAction:(NSDictionary *)args {
    if (self.advertisementAction) {
        self.advertisementAction(args);
    }
}

#pragma mark RedpacketControllers
+ (void)presentRedpacketViewController:(RPRedpacketControllerType)controllerType
                       fromeController:(UIViewController *)fromeController
                      groupMemberCount:(NSInteger)count
                 withRedpacketReceiver:(RedpacketUserInfo *)receiver
                       andSuccessBlock:(RedpacketSendBlock)sendBlock
         withFetchGroupMemberListBlock:(RedpacketMemberListBlock)memberBlock
           andGenerateRedpacketIDBlock:(RedpacketIDGenerateBlock)generateBlock {
    
    NSAssert(fromeController, __NoneCurrtViewController__);
    NSAssert(receiver, __NoneConversationInfo__);
    NSAssert(sendBlock, __NoneRedpacketSendBlock__);
#ifdef AliAuthPay
    NSAssert(controllerType != RPRedpacketControllerTypeTransfer, __AnValiableTransferFunction__);
#endif
    RedpacketViewControl * control = [RedpacketViewControl new];
    fromeController.rp_control = control;
    
    control.converstationInfo = receiver;
    control.fromViewController = fromeController;
    control.redpacketSendBlock = sendBlock;
    
    //  Redpacket ID callBack
    control.generateBlock = generateBlock;
    
    switch (controllerType) {
        case RPRedpacketControllerTypeSingle: {
            RPSendRedPacketViewController * redpacketController = [[RPSendRedPacketViewController alloc] initWithControllerType:RPSendRedPacketViewControllerSingle];
            redpacketController.conversationInfo = receiver;
            redpacketController.sendRedPacketBlock = sendBlock;
            redpacketController.hostController = fromeController;
            [redpacketController setMemberCount:count];
            RPRedpackeNavgationController *navigationController = [[RPRedpackeNavgationController alloc] initWithRootViewController:redpacketController];
            [fromeController presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case RPRedpacketControllerTypeGroup: {
            RPSendRedPacketViewControllerType type = RPSendRedPacketViewControllerGroup;
            if (memberBlock) {
                type = RPSendRedPacketViewControllerMember;
            }
            
            RPSendRedPacketViewController * redpacketController = [[RPSendRedPacketViewController alloc] initWithControllerType:type];
            redpacketController.conversationInfo = receiver;
            redpacketController.sendRedPacketBlock = sendBlock;
            redpacketController.fetchBlock = memberBlock;
            redpacketController.hostController = fromeController;
            [redpacketController setMemberCount:count];
            RPRedpackeNavgationController *navigationController = [[RPRedpackeNavgationController alloc] initWithRootViewController:redpacketController];
            [fromeController presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        case RPRedpacketControllerTypeRand: {
            RPSendAmountPacketViewController * redpacketController = [RPSendAmountPacketViewController new];
            redpacketController.delegate = control;
            redpacketController.conversationInfo = receiver;
            redpacketController.sendRedPacketBlock = sendBlock;
            redpacketController.hostViewController = fromeController;
            [fromeController addChildViewController:redpacketController];
            redpacketController.view.frame = CGRectMake(0, 0, CGRectGetWidth(fromeController.view.frame), CGRectGetHeight(fromeController.view.frame));
            [fromeController.view addSubview:redpacketController.view];
            break;
        }
        case RPRedpacketControllerTypeTransfer: {
            TransferViewController *transferController = [[TransferViewController alloc]init];
            transferController.userInfo = receiver;
            transferController.sendRedPacketBlock = sendBlock;
            RPRedpackeNavgationController *navigationController = [[RPRedpackeNavgationController alloc] initWithRootViewController:transferController];
            [fromeController presentViewController:navigationController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

+ (void)presentChangePocketViewControllerFromeController:(UIViewController *)viewController
{
    UIViewController *controller;
#ifdef AliAuthPay
    
    controller = [[RPReceiptsInAlipayViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
#else
    controller = [[ChangePurseViewController alloc] init];
    
#endif
    
    RPRedpackeNavgationController *navigation = [[RPRedpackeNavgationController alloc] initWithRootViewController:controller];
    [viewController presentViewController:navigation animated:YES completion:nil];
}

//  零钱
+ (UIViewController *)changePocketViewController {
    
    UIViewController *controller;
    
#ifdef AliAuthPay
    
    controller = [[RPReceiptsInAlipayViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
#else
    controller = [[ChangePurseViewController alloc] init];
    
#endif

    return controller;
}

// 获取零钱
+ (void)getChangeMoney:(void (^)(NSString *amount))amount {
    
#ifdef AliAuthPay
    if (amount) {
        amount(@"");
    }
    return;
#else
    
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        if (code == 0) {
            RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *dict) {
                amount([dict rp_stringFloatForKey:@"Balance"]);
            } andFaliureBlock:^(NSString *error, NSInteger code) {
                amount(@"");
            }];
            [request getPaymentMoney];
        }else {
            amount(@"");
        }
    }];
#endif
    
}

+ (void)checkRedpacketStatusWithRedpacketID:(NSString *)redpacketID
                              andCheckBlock:(RedpacketCheckRedpacketStatusBlock)checkBlock
{
    RPAssert(checkBlock, @"传入CeckBlock参数后，方可使用本方法");
    if (redpacketID.length == 0) {
        NSInteger code = -1;
        NSString *msg = @"传入的红包ID为空";
        NSError *ns_error = [NSError errorWithDomain:msg code:code userInfo:nil];
        checkBlock(nil, ns_error);
        return;
    }
    
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken:^(NSInteger code, NSString *msg) {
        
        if (code == 0) {
            
            RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
                
                if (checkBlock) {
                    RedpacketMessageModel *model = [RedpacketMessageModel modelWithCheckResult:data];
                    checkBlock(model, nil);
                }
                
            } andFaliureBlock:^(NSString *error, NSInteger code) {
                
                NSError *ns_error = [NSError errorWithDomain:error code:code userInfo:nil];
                checkBlock(nil, ns_error);
                
            }];
            
            [request checkRedpacketIsExist:redpacketID];
            
        }else {
            //  Token 过期
            NSError *ns_error = [NSError errorWithDomain:msg code:code userInfo:nil];
            checkBlock(nil, ns_error);
        }
    }];
}

+ (RedpacketMessageModel *)modelWithCheckResult:(NSDictionary *)dict
{
    NSString *orgName = [RPRedpacketSetting shareInstance].redpacketOrgName;
    RedpacketMessageModel *model = [RedpacketMessageModel new];
    //model.redpacketType
    model.redpacketId = [dict rp_stringForKey:@"ID"];
    model.redpacket.redpacketGreeting = [dict rp_stringForKey:@"Message"];
    if (orgName.length) {
        model.redpacket.redpacketOrgName = rpString(@"%@红包", orgName);
    }else {
        model.redpacket.redpacketOrgName = @"红包";
    }
    
    [model redpacketTypeVoluationWithGroupType:[dict valueForKey:@"Type"]];
    //  这里有个缺陷，先作为临时方案修改 （model.redpacketType 赋值方式有问题）
    RedpacketType type = model.redpacketType;
    model.redpacketType = 0;
    model.redpacketType = type;
    
    model.redpacketReceiver.userId = [dict rp_stringForKey:@"ReceiverDuid"];
    NSString *redpacketReceiver = [dict rp_stringForKey:@"ReceiverDuid"];
    if (redpacketReceiver.length) {
        model.redpacketReceiver.userId = redpacketReceiver;
    }
    model.redpacketSender = model.currentUser;

    return model;
}

@end

