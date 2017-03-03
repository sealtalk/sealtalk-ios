//
//  NSBundle+RedpacketBundle.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSBundle (RedpacketBundle)

+ (NSBundle *)RedpacketBundle;

+ (id)loadNibFromClass:(Class)classPr;

+ (NSString *)loadImagePath:(NSString *)imageName;

@end
