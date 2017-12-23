//
//  RCDCSEvaluateModel.h
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/8.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDCSEvaluateModel : UIButton
@property (nonatomic, assign) BOOL isTagMust;
@property (nonatomic, assign) BOOL isQuestionFlag;
@property (nonatomic, assign) BOOL isInputMust;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, assign) int score;
@property (nonatomic, copy) NSString *inputPlaceHolder;

- (instancetype)initWithDictionary:(NSDictionary *)json;
+ (RCDCSEvaluateModel *)modelWithDictionary:(NSDictionary *)json;
@end
