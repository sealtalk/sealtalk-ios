//
//  MMEmoji.h
//  BQMM SDK
//
//  Created by ceo on 11/2/15.
//  Copyright © 2015 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMEmoji : NSObject

/**
 *  emoji id
 */
@property (nonatomic, copy, nullable) NSString *emojiId;

/**
 *  emoji name
 */
@property (nonatomic, copy, nullable) NSString *emojiName;

/**
 *  emoji code
 */
@property (nonatomic, copy, nullable) NSString *emojiCode;

/**
 *  emoji image
 */
@property (nonatomic, strong, nullable) UIImage *emojiImage;

/**
 *  emoji data
 */
@property (nonatomic, strong, nullable) NSData *emojiData;

/**
 *  package id
 */
@property (nonatomic, copy, nullable) NSString *packageId;
/**
 *  is small emoji?
 */
@property (nonatomic, assign) BOOL isEmoji;

@end
