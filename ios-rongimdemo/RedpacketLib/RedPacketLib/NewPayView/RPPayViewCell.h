//
//  RPPayViewCell.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccoutModel.h"


@class RPPayViewCell;

typedef void (^CellTouchBlock)(RPPayViewCell *);

@interface RPPayViewCell : UITableViewCell

@property (nonatomic, strong) YZHPayInfo *payInfo;
@property (nonatomic, copy)   CellTouchBlock toucheBlock;

- (void)configWithPayInfo:(YZHPayInfo *)payInfo;

@end
