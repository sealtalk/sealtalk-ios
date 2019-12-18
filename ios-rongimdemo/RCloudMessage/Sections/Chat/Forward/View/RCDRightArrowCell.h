//
//  RCDRightArrowCell.h
//  SealTalk
//
//  Created by 孙浩 on 2019/6/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCDRightArrowCell : RCDTableViewCell

@property (nonatomic, strong) UILabel *leftLabel;

@property (nonatomic, strong) UIImageView *rightArrow;

- (void)setLeftText:(NSString *)leftText;

@end

NS_ASSUME_NONNULL_END
