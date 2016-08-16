//
//  IsPhoneNumber.h
//  KidsCare
//
//  Created by Jue on 15/6/21.
//  Copyright (c) 2015年 Jue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IsPhoneNumber : NSObject

+ (IsPhoneNumber *)PhoneNumberManager;

- (BOOL)isMobileNumber:(NSString *)mobileNum;

@end
