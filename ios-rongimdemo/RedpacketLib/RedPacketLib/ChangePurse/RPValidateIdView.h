//
//  RPValidateIdView.h
//  RedpacketLib
//
//  Created by Mr.Yan on 2016/11/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ValidateIDViewType) {
    ValidateIDViewReady,
    ValidateIDViewUpload,
    ValidateIDViewSuccess,
    ValidateIDViewFalie,
    ValidateIDViewValideFalie,
    ValidateIDViewPickFinished
};

@interface RPValidateIdView : UIView

@property (nonatomic, copy) void(^imageViewTouched)(BOOL isLeft);

@property (nonatomic, assign)   BOOL isLeft;

@property (nonatomic)  UIImageView *imageViewLeft;
@property (nonatomic)  UIImageView *imageViewRight;

@property (nonatomic, assign)   ValidateIDViewType leftImageViewtype;
@property (nonatomic, assign)   ValidateIDViewType rightImageViewtype;

- (void)refreshUploadImage:(UIImage *)image;


@end
