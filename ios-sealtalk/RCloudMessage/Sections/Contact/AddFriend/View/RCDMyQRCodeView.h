//
//  RCDMyQRCodeView.h
//  SealTalk
//
//  Created by 孙浩 on 2019/7/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCDMyQRCodeViewDelegate <NSObject>

- (void)myQRCodeViewShareSealTalk;

@end

@interface RCDMyQRCodeView : UIView

@property (nonatomic, weak) id<RCDMyQRCodeViewDelegate> delegate;

- (void)show;

@end

NS_ASSUME_NONNULL_END
