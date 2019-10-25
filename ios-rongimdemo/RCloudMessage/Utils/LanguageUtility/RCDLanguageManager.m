//
//  RCDLanguageManager.m
//  LanguageSettingDemo
//
//  Created by 孙浩 on 2019/2/17.
//  Copyright © 2019 rongcloud. All rights reserved.
//

#import "RCDLanguageManager.h"

static NSString *const RCDUserLanguageKey = @"RCDUserLanguageKey";
static NSString *const RCDAppleLanguagesKey = @"AppleLanguages";

@interface RCDLanguageManager ()

@property (nonatomic, copy) NSString *currentLanguage;

@end

@implementation RCDLanguageManager

+ (instancetype)sharedRCDLanguageManager {

    static RCDLanguageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)setLocalizableLanguage:(NSString *)Language {
    if (Language.length == 0) {
        [self resetLanguage];
        return;
    }

    if (![_currentLanguage isEqualToString:Language]) {
        [DEFAULTS setValue:Language forKey:RCDUserLanguageKey];
        [DEFAULTS setValue:@[ Language ] forKey:RCDAppleLanguagesKey];
    }
}

- (NSString *)currentLanguage {
    NSString *userLanguage = [DEFAULTS valueForKey:RCDUserLanguageKey];
    if (!userLanguage) {
        NSArray *languages = [NSLocale preferredLanguages];
        userLanguage = [languages objectAtIndex:0];
        if ([userLanguage containsString:@"en"]) {
            userLanguage = @"en";
        } else if ([userLanguage containsString:@"zh-Hans"]) {
            userLanguage = @"zh-Hans";
        }
    }
    return userLanguage ? userLanguage : @"default";
}

- (void)resetLanguage {

    [DEFAULTS removeObjectForKey:RCDUserLanguageKey];
    [DEFAULTS setValue:nil forKey:RCDAppleLanguagesKey];
}

@end
