//
//  RCDCheckVersion.m
//  RCloudMessage
//
//  Created by Jue on 16/7/7.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCheckVersion.h"

@interface RCDCheckVersion ()
@property (nonatomic, copy) void (^successBlock)(NSDictionary *result);

@end

@implementation RCDCheckVersion
{
  NSMutableData *backData;
  NSURLConnection *connection;
  NSString *sdkVersion;
  NSString *sealtalkBuild;
  NSString *applistURL;
}

+ (RCDCheckVersion *)shareInstance {
  static RCDCheckVersion *instance = nil;
  static dispatch_once_t predicate;
  dispatch_once(&predicate, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}


-(void) checkVersion
{
  NSDictionary *result = [[NSDictionary alloc] init];
  NSString *currentBuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
  NSDate *currentBuildDate = [self stringToDate:currentBuild];
  NSDate *buildDtate = [self stringToDate:sealtalkBuild];
  NSTimeInterval secondsInterval= [currentBuildDate timeIntervalSinceDate:buildDtate];
  if (secondsInterval < 0) {
    result = [NSDictionary dictionaryWithObjectsAndKeys:@"YES",@"isNeedUpdate",applistURL,@"applist", nil];
  }
  else
  {
    result = [NSDictionary dictionaryWithObjectsAndKeys:@"NO",@"isNeedUpdate", nil];
  }
  if (self.successBlock) {
    self.successBlock(result);
    self.successBlock = nil;
  }
}

-(void)startCheckSuccess:(void (^)(NSDictionary *result))success
{
  //获取系统当前的时间戳
  NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
  NSTimeInterval now = [dat timeIntervalSince1970] * 1000;
  NSString *timeString = [NSString stringWithFormat:@"%f", now];
  //为html增加随机数，避免缓存。
  NSString * URLString = [NSString stringWithFormat:@"http://downloads.rongcloud.cn/SealTalk_iOS_Update.html?%@",timeString];
  NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL];
  self.successBlock = success;
  connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
  NSLog(@"response = %@",response);
  backData = [[NSMutableData alloc]init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
  [backData appendData:data];
  id json = [NSJSONSerialization JSONObjectWithData:backData options:0 error:nil];
  if (json) {
    sdkVersion = [json objectForKey:@"sdkVersion"];
    sealtalkBuild = [json objectForKey:@"sealtalkBuild"];
    applistURL = [json objectForKey:@"applistURL"];
    [self checkVersion];
  }
}

-(NSDate *)stringToDate:(NSString *)build
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
  NSDate *date = [dateFormatter dateFromString:build];
  return date;
}

@end
