//
//  RedpacketViewControl+RedpacketID.h
//  RedpacketLib
//
//  Created by Mr.Yang on 2017/1/20.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import "RedpacketViewControl.h"

@protocol RedpacketViewControlDelegate <NSObject>

@optional
@property (nonatomic, copy) RedpacketIDGenerateBlock generateBlock;
@property (nonatomic, copy) RedpacketCheckRedpacketStatusBlock checkRedpacketStatusBlock;

@end

@interface RedpacketViewControl (RedpacketID) <RedpacketViewControlDelegate>


@end
