//
//  RedpacketTypeBaseHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeBaseHandle.h"
#import "RedpacketTypeSingleHandle.h"
#import "RedpacketTypeMemberHandle.h"
#import "RedpacketTypeRandHandle.h"
#import "RedpacketTypeAvgHandle.h"
#import "RedpacketTypeRandpiHandle.h"
#import "RedpacketTypeAdvertisementHandle.h"
#import "YZTransparent.h"
#import "UIView+YZHAnimation.h"
#import "RedpacketTypeAmountHandle.h"
#import "RedPacketDetailViewController.h"
#import "RPRedpackeNavgationController.h"
#import "RPAdvertisementDetailViewContrroller.h"

@interface RedpacketTypeBaseHandle()

@property (nonatomic, weak) RedPacketDetailViewController *packetDetailViewController;

@end

@implementation RedpacketTypeBaseHandle

+ (void)handleWithMessageModel:(RedpacketMessageModel *)messageModel success:(void (^)(RedpacketTypeBaseHandle *))successblock failure:(void (^)(NSString *, NSInteger))failureBlock {

    RedpacketDataRequester *request = [RedpacketDataRequester requestSuccessBlock:^(NSDictionary *data) {
        
        switch (messageModel.redpacketType) {
            case RedpacketTypeAdvertisement:
                break;
            default:
                // 抢红包详情页面的数据
                messageModel.redpacketDetailDic = data;
                break;
        }
        
        RedpacketTypeBaseHandle * handle = [[self class] handleWithmessageModel:messageModel];
        //  广告红包相关数据
        handle.redpacketDetailDic = data;
        successblock(handle);
        
    } andFaliureBlock:^(NSString *error, NSInteger code) {
        failureBlock(error,code);
    }];
    
    switch (messageModel.redpacketType) {
            //  广告红包详情
        case RedpacketTypeAdvertisement:
            [request requestADRedpacketDetail:messageModel.redpacketId];
            break;
        default:
            //  其它红包详情
            [request requestRedpacketDetail:messageModel.redpacketId];
            break;
    }
}


+ (instancetype)handleWithmessageModel:(RedpacketMessageModel *)messageModel{
    RedpacketTypeBaseHandle * handle;
    switch (messageModel.redpacketType) {
        case RedpacketTypeSingle: {
            handle = [RedpacketTypeSingleHandle new];
            break;
        }
        case RedpacketTypeGroup:{
            break;
        }
        case RedpacketTypeRand:{
            handle = [RedpacketTypeRandHandle new];
            break;
        }
        case RedpacketTypeAvg:{
            handle = [RedpacketTypeAvgHandle new];
            break;
        }
        case RedpacketTypeRandpri: {
            handle = [RedpacketTypeRandpiHandle new];
            break;
        }
        case RedpacketTypeMember: {
            handle = [RedpacketTypeMemberHandle new];
            break;
        }
        case RedpacketTypeAdvertisement: {
            handle = [RedpacketTypeAdvertisementHandle new];
            break;
        }
        case RedpacketTypeAmount:
            handle = [RedpacketTypeAmountHandle new];
            break;
        default:
            NSParameterAssert(messageModel.redpacketType);
            break;
    }
    handle.messageModel = messageModel;
    return handle;
}

- (void)getRedpacketDetail {
    //  检查有没有实现代理
    if (![self.delegate conformsToProtocol:@protocol(RedpacketHandleDelegate)]) {
       @throw [NSException exceptionWithName:@"RedpacketTypeBaseHandle" reason:@"RedpacketHandleDelegate" userInfo:nil];
    };
}

- (void)showRedPacketDetailViewController:(RedpacketMessageModel *)messageModel arguments:(id)args {
    switch (messageModel.redpacketType) {
        case RedpacketTypeSingle:
        case RedpacketTypeGroup:
        case RedpacketTypeRand:
        case RedpacketTypeAvg:
        case RedpacketTypeRandpri:
        case RedpacketTypeMember: {
            if (!_packetDetailViewController) {
                RedPacketDetailViewController *controller = [[RedPacketDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
                _packetDetailViewController = controller;
                RPRedpackeNavgationController *navigation = [[RPRedpackeNavgationController alloc] initWithRootViewController:controller];
                [self.fromViewController presentViewController:navigation animated:YES completion:nil];
            }
            _packetDetailViewController.messageModel = messageModel;
            break;
        }
        case RedpacketTypeAdvertisement: {
            RPAdvertisementDetailViewContrroller *controller = [[RPAdvertisementDetailViewContrroller alloc] init];
            rpWeakSelf;
            controller.advertisementDetailAction = ^(NSDictionary * args) {
                if ([weakSelf.delegate respondsToSelector:@selector(advertisementRedPacketAction:)]) {
                    [weakSelf.delegate advertisementRedPacketAction:args];
                }
            };
            controller.adMessageModel = args;
            controller.messageModel = messageModel;
            RPRedpackeNavgationController *navigation = [[RPRedpackeNavgationController alloc] initWithRootViewController:controller];
            [self.fromViewController presentViewController:navigation animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

@end


@implementation RedpacketTypeBaseHandle(infoView)

- (void)setingPacketViewWith:(RedpacketMessageModel *)messageModel
               boxStatusType:(RedpacketBoxStatusType)BoxStatusType
            closeButtonBlock:(void (^)(RPRedpacketPreView * packetView))closeButtonBlock
           submitButtonBlock:(void(^)(RedpacketBoxStatusType boxStatusType,RPRedpacketPreView * packetView))submitButtonBlock {
    [self removeRedPacketView];
    RPRedpacketPreView *packetView = [[RPRedpacketPreView alloc]initWithRedpacketBoxStatusType:BoxStatusType];;
    [YZTransparent showInView:self.fromViewController.view touchBlock:nil];
    packetView.messageModel = messageModel;
    packetView.boxStatusType = BoxStatusType;
    [packetView setCloseButtonBlock:closeButtonBlock];
    [packetView setSubmitButtonBlock:submitButtonBlock];
    [self popSubView:packetView];
}

- (void)removeRedPacketView {
    [self removeRedPacketView:YES];
}

- (void)removeRedPacketView:(BOOL)animated {
    [YZTransparent removeFromSuperView];
    [self.fromViewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RPRedpacketPreView class]]) {
            __weak UIView *weakRedpacket = obj;
            if (animated) {
                [obj rp_shrinkDispaerWithCompletionBlock:^{
                    [weakRedpacket removeFromSuperview];
                }];
            }else {
                [weakRedpacket removeFromSuperview];
            }
            
        }
    }];
}

- (void)popSubView:(UIView *)view {
    view.frame = CGRectMake(28, 100, [UIScreen mainScreen].bounds.size.width - 56, ([UIScreen mainScreen].bounds.size.width - 56)*418.0/320.0);
    view.center = CGPointMake(CGRectGetWidth(self.fromViewController.view.frame) / 2, CGRectGetHeight(self.fromViewController.view.frame) / 2);
    [self.fromViewController.view rp_popupSubView:view atPosition:PopAnchorCenterX | PopAnchorCenterY];
}

@end
