//
//  RCDForwardCellModel.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/19.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDForwardCellModel.h"

@implementation RCDForwardCellModel

+ (instancetype)createModelWith:(RCConversation *)conversation {
    RCDForwardCellModel *model = [[RCDForwardCellModel alloc] init];
    model.targetId = conversation.targetId;
    model.conversationType = conversation.conversationType;
    return model;
}

@end
