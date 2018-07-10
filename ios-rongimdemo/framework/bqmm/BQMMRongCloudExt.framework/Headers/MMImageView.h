//
//  MMImageView.h
//  StampMeSDK
//
//  Created by Tender on 16/03/2018.
//  Copyright © 2018 siyanhui. All rights reserved.
//

#ifndef MMImageView_h
#define MMImageView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MMEmoji;

@interface MMImageView: UIView

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *errorImage;


+ (CGSize)sizeForImageSize:(CGSize)size imgMaxSize: (CGSize)mSize;

- (void)prepareForReuse;

- (void)setImageWithEmojiCode:(NSString * _Nonnull)emojiCode;
- (void)setImageWithEmojiCode:(NSString * _Nonnull)emojiCode completHandler:(void (^_Nullable)(BOOL success))handler;

- (void)setImageWithUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId;
- (void)setImageWithUrl:(NSString * _Nonnull)urlString gifId:(NSString * _Nonnull)gifId  completHandler:(void (^_Nullable)(BOOL success))handler;
@end

#endif /* MMImageView_h */
