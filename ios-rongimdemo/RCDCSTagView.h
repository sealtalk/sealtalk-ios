//
//  RCDCSTagView.h
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#define button_height 30
#define button_width 130
#define horizental_space 21
#define vertical_space 15
@interface RCDCSTagView : UIView

@property (nonatomic, copy) void(^isSelectedTags)(NSDictionary *selectTags);

@property (nonatomic, strong) NSArray *tags;
- (void)setTags:(NSArray *)tags;
- (void)isMustSelect:(BOOL)isMustSelect;
@end
