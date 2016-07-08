//
//  DefaultPortraitView.h
//  RCloudMessage
//
//  Created by Jue on 16/3/31.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultPortraitView : UIView

@property(nonatomic, strong) NSString *firstCharacter;

- (void)setColorAndLabel:(NSString *)userId Nickname:(NSString *)nickname;

- (UIImage *)imageFromView;

@end
