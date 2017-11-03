//
//  RCDSearchViewController.h
//  RCloudMessage
//
//  Created by 张改红 on 16/9/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCDSearchResultModel;
@protocol RCDSearchViewDelegate <NSObject>
- (void)onSearchCancelClick;
@end

@interface RCDSearchViewController : UIViewController <UINavigationControllerDelegate>

@property(nonatomic, weak) id<RCDSearchViewDelegate> delegate;

@end
