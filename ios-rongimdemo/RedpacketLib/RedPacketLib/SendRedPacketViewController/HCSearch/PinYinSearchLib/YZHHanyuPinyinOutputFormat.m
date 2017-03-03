//
//  
//
//  Created by kimziv on 13-9-14.
//

#include "YZHHanyuPinyinOutputFormat.h"

@implementation YZHHanyuPinyinOutputFormat
@synthesize yzh_vCharType=_yzh_vCharType;
@synthesize yzh_caseType=_yzh_caseType;
@synthesize yzh_toneType=_yzh_toneType;

- (id)init {
  if (self = [super init]) {
    [self yzh_restoreDefault];
  }
  return self;
}

- (void)yzh_restoreDefault {
    _yzh_vCharType = YZHVCharTypeWithUAndColon;
    _yzh_caseType = YZHCaseTypeLowercase;
    _yzh_toneType = YZHToneTypeWithToneNumber;
}

@end
