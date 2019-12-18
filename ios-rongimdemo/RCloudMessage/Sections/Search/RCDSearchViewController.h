//
//  RCDSearchViewController.h
//  RCloudMessage
//
//  Created by 张改红 on 16/9/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDViewController.h"
@class RCDSearchResultModel;
@protocol RCDSearchViewDelegate <NSObject>
- (void)searchViewControllerDidClickCancel;
@end

@interface RCDSearchViewController : RCDViewController <UINavigationControllerDelegate>

@property (nonatomic, weak) id<RCDSearchViewDelegate> delegate;

@end
