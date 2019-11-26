//
//  RCDDebugAlertView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/10/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    RCDDebugAlertViewTypeSet,
    RCDDebugAlertViewTypeGet,
    RCDDebugAlertViewTypeDelete,
} RCDDebugAlertViewType;

@interface RCDDebugAlertView : UIView

typedef void (^FinishBlock)(RCDDebugAlertView *alertView);

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, assign) BOOL isNotice;
@property (nonatomic, strong) NSString *extra;

@property (nonatomic, copy) FinishBlock finishBlock;

- (instancetype)initWithAlertViewType:(RCDDebugAlertViewType)type;

@end

NS_ASSUME_NONNULL_END
