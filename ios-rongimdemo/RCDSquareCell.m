//
//  RCDSquareCell.m
//  RCloudMessage
//
//  Created by Jue on 2016/10/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSquareCell.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>

@implementation RCDSquareCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithIconName:(NSString *)iconName TitleName:(NSString *)titleName {
    self = [super init];
    if (self) {
        self = [[RCDSquareCell alloc] initWithLeftImageStr:iconName
                                             leftImageSize:CGSizeMake(50, 50)
                                              rightImaeStr:nil
                                            rightImageSize:CGSizeZero];
        self.rightArrow.hidden = YES;
        self.leftImageCornerRadius = 5.f;
        self.leftLabel.text = titleName;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5" alpha:1.0];
    }
    return self;
}

@end
