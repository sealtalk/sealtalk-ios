//
//  RCDCSAnnounceView.h
//  RCloudMessage
//
//  Created by 张改红 on 2017/8/31.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCDCSAnnounceViewDelegate <NSObject>
@optional
- (void)didTapViewAction;
@end

@interface RCDCSAnnounceView : UIView
@property (nonatomic,strong) UILabel *content;
@property (nonatomic,assign) BOOL hiddenArrowIcon;
@property (nonatomic,weak) id <RCDCSAnnounceViewDelegate> delegate;
@end
