//
//  ImageViewController.m
//  RongIMDemo
//
//  Created by litao on 15/3/31.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "ImageViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "RCAppQueryHelper.h"

@implementation ImageViewController

- (instancetype)init {
    self = [super init];
    NSLog(@"conversationController init");
    if (self) {
        // Initialize variables here.
        // Configure interface objects here.
        
        
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    RCMessage *msg = context;
    RCImageMessage *imgMsg = (RCImageMessage *)msg.content;
    
    if (imgMsg.originalImage) {
        [self.image setImage:imgMsg.originalImage];
        [self.loadingLabel setHidden:YES];
    } else {
        __weak ImageViewController  *weakSelf = self;
        [self.loadingLabel setHidden:NO];
        [RCAppQueryHelper requestParentAppLoadImage:msg.conversationType targetId:msg.targetId imageUrl:imgMsg.imageUrl reply:^(UIImage *image) {
            [weakSelf.image setImage:image];
            [self.loadingLabel setHidden:YES];
        }];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

@end
