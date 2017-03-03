//
//  ZYPinYinSearch.m
//  ZYPinYinSearch
//
//  Created by soufun on 15/7/27.
//  Copyright (c) 2015年 ZY. All rights reserved.
//

#import "YZHZYPinYinSearch.h"
#import "YZHChineseInclude.h"
#import "YZHPinYinForObjc.h"
#import "objc/runtime.h"
#import <UIKit/UIKit.h>
#import "YZHHCHeader.h"

@implementation YZHPinYinSearch
+(NSArray *)yzh_searchWithOriginalArray:(NSArray *)originalArray andSearchText:(NSString *)searchText andSearchByPropertyName:(NSString *)propertyName
{
    NSMutableArray * dataSourceArray = [[NSMutableArray alloc]init];
    NSString * type;
    if(originalArray.count <= 0){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"数据源不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return originalArray;
    }
    else{
        id object = originalArray[0];
        if ([object isKindOfClass:[NSString class]]) {
            type = @"string";
        }
        else if([object isKindOfClass:[NSDictionary class]]){
            type = @"dict";
            NSDictionary * dict = originalArray[0];
            NSLog(@"字典keys：%@",[dict allKeys]);
            BOOL isExit = NO;
            for (NSString * key in dict.allKeys) {
                if([key isEqualToString:propertyName]){
                    isExit = YES;
                    break;
                }
            }
            if (!isExit) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"数据源中的字典没有你指定的key:%@",propertyName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                return originalArray;
            }
        }
        else{
            type = @"model";
            NSMutableArray *props = [NSMutableArray array];
            unsigned int outCount, i;
            objc_property_t *properties = class_copyPropertyList([object class], &outCount);
            for (i = 0; i<outCount; i++)
            {
                objc_property_t property = properties[i];
                const char* char_f = property_getName(property);
                NSString *propertyName = [NSString stringWithUTF8String:char_f];
                [props addObject:propertyName];
            }
            NSLog(@"Model属性列表：%@",props);
            free(properties);
            BOOL isExit = NO;
            for (NSString * property in props) {
                if([property isEqualToString:propertyName]){
                    isExit = YES;
                    break;
                }
            }
            if (!isExit) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"数据源中的Model没有你指定的属性:%@",propertyName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                return originalArray;
            }

        }
    }
    if (searchText.length>0&&![YZHChineseInclude yzh_isIncludeChineseInString:searchText]) {
        for (int i=0; i<originalArray.count; i++) {
            NSString * tempString;
            if ([type isEqualToString:@"string"]) {
                tempString = originalArray[i];
            }
            else{
                tempString = [originalArray[i]valueForKey:propertyName];
            }
            if ([YZHChineseInclude yzh_isIncludeChineseInString:tempString]) {
                NSString *tempPinYinStr = [YZHPinYinForObjc yzh_chineseConvertToPinYin:tempString];
                NSLog(@"%@",tempPinYinStr);
                NSRange titleResult=[tempPinYinStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
                NSString *tempPinYinHeadStr = [YZHPinYinForObjc yzh_chineseConvertToPinYinHead:tempString];
                NSLog(@"%@",tempPinYinHeadStr);
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }
            else {
                NSRange titleResult=[tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [dataSourceArray addObject:originalArray[i]];
                    continue;
                }
            }
        }
    } else if (searchText.length>0&&[YZHChineseInclude yzh_isIncludeChineseInString:searchText]) {
        for (id object in originalArray) {
            NSString * tempString;
            if ([type isEqualToString:@"string"]) {
                tempString = object;
            }
            else{
                tempString = [object valueForKey:propertyName];
            }
            NSRange titleResult=[tempString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [dataSourceArray addObject:object];
            }
        }
    }
    return dataSourceArray;
}

@end
