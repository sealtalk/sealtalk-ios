//
//  RedpacketDemoViewController.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-22.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketDemoViewController.h"
#import <RongIMKit/RongIMKit.h>

#pragma mark - 红包相关头文件
#import "RedpacketViewControl.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessage.h"
#import "RedpacketMessageCell.h"
#import "RedpacketTakenMessage.h"
#import "RedpacketTakenOutgoingMessage.h"
#import "RedpacketTakenMessageTipCell.h"
#import "RedpacketConfig.h"
#import "RCDHttpTool.h"
#pragma mark -

// 用于获取
#import "RCDRCIMDataSource.h"
#import "RCDataBaseManager.h"
#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#pragma mark -

@interface RedpacketDemoViewController () <RCMessageCellDelegate>

@property (nonatomic, strong, readwrite) RedpacketViewControl *redpacketControl;
@property (atomic, strong)NSMutableArray * usersArray;
@end

@implementation RedpacketDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.usersArray = [NSMutableArray array];
    // 注册消息显示 Cell
    [self registerClass:[RedpacketMessageCell class] forCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier];
    [self registerClass:[RedpacketTakenMessageTipCell class] forCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier];
    [self registerClass:[RCTextMessageCell class] forCellWithReuseIdentifier:@"Message"];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 融云消息与红包插件消息转换与处理
// 发送融云红包消息
- (void)sendRedpacketMessage:(RedpacketMessageModel *)redpacket
{
    RedpacketMessage *message = [RedpacketMessage messageWithRedpacket:redpacket];
    NSString *push = [NSString stringWithFormat:@"%@发了一个红包", redpacket.currentUser.userNickname];
    [self sendMessage:message pushContent:push];
}

// 红包被抢消息处理
- (void)onRedpacketTakenMessage:(RedpacketMessageModel *)redpacket
{
    RedpacketTakenMessage *message = [RedpacketTakenMessage messageWithRedpacket:redpacket];
    // 抢自己的红包不发消息，只自己显示抢红包消息
    if ([redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]) {//如果发送者是自己

        RCMessage *m = [[RCIMClient sharedRCIMClient] insertMessage:self.conversationType
                                                           targetId:self.targetId
                                                       senderUserId:self.conversation.senderUserId
                                                         sendStatus:SentStatus_SENT
                                                            content:message];
        [self appendAndDisplayMessage:m];
    }
    else {
        switch (redpacket.redpacketType) {
            case RedpacketTypeSingle: {
                [self sendMessage:message pushContent:nil];
                break;
            }
            case RedpacketTypeGroup:
            case RedpacketTypeRand:
            case RedpacketTypeAvg:
            case RedpacketTypeRandpri:
            case RedpacketTypeMember:{
                RCMessage *m = [[RCIMClient sharedRCIMClient] insertMessage:self.conversationType
                                                                   targetId:self.targetId
                                                               senderUserId:self.conversation.senderUserId
                                                                 sendStatus:SentStatus_SENT
                                                                    content:message];
                [self appendAndDisplayMessage:m];
                
                // 按照 android 的需求修改发送红包的功能
                RedpacketTakenOutgoingMessage *m2 = [RedpacketTakenOutgoingMessage messageWithRedpacket:redpacket];
                [self sendMessage:m2 pushContent:nil];
                break;
            }
            default:
                break;
        }
    }
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        RedpacketMessageModel *redpacket = redpacketMessage.redpacket;
        if(RedpacketMessageTypeRedpacket == redpacket.messageType) {
            return CGSizeMake(collectionView.frame.size.width, [RedpacketMessageCell getBubbleBackgroundViewSize:model].height + REDPACKET_MESSAGE_TOP_BOTTOM_PADDING);
        }
        else if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType){
            return CGSizeMake(collectionView.frame.size.width,
                              [RedpacketTakenMessageTipCell sizeForModel:model].height + REDPACKET_TAKEN_MESSAGE_TOP_BOTTOM_PADDING);
        }
        
    }
    
    return [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message
{
    RCMessageContent *messageContent = message.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        RedpacketMessageModel *redpacket = redpacketMessage.redpacket;
        if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType ){            
            
                // 发红包的人可以显示所有被抢红包的消息
                // 抢红包的人显示自己的消息
                // 过滤掉空消息显示
            
           if (![redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]
                && ![redpacket.currentUser.userId isEqualToString:redpacket.redpacketReceiver.userId]) {
             
               return nil;
           }else if ([redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]){
               
               RedpacketTakenMessage *takenMessage = [RedpacketTakenMessage messageWithRedpacket:redpacket];
               RCMessage *m = [[RCIMClient sharedRCIMClient] insertMessage:message.conversationType
                                                                  targetId:message.targetId
                                                              senderUserId:redpacket.redpacketSender.userId
                                                                sendStatus:SentStatus_SENT
                                                                   content:takenMessage];
               [self appendAndDisplayMessage:m];
               return nil;
           
           }
        }
    } 
    return message;
}

- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    
    if (!self.displayUserNameInCell) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            model.isDisplayNickname = NO;
        }
    }
    RCMessageContent *messageContent = model.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        RedpacketMessageModel *redpacket = redpacketMessage.redpacket;
        if(RedpacketMessageTypeRedpacket == redpacket.messageType) {
            RedpacketMessageCell *cell = [collectionView
                                          dequeueReusableCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier
                                          forIndexPath:indexPath];
            [cell setDataModel:model];
            [cell setDelegate:self];
            return cell;
        }
        else if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType
                // 过滤掉空消息显示
                && [messageContent isKindOfClass:[RedpacketTakenMessage class]]){
            RedpacketTakenMessageTipCell *cell = [collectionView
                                      dequeueReusableCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier
                                      forIndexPath:indexPath];
            // 目前红包 SDK 不传递有效的 redpacketReceiver
            cell.tipMessageLabel.text = [redpacketMessage conversationDigest];
            [cell setDataModel:model];
            [cell setNeedsLayout];
            return cell;
        }
        else {
            return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
        }
    } else {
        return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[RedpacketMessageCell class]]) {
        RedpacketMessageCell *c = (RedpacketMessageCell *)cell;
        c.statusContentView.hidden = YES;
    }
    [super willDisplayMessageCell:cell atIndexPath:indexPath];
}

#pragma mark - 红包插件点击事件
- (void)didTapMessageCell:(RCMessageModel *)model {
    __weak typeof(self) weakself = self;
    if ([model.content isKindOfClass:[RedpacketMessage class]]) {
        if(RedpacketMessageTypeRedpacket == ((RedpacketMessage *)model.content).redpacket.messageType) {
            if ([self.chatSessionInputBarControl.inputTextView isFirstResponder]) {
                [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
            }
            
            RedpacketMessageModel * redPacketModel = ((RedpacketMessage *)model.content).redpacket;
            switch (self.conversationType) {
                case ConversationType_PRIVATE: {
                    RCUserInfo* info = [[RCDataBaseManager shareInstance] getUserByUserId:redPacketModel.redpacketSender.userId];
                    if (info) {
                        if ([redPacketModel.redpacketSender.userId isEqualToString:info.userId]) {
                            redPacketModel.redpacketSender.userNickname = info.name?info.name:redPacketModel.redpacketReceiver.userId;
                            redPacketModel.redpacketSender.userAvatar = info.portraitUri;
                        }
                    }
                    [RedpacketViewControl redpacketTouchedWithMessageModel:redPacketModel fromViewController:self redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
                        [weakself onRedpacketTakenMessage:messageModel];
                    } advertisementAction:nil];
                    break;
                }
                case ConversationType_DISCUSSION:
                case ConversationType_GROUP: {
                    [RedpacketViewControl redpacketTouchedWithMessageModel:redPacketModel fromViewController:self redpacketGrabBlock:^(RedpacketMessageModel *messageModel) {
                        [weakself onRedpacketTakenMessage:messageModel];
                    } advertisementAction:nil];
                    break;
                }
                default:
                    break;
            }
        }
    } else {
        [super didTapMessageCell:model];
        
    }
}

#pragma mark - 融云插件点击事件

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    // 由于不清楚的原因，RCIM 返回的 userNickname 时候是邮箱，但又不好判断是什么，所以每次都强制更新一下用户名
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    user.userId = self.targetId;
    user.userNickname = self.userName;
    __weak typeof(self) weakself = self;
    // 用户发红包的通知
    if (tag != 1603) {
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
        return;
    }
    
    switch (self.conversationType) {
        case ConversationType_PRIVATE:{
            [RedpacketViewControl presentRedpacketViewController:RPRedpacketControllerTypeSingle fromeController:self groupMemberCount:0 withRedpacketReceiver:user andSuccessBlock:^(RedpacketMessageModel *model) {
                [weakself sendRedpacketMessage:model];
            } withFetchGroupMemberListBlock:nil andGenerateRedpacketIDBlock:nil];
            break;
        }
        case ConversationType_DISCUSSION:
        {
            // 需要在界面显示讨论组员数量，需要先取得相应的数值
            [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
                                                 success:^(RCDiscussion *discussion) {
                                                     // 显示多人红包界面
                                                     [self.usersArray removeAllObjects];
                                                     for (NSString *targetId in discussion.memberIdList) {
                                                         [[RCDHttpTool shareInstance] getUserInfoByUserID:targetId
                                                                                               completion:^(RCUserInfo *user) {
                                                                                                   RedpacketUserInfo * userInfo = [RedpacketUserInfo new];
                                                                                                   userInfo.userId = user.userId;
                                                                                                   userInfo.userAvatar = user.portraitUri;
                                                                                                   userInfo.userNickname = user.name;
                                                                                                   if ([discussion.creatorId isEqualToString: user.userId]) {
                                                                                                       [self.usersArray insertObject:userInfo atIndex:0];
                                                                                                   }else{
                                                                                                       
                                                                                                       [self.usersArray addObject:userInfo];
                                                                                                   }
                                                                                               }];
                                                         
                                                     }

                                                     [RedpacketViewControl presentRedpacketViewController:RPRedpacketControllerTypeRand fromeController:self groupMemberCount:discussion.memberIdList.count withRedpacketReceiver:user andSuccessBlock:^(RedpacketMessageModel *model) {
                                                         [weakself sendRedpacketMessage:model];
                                                     } withFetchGroupMemberListBlock:^(RedpacketMemberListFetchBlock completionHandle) {
                                                         completionHandle(self.usersArray);
                                                     } andGenerateRedpacketIDBlock:nil];
                                                 } error:^(RCErrorCode status) {

                                                 }];
        }
            break;
        case ConversationType_GROUP:
        {
            [self.usersArray removeAllObjects];
            [[[RCDataBaseManager shareInstance] getGroupMember:self.targetId] enumerateObjectsUsingBlock:^(RCUserInfo *user, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:user.userId]) {
                    RedpacketUserInfo * userInfo = [RedpacketUserInfo new];
                    userInfo.userId = user.userId;
                    userInfo.userAvatar = user.portraitUri;
                    userInfo.userNickname = user.name;
                    [self.usersArray addObject:userInfo];
                }
            
            }];
            [RedpacketViewControl presentRedpacketViewController:RPRedpacketControllerTypeRand fromeController:self groupMemberCount:self.usersArray.count withRedpacketReceiver:user andSuccessBlock:^(RedpacketMessageModel *model) {
                [weakself sendRedpacketMessage:model];
            } withFetchGroupMemberListBlock:^(RedpacketMemberListFetchBlock completionHandle) {
                completionHandle(self.usersArray);
            } andGenerateRedpacketIDBlock:nil];
        }
            break;
        default:
            break;
    }
}


@end
