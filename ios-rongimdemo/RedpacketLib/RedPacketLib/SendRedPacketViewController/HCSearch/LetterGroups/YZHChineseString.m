//
//  ChineseString.m


#import "YZHChineseString.h"

@implementation YZHChineseString
@synthesize yzh_string;
@synthesize yzh_pinYin;

#pragma mark - 返回tableview右方 indexArray
+(NSMutableArray*)yzh_IndexArray:(NSArray*)stringArr
{
    //返回排序好的字符拼音 ReturnSortChineseArrar
    NSMutableArray *tempArray = [self yzh_ReturnSortChineseArrar:stringArr];
    
    NSMutableArray *A_Result=[NSMutableArray array];
    NSString *tempString ;
    
    for (NSString* object in tempArray)
    {
        NSString *pinyin = [((YZHChineseString*)object).yzh_pinYin substringToIndex:1];
        //不同
        if(![tempString isEqualToString:pinyin])
        {
           // NSLog(@"IndexArray----->%@",pinyin);
            [A_Result addObject:pinyin];
            tempString = pinyin;
        }
    }
        return A_Result;
}

#pragma mark - 返回联系人（按字母分组，数组中包含数组 例如 A：安... B:北... C:...）
+(NSMutableArray*)yzh_LetterSortArray:(NSArray*)stringArr
{
    //返回排序好的字符拼音 ReturnSortChineseArrar
    NSMutableArray *tempArray = [self yzh_ReturnSortChineseArrar:stringArr];
    //分组存放首字母相同的string
    NSMutableArray *LetterResult=[NSMutableArray array];
    NSMutableArray *item = [NSMutableArray array];
    NSString *tempString ;
    //拼音分组
    for (NSString* object in tempArray) {

         NSString *pinyin = [((YZHChineseString*)object).yzh_pinYin substringToIndex:1];
         NSString *string = ((YZHChineseString*)object).yzh_string;
        //不同
        if(![tempString isEqualToString:pinyin])
        {
            //分组
            item = [NSMutableArray array];
            [item  addObject:string];
            [LetterResult addObject:item];//1.
            //遍历
            tempString = pinyin;
        }else//相同
        {
            [item  addObject:string];//由1.可知，item但指针指向了LetterResult，所以再只执行[item  addObject:string]时，也隐含执行[LetterResult addObject:item]//1.
        }
    }
    return LetterResult;
}

//过滤指定字符串   里面的指定字符根据自己的需要添加
+(NSString*)yzh_RemoveSpecialCharacter: (NSString *)str {
//    NSRange urgentRange = [str rangeOfCharacterFromSet:
//                           [NSCharacterSet characterSetWithCharactersInString:
//                            @",.？、 ~￥#&<>《》()[]{}【】^@/￡¤|§¨「」『』￠￢￣~@#&*（）——+|《》$_€"]];
//    if (urgentRange.location != NSNotFound)
//    {
//        return [self yzh_RemoveSpecialCharacter:[str stringByReplacingCharactersInRange:urgentRange withString:@""]];
//    }
    return str;
}

///////////////////
//
//返回排序好的字符拼音
//
///////////////////
+(NSMutableArray*)yzh_ReturnSortChineseArrar:(NSArray*)stringArr
{
    //获取字符串中文字的拼音首字母并与字符串共同存放
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[stringArr count];i++)
    {
        YZHChineseString *chineseString=[[YZHChineseString alloc]init];
        chineseString.yzh_string=[NSString stringWithString:[stringArr objectAtIndex:i]];
        if(chineseString.yzh_string==nil){
            chineseString.yzh_string=@"";
        }
        //去除两端空格和回车
        chineseString.yzh_string  = [chineseString.yzh_string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        //此方法存在一些问题 有些字符过滤不了
        //NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
        //chineseString.string = [chineseString.string stringByTrimmingCharactersInSet:set];
        
        
        //这里我自己写了一个递归过滤指定字符串   RemoveSpecialCharacter
        chineseString.yzh_string =[YZHChineseString yzh_RemoveSpecialCharacter:chineseString.yzh_string];
       // NSLog(@"string====%@",chineseString.string);
        
        
        //判断首字符是否为字母
        NSString *regex = @"[A-Za-z]+";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        NSString *header = [chineseString.yzh_string substringToIndex:1];
        if ([predicate evaluateWithObject:header])
        {
            //首字母大写
            chineseString.yzh_pinYin = [chineseString.yzh_string capitalizedString] ;
        }else{
            if(![chineseString.yzh_string isEqualToString:@""]){
                NSString *pinYinResult=[NSString string];
                if ([[chineseString.yzh_string substringToIndex:1] isEqualToString:@"长"]) {
                    pinYinResult = @"C";
                }else{
                     NSString *headLetter = [[self transform:chineseString.yzh_string] substringToIndex:1];
                    char commitChar = [headLetter characterAtIndex:0];
                    if (commitChar >= 'A' && commitChar <= 'Z') {
                        pinYinResult=[pinYinResult stringByAppendingString:headLetter];
                    }else{
                        pinYinResult = @"{";
                    }
//                    pinYinResult=[pinYinResult stringByAppendingString:headLetter];
                }

//                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",
//                                                   pinyinFirstLetter([chineseString.string
//                                                                      characterAtIndex:0])]uppercaseString];
//                    
//                    pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            
                chineseString.yzh_pinYin=pinYinResult;
            }else{
                chineseString.yzh_pinYin=@"";
            }
        }
        [chineseStringsArray addObject:chineseString];
    }
    //按照拼音首字母对这些Strings进行排序
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"yzh_pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];

    return chineseStringsArray;
}

+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}

#pragma mark - 返回一组字母排序数组
+(NSMutableArray*)yzh_SortArray:(NSArray*)stringArr
{
    NSMutableArray *tempArray = [self yzh_ReturnSortChineseArrar:stringArr];
    
    //把排序好的内容从ChineseString类中提取出来
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[stringArr count];i++){
        [result addObject:((YZHChineseString*)[tempArray objectAtIndex:i]).yzh_string];
        NSLog(@"SortArray----->%@",((YZHChineseString*)[tempArray objectAtIndex:i]).yzh_string);
    }
    return result;
}
@end