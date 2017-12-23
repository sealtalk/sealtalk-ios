//
//  RCDCSEvaluateModel.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/8.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSEvaluateModel.h"

@implementation RCDCSEvaluateModel
- (instancetype)initWithDictionary:(NSDictionary *)json{
  self = [super init];
  if (self) {
    if (![[json valueForKey:@"isTagMust"] isEqual:[NSNull null]]) {
      self.isTagMust = [[json valueForKey:@"isTagMust"] boolValue];
    }
    if (![[json valueForKey:@"isQuestionFlag"] isEqual:[NSNull null]]) {
      self.isQuestionFlag = [[json valueForKey:@"isQuestionFlag"] boolValue];
    }
    if (![[json valueForKey:@"isInputMust"] isEqual:[NSNull null]]) {
      self.isInputMust = [[json valueForKey:@"isInputMust"] boolValue];
    }
    if (![[json valueForKey:@"inputLanguage"] isEqual:[NSNull null]]) {
      self.inputPlaceHolder = [json valueForKey:@"inputLanguage"];
    }
    self.score = [[json valueForKey:@"score"] intValue];
    
    if (![[json valueForKey:@"labelName"] isEqual:[NSNull null]]) {
      NSString *tagStr = [json valueForKey:@"labelName"];
      if (tagStr.length > 0) {
        self.tags = [tagStr componentsSeparatedByString:@","];
      }
    }
  }
  return self;
}

+ (RCDCSEvaluateModel *)modelWithDictionary:(NSDictionary *)json{
  return [[RCDCSEvaluateModel alloc] initWithDictionary:json];
}


@end
