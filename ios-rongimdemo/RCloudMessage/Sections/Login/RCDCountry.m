//
//  RCDCountry.m
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCDCountry.h"
@interface RCDCountry ()
@property (nonatomic, strong) NSDictionary *locale;
@property (nonatomic, strong) NSString *countryName;
@end
@implementation RCDCountry
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.phoneCode = [dict objectForKey:@"region"];
        NSDictionary *locale = [dict objectForKey:@"locale"];
        self.locale = locale;
    }
    return self;
}

- (NSDictionary *)getModelJson {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.phoneCode forKey:@"region"];
    [dic setObject:self.locale forKey:@"locale"];
    return dic.copy;
}

- (NSString *)countryName {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage containsString:@"zh-Hans"]) {
        return self.locale[@"zh"];
    } else {
        return self.locale[@"en"];
    }
    return nil;
}

@end
