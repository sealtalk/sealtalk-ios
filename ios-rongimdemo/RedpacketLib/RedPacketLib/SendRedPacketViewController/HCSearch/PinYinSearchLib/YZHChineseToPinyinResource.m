//
//
//
//  Created by kimziv on 13-9-14.
//

#import "NSBundle+RedpacketBundle.h"
#include "YZHChineseToPinyinResource.h"
#define YZHLEFT_BRACKET @"("
#define YZHRIGHT_BRACKET @")"
#define YZHCOMMA @","

#define YZHkCacheKeyForUnicode2Pinyin @"cache.key.for.unicode.to.pinyin"

static inline NSString* YZHcachePathForKey(NSString* directory, NSString* key) {
	return [directory stringByAppendingPathComponent:key];
}

@interface YZHChineseToPinyinResource ()
- (id<NSCoding>)yzh_cachedObjectForKey:(NSString*)key;
-(void)yzh_cacheObjec:(id<NSCoding>)obj forKey:(NSString *)key;

@end

@implementation YZHChineseToPinyinResource
//@synthesize unicodeToHanyuPinyinTable=_unicodeToHanyuPinyinTable;
//- (NSDictionary *)getUnicodeToHanyuPinyinTable {
//    return _unicodeToHanyuPinyinTable;
//}

- (id)init {
    if (self = [super init]) {
        _yzh_unicodeToHanyuPinyinTable = nil;
        [self yzh_initializeResource];
    }
    return self;
}

- (void)yzh_initializeResource {
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	NSString* oldCachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"PinYinCache"] copy];
    
	if([[NSFileManager defaultManager] fileExistsAtPath:oldCachesDirectory]) {
		[[NSFileManager defaultManager] removeItemAtPath:oldCachesDirectory error:NULL];
	}
	
	_yzh_directory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle RedpacketBundle] bundleIdentifier]] stringByAppendingPathComponent:@"PinYinCache"] copy];
    
    NSDictionary *dataMap=(NSDictionary *)[self yzh_cachedObjectForKey:YZHkCacheKeyForUnicode2Pinyin];
    if (dataMap) {
        self->_yzh_unicodeToHanyuPinyinTable=dataMap;
    }else{
        NSString *resourceName =[[NSBundle RedpacketBundle] pathForResource:@"yzh_unicode_to_hanyu_pinyin" ofType:@"txt"];
        NSString *dictionaryText=[NSString stringWithContentsOfFile:resourceName encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dictionaryText componentsSeparatedByString:@"\r\n"];
        __block NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] init];
        @autoreleasepool {
            [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *lineComponents=[obj componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //NSLog(@"%@, %@",lineComponents[0],lineComponents[1]);
                [tempMap setObject:lineComponents[1] forKey:lineComponents[0]];
            }];
        }
        self->_yzh_unicodeToHanyuPinyinTable=tempMap;
        [self yzh_cacheObjec:self->_yzh_unicodeToHanyuPinyinTable forKey:YZHkCacheKeyForUnicode2Pinyin];
    }
}

- (id<NSCoding>)yzh_cachedObjectForKey:(NSString*)key
{
    NSData *data = [NSData dataWithContentsOfFile:YZHcachePathForKey(_yzh_directory, key) options:0 error:NULL];
    if (data) {
           return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

-(void)yzh_cacheObjec:(id<NSCoding>)obj forKey:(NSString *)key
{
    NSData* data= [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSString* cachePath = YZHcachePathForKey(_yzh_directory, key);
	dispatch_async(dispatch_get_main_queue(), ^{
        [data writeToFile:cachePath atomically:YES];
    });
}

- (NSArray *)yzh_getHanyuPinyinStringArrayWithChar:(unichar)ch {
    NSString *pinyinRecord = [self yzh_getHanyuPinyinRecordFromCharWithChar:ch];
    if (nil != pinyinRecord) {
        NSRange rangeOfLeftBracket= [pinyinRecord rangeOfString:YZHLEFT_BRACKET];
        NSRange rangeOfRightBracket= [pinyinRecord rangeOfString:YZHRIGHT_BRACKET];
        NSString *stripedString = [pinyinRecord substringWithRange:NSMakeRange(rangeOfLeftBracket.location+rangeOfLeftBracket.length, rangeOfRightBracket.location-rangeOfLeftBracket.location-rangeOfLeftBracket.length)];
        return [stripedString componentsSeparatedByString:YZHCOMMA];
    }
    else return nil;
}

- (BOOL)yzh_isValidRecordWithNSString:(NSString *)record {
    NSString *noneStr = @"(none0)";
    if ((nil != record) && ![record isEqual:noneStr] && [record hasPrefix:YZHLEFT_BRACKET] && [record hasSuffix:YZHRIGHT_BRACKET]) {
        return YES;
    }
    else return NO;
}

- (NSString *)yzh_getHanyuPinyinRecordFromCharWithChar:(unichar)ch {
    int codePointOfChar = ch;
    NSString *codepointHexStr =[[NSString stringWithFormat:@"%x", codePointOfChar] uppercaseString];
    NSString *foundRecord =[self->_yzh_unicodeToHanyuPinyinTable objectForKey:codepointHexStr];
    return [self yzh_isValidRecordWithNSString:foundRecord] ? foundRecord : nil;
}

+ (YZHChineseToPinyinResource *)yzh_getInstance {
    static YZHChineseToPinyinResource *yzh_sharedInstance=nil;
    static dispatch_once_t yzh_onceToken;
    dispatch_once(&yzh_onceToken, ^{
        yzh_sharedInstance=[[self alloc] init];
    });
    return yzh_sharedInstance;
}

@end

