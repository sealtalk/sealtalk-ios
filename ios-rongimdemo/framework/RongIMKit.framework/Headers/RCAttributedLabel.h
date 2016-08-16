//
//  RCAttributedLabel.h
//  iOS-IMKit
//
//  Created by YangZigang on 14/10/29.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  RCAttributedLabelClickedTextInfo
 */
@interface RCAttributedLabelClickedTextInfo : NSObject
/**
 *  NSTextCheckingType
 */
@property(nonatomic, assign) NSTextCheckingType textCheckingType;
/**
 *  text
 */
@property(nonatomic, strong) NSString *text;

@end

/**
 *  RCAttributedDataSource
 */
@protocol RCAttributedDataSource <NSObject>
/**
 *  attributeDictionaryForTextType
 *
 *  @param textType textType
 *
 *  @return return NSDictionary
 */
- (NSDictionary *)attributeDictionaryForTextType:(NSTextCheckingTypes)textType;
/**
 *  highlightedAttributeDictionaryForTextType
 *
 *  @param textType textType
 *
 *  @return NSDictionary
 */
- (NSDictionary *)highlightedAttributeDictionaryForTextType:(NSTextCheckingType)textType;

@end

@protocol RCAttributedLabelDelegate;

/**
 *  Override UILabel @property to accept both NSString and NSAttributedString
 */
@protocol RCAttributedLabel <NSObject>

/**
 *  text
 */
@property (nonatomic, copy) id text;

@end
/**
 *  RCAttributedLabel
 */
@interface RCAttributedLabel : UILabel <RCAttributedDataSource,UIGestureRecognizerDelegate>
/**
 * 可以通过设置attributeDataSource或者attributeDictionary、highlightedAttributeDictionary来自定义不同文本的字体颜色
 */
@property(nonatomic, strong) id<RCAttributedDataSource> attributeDataSource;
/**
 * 可以通过设置attributedStrings可以给一些字符添加点击事件等，例如在实现的会话列表里修改文本消息内容
 *  -(void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath{
 *
 *   if ([cell isKindOfClass:[RCTextMessageCell class]]) {
 *      RCTextMessageCell *newCell = (RCTextMessageCell *)cell;
 *      if (newCell.textLabel.text.length>3) {
 *          NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:(NSMakeRange(0, 3)) URL:[NSURL URLWithString:@"http://www.baidu.com"]];
 *          [newCell.textLabel.attributedStrings addObject:textCheckingResult];
 *          [newCell.textLabel setTextHighlighted:YES atPoint:CGPointMake(0, 3)];
 *       }
 *    }
 *}
 *
 */
@property(nonatomic, strong) NSMutableArray *attributedStrings;
/*!
 点击回调
 */
@property (nonatomic, weak) id <RCAttributedLabelDelegate> delegate;
/**
 *  attributeDictionary
 */
@property(nonatomic, strong) NSDictionary *attributeDictionary;
/**
 *  highlightedAttributeDictionary
 */
@property(nonatomic, strong) NSDictionary *highlightedAttributeDictionary;
/**
 *  NSTextCheckingTypes 格式类型
 */
@property(nonatomic, assign) NSTextCheckingTypes textCheckingTypes;
/**
 *  NSTextCheckingTypes current格式类型
 */
@property(nonatomic, readonly, assign) NSTextCheckingType currentTextCheckingType;
/**
 *  setTextdataDetectorEnabled
 *
 *  @param text                text
 *  @param dataDetectorEnabled dataDetectorEnabled
 */
- (void)setText:(NSString *)text dataDetectorEnabled:(BOOL)dataDetectorEnabled;
/**
 *  textInfoAtPoint
 *
 *  @param point point
 *
 *  @return RCAttributedLabelClickedTextInfo
 */
- (RCAttributedLabelClickedTextInfo *)textInfoAtPoint:(CGPoint)point;
/**
 *  setTextHighlighted
 *
 *  @param highlighted highlighted
 *  @param point       point
 */
- (void)setTextHighlighted:(BOOL)highlighted atPoint:(CGPoint)point;

@end

/*!
 RCAttributedLabel点击回调
 */
@protocol RCAttributedLabelDelegate <NSObject>
@optional

/*!
 点击URL的回调
 
 @param label 当前Label
 @param url   点击的URL
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url;

/*!
 点击电话号码的回调
 
 @param label       当前Label
 @param phoneNumber 点击的URL
 */
- (void)attributedLabel:(RCAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber;

/*!
 点击Label的回调
 
 @param label   当前Label
 @param content 点击的内容
 */
- (void)attributedLabel:(RCAttributedLabel *)label didTapLabel:(NSString *)content;

@end

