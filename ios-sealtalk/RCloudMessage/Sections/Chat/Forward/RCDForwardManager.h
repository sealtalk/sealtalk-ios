//
//  RCDForwardManager.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RCDForwardAlertView.h"
#import "RCDForwardCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDForwardManager : NSObject <RCDForwardAlertViewDelegate>
+ (RCDForwardManager *)sharedInstance;
@property (nonatomic, assign) BOOL isForward;
@property (nonatomic, assign) BOOL isMultiSelect;
@property (nonatomic, strong, nullable) NSArray *selectedMessages;
@property (nonatomic, strong, nullable) RCConversation *toConversation;
@property (nonatomic, strong) NSMutableArray *selectedContactArray;

@property (nonatomic, assign, readonly) NSInteger friendCount;
@property (nonatomic, assign, readonly) NSInteger groupCount;

@property (nonatomic, copy) void (^willForwardMessageBlock)(RCConversationType type, NSString *targetId);
@property (nonatomic, copy) void (^selectConversationCompleted)(NSArray<RCConversation *> *conversationList);

- (void)showForwardAlertViewInViewController:(UIViewController *)viewController;
- (BOOL)allSelectedMessagesAreLegal;
- (void)clear;
- (void)forwardEnd;

- (NSArray *)getForwardModelArray;
- (void)addForwardModel:(RCDForwardCellModel *)model;
- (void)removeForwardModel:(RCDForwardCellModel *)model;
- (void)clearForwardModelArray;

- (BOOL)modelIsContains:(NSString *)targetId;

@end

NS_ASSUME_NONNULL_END
