//
//  RCDLanguageManager.m
//  LanguageSettingDemo
//
//  Created by 孙浩 on 2019/2/17.
//  Copyright © 2019 rongcloud. All rights reserved.
//

#import "RCDLanguageManager.h"

static NSString *const RCDUserLanguageKey = @"RCDUserLanguageKey";
#define RC_USERDEFAULTS  [NSUserDefaults standardUserDefaults]

@interface RCDLanguageManager ()

@property(nonatomic, copy) NSString *localzableLanguage;

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
    
    if (![_localzableLanguage isEqualToString:Language]) {
        [RC_USERDEFAULTS setValue:Language forKey:RCDUserLanguageKey];
        [RC_USERDEFAULTS setValue:@[Language] forKey:@"AppleLanguages"];
    }
}

- (NSString *)localzableLanguage {
    NSString *userLanguage = [RC_USERDEFAULTS valueForKey:RCDUserLanguageKey];
    if(!userLanguage){
        NSArray *languages = [NSLocale preferredLanguages];
        userLanguage = [languages objectAtIndex:0];
        if ([userLanguage containsString:@"en"]) {
            userLanguage = @"en";
        }else if ([userLanguage containsString:@"zh-Hans"]){
            userLanguage = @"zh-Hans";
        }
    }
    return userLanguage ? userLanguage : @"default";
}

- (void)resetLanguage {
    
    [RC_USERDEFAULTS removeObjectForKey:RCDUserLanguageKey];
    [RC_USERDEFAULTS setValue:nil forKey:@"AppleLanguages"];
}

@end
