//
//  RCDMeDetailsCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/9.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDMeDetailsCell.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
#import <RongIMKit/RongIMKit.h>

@implementation RCDMeDetailsCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    if (self) {
        NSString *portraitUrl = [DEFAULTS stringForKey:@"userPortraitUri"];
        if ([portraitUrl isEqualToString:@""]) {
            portraitUrl = [RCDUtilities defaultUserPortrait:[RCIM sharedRCIM].currentUserInfo];
        }
        self = [[RCDMeDetailsCell alloc] initWithLeftImageStr:portraitUrl
                                                leftImageSize:CGSizeMake(65, 65)
                                                 rightImaeStr:nil
                                               rightImageSize:CGSizeZero];
        self.leftImageCornerRadius = 5.f;
        self.leftLabel.text = [DEFAULTS stringForKey:@"userNickName"];
    }
    return self;
}

@end
