//
//  RPPayViewCell.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/3.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPPayViewCell.h"
#import "RedpacketColorStore.h"
#import "RPRedpacketTool.h"


@implementation RPPayViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.contentView.bounds;
        button.autoresizingMask =     UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight
                                    | UIViewAutoresizingFlexibleTopMargin
                                    | UIViewAutoresizingFlexibleBottomMargin;
        
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [button addTarget:self action:@selector(cellClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
   
    return self;
}

- (void)configWithPayInfo:(YZHPayInfo *)payInfo
{
    if (!payInfo) return;
    
    _payInfo = payInfo;
    self.imageView.image = rpRedpacketBundleImage(payInfo.payImage);
    self.textLabel.text = payInfo.payName;
    self.detailTextLabel.text = payInfo.describe;
    
    self.textLabel.font = [UIFont systemFontOfSize:15.0f];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.minimumScaleFactor = .6;
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    self.detailTextLabel.textColor = [RedpacketColorStore rp_textColorLightGray];
    
    if (payInfo.isAValiable) {
        self.textLabel.textColor = [RedpacketColorStore rp_textColorBlack];
        
    }else {
        self.textLabel.textColor = [RedpacketColorStore rp_textColorLightGray];
    }
}

- (void)cellClicked:(UIButton *)button
{
    if (_payInfo.isAValiable) {
        
        [self setHighlighted:YES animated:NO];
        
        if (_toucheBlock) {
            _toucheBlock(self);
        }
    }
}

@end
