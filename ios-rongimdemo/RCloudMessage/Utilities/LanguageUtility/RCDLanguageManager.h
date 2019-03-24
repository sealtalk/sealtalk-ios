//
//  RCDLanguageManager.h
//  LanguageSettingDemo
//
//  Created by 孙浩 on 2019/2/17.
//  Copyright © 2019 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCDLanguageManager : NSObject

// 当前的国际化语言
@property(nonatomic, copy, readonly) NSString *localzableLanguage;

/**
 单例方法
 
 @return 单例对象
 */
+ (instancetype)sharedRCDLanguageManager;

/**
 设置当前的国际化语言
 
 @param Language 当前的国际化语言，请参考上面的RCLocalizableLanguageDefault
 */
- (void)setLocalizableLanguage:(NSString *)Language;


@end

NS_ASSUME_NONNULL_END
