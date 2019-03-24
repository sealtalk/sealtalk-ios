//
//  NSBundle+RCUtils.m
//  LanguageSettingDemo
//
//  Created by 孙浩 on 2019/2/17.
//  Copyright © 2019 rongcloud. All rights reserved.
//

#import "NSBundle+RCUtils.h"
#import "RCDLanguageManager.h"
#import <objc/runtime.h>

@interface RCDBundle : NSBundle

@end

@implementation NSBundle (RCUtils)

+ (NSString *)currentLanguage {
    
    return [RCDLanguageManager sharedRCDLanguageManager].localzableLanguage ? : [NSLocale preferredLanguages].firstObject;
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [RCDBundle class]);
    });
}

@end


@implementation RCDBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    
    if ([RCDBundle rcd_mainBundle]) {
        return [[RCDBundle rcd_mainBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

+ (NSBundle *)rcd_mainBundle {
    
    if ([NSBundle currentLanguage].length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSBundle currentLanguage] ofType:@"lproj"];
        if (path.length) {
            return [NSBundle bundleWithPath:path];
        }
    }
    return nil;
}

@end
