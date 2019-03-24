//
//  RCDCSTagView.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSTagView.h"
#import "RCDCommonDefine.h"
#import "RCDCSButton.h"

@interface RCDCSTagView ()
@property (nonatomic, strong) UILabel *tagTitle;
@property (nonatomic, strong)NSMutableDictionary *selectedTags;
@end
@implementation RCDCSTagView
- (instancetype)init{
  self = [super init];
  if (self) {
    self.selectedTags = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)settagTitle{
  self.tagTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
  self.tagTitle.textColor = HEXCOLOR(0x3c4d65);
  self.tagTitle.text = RCDLocalizedString(@"cs_evaluate_problem_title");
  self.tagTitle.font = [UIFont systemFontOfSize:16];
  self.tagTitle.textAlignment = NSTextAlignmentCenter;
  [self addSubview:self.tagTitle];
}

- (void)setTags:(NSArray *)tags{
  if (!self.tagTitle) {
    [self settagTitle];
  }
  for (UIView *view in self.subviews) {
    if ([view isKindOfClass:[UIButton class]]) {
      [view removeFromSuperview];
    }
  }
  for (int i = 0; i < tags.count; i++) {
    CGFloat posX = (self.frame.size.width - horizental_space - button_width*2)/2;
    CGFloat posY = CGRectGetMaxY(self.tagTitle.frame)+13;
    if (i%2 != 0 ) {
      posX += (i%2)*button_width+horizental_space;
    }
      posY += (i/2)*(button_height+vertical_space);
    RCDCSButton *button =
    [[RCDCSButton alloc] initWithFrame:CGRectMake(posX, posY, button_width,button_height)];
    [button setTitle:tags[i] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didSelectTag:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = i;
    [self addSubview:button];
  }
  _tags = tags;
}

- (void)didSelectTag:(UIButton *)sender{
  sender.selected = !sender.selected;
  NSString *key = [NSString stringWithFormat:@"%ld",(long)sender.tag];
  if (sender.selected) {
    [self.selectedTags setObject:self.tags[sender.tag] forKey:key];
  }else{
    [self.selectedTags removeObjectForKey:key];
  }
  self.isSelectedTags(self.selectedTags);
}

- (void)isMustSelect:(BOOL)isMustSelect{
  dispatch_async(dispatch_get_main_queue(), ^{
    if (isMustSelect) {
      self.tagTitle.text = RCDLocalizedString(@"cs_evaluate_problem_must_title");
    }else{
      self.tagTitle.text = RCDLocalizedString(@"cs_evaluate_problem_title");
    }
  });
}
@end
