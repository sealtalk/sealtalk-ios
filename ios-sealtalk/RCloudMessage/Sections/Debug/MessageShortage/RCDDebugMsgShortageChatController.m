//
//  RCDDebugMsgShortageChatController.m
//  SealTalk
//
//  Created by 张改红 on 2021/4/29.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCDDebugMsgShortageChatController.h"
#import "UIView+MBProgressHUD.h"
#import "NormalAlertView.h"
#import "RCDTipMessageCell.h"
#import "RCDGroupNotificationMessage.h"
#import "RCDChatNotificationMessage.h"
@interface RCDDebugMsgShortageChatController ()
@property (nonatomic, assign) BOOL isTouchScrolled; /// 表示是否是触摸滚动
@property (nonatomic, strong) dispatch_queue_t msgQueue;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation RCDDebugMsgShortageChatController
- (instancetype)init{
    self = [super init];
    if (self) {
        self.msgQueue = dispatch_queue_create("rcd_get_messages_queue",NULL);
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDGroupNotificationMessage.class];
    [self registerClass:RCDTipMessageCell.class forMessageClass:RCDChatNotificationMessage.class];
    
    [self.conversationDataRepository removeAllObjects];
    [self.conversationMessageCollectionView reloadData];
    [self loadMoreHistoryMessageIfNeed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // isTouchScrolled 只有人为滑动页面才需要加载更新或者更旧的消息
    // 其他的时机如 reloadData 和弹出键盘等不需要加载消息
    if (scrollView.contentOffset.y <= 0 && self.isTouchScrolled) {
        [self loadMoreHistoryMessageIfNeed];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height && self.isTouchScrolled) {
        [self LoadMoreNewerMessage];
    }
}


//点击状态栏屏蔽系统动作手动滚动到顶部并加载历史消息
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.conversationMessageCollectionView numberOfItemsInSection:0] > 0) {
        [self.conversationMessageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       atScrollPosition:(UICollectionViewScrollPositionTop)
                                                               animated:YES];
    }
    [self loadMoreHistoryMessageIfNeed];
    return NO;
}

- (void)loadMoreHistoryMessageIfNeed{
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.msgQueue,^{
        RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
        if (self.conversationDataRepository.count > 0) {
            RCMessageModel *model = self.conversationDataRepository[0];
            option.recordTime = model.sentTime;
        }else{
            option.recordTime = 0;
        }
        option.count = 20;
        option.order = RCRemoteHistoryOrderDesc;
        [[RCCoreClient sharedCoreClient] getMessages:weakSelf.conversationType targetId:weakSelf.targetId option:option complete:^(NSArray *messages, RCErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.isLoading = NO;
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (code == RC_SUCCESS) {
                    [weakSelf displayMessages:messages];
                    [weakSelf.conversationMessageCollectionView reloadData];
                    [weakSelf.conversationMessageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionTop) animated:NO];
                }else{
                    [NormalAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"可能存在断档，但从远端拉消息失败: %ld",code] describeTitle:nil confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
                        
                    }];
                }
            });
        }];
    });
}

- (void)LoadMoreNewerMessage{
    if (self.isLoading) {
        return;
    }
    self.isLoading = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.msgQueue,^{
        RCHistoryMessageOption *option = [[RCHistoryMessageOption alloc] init];
        if (weakSelf.conversationDataRepository.count > 0) {
            RCMessageModel *model = self.conversationDataRepository.lastObject;
            option.recordTime = model.sentTime;
        }else{
            option.recordTime = 0;
        }
        option.count = 20;
        option.order = RCRemoteHistoryOrderAsc;
        [[RCCoreClient sharedCoreClient] getMessages:weakSelf.conversationType targetId:weakSelf.targetId option:option complete:^(NSArray *messages, RCErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.isLoading = NO;
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (code == RC_SUCCESS) {
                    for (int i = (int)messages.count-1; i >=0 ; i--) {
                        [weakSelf appendAndDisplayMessage:messages[i]];
                    }
                }else{
                    [NormalAlertView showAlertWithTitle:nil message:[NSString stringWithFormat:@"可能存在断档，但从远端拉消息失败: %ld",code] describeTitle:nil confirmTitle:RCDLocalizedString(@"confirm") confirm:^{
                    }];
                }
            });
        }];
    });
}

- (void)displayMessages:(NSArray *)messageArray{
    for (int i = 0; i < messageArray.count; i++) {
        RCMessage *rcMsg = [messageArray objectAtIndex:i];
        RCMessageModel *model = [RCMessageModel modelWithMessage:rcMsg];
        [self pushOldMessageModel:model];
    }
    [self figureOutAllConversationDataRepository];
}

- (BOOL)pushOldMessageModel:(RCMessageModel *)model {
    if (!(!model.content && model.messageId > 0 && RCKitConfigCenter.message.showUnkownMessage) &&
        !([[model.content class] persistentFlag] & MessagePersistent_ISPERSISTED)) {
        return NO;
    }
    long ne_wId = model.messageId;
    for (RCMessageModel *__item in self.conversationDataRepository) {
        if (ne_wId == __item.messageId && ne_wId != -1) {
            return NO;
        }
    }
    if (model && model.sentTime == MessageDirection_RECEIVE) {
        model.isDisplayNickname = self.displayUserNameInCell;
    }
    [self.conversationDataRepository insertObject:model atIndex:0];
    return YES;
}
    
- (void)figureOutAllConversationDataRepository {
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
        } else if (i > 0) {
            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];
            
            long long previous_time = pre_model.sentTime;
            
            long long current_time = model.sentTime;
            
            long long interval =
            current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            if (interval / 1000 <= 3 * 60) {
                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height - 45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = NO;
            }
        }
    }
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {
    if ([messageContent isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *mesage = messageContent;
        [self showAlertController:mesage.referMsgUid];
    }
}
-(void)showAlertController:(NSString *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:nil
                         message:info
                  preferredStyle:UIAlertControllerStyleAlert];
    [alertController
        addAction:[UIAlertAction actionWithTitle:@"确定"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *_Nonnull action) {
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }]];
    [self presentViewController:alertController animated:NO completion:nil];
    });
}
@end
