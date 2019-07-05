//
//  RCDCSSolveView.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSSolveView.h"
#import "RCDCommonDefine.h"
#import "RCDCSButton.h"
#define button_size CGSizeMake(130 , 30)
#define button_space 21
#define titleAndButton_space 11
@interface RCDCSSolveView ()

@property (nonatomic, strong) UILabel *solveTitle;

@property (nonatomic, strong) RCDCSButton *solvedButton;
@property (nonatomic, strong) RCDCSButton *noSolveButton;

@end
@implementation RCDCSSolveView
- (instancetype)init{
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)setSubview{
  self.solveTitle.text = RCDLocalizedString(@"cs_evaluate_resolved_title");
  [self.solvedButton setTitle:RCDLocalizedString(@"cs_evaluate_resolved") forState:(UIControlStateNormal)];
  [self.noSolveButton setTitle:RCDLocalizedString(@"cs_evaluate_unresolved") forState:(UIControlStateNormal)];
}

- (void)didClickSolveButton:(UIButton *)sender{
  if (!sender.selected && self.noSolveButton.selected) {
    sender.selected = !sender.selected;
    self.noSolveButton.selected = !self.noSolveButton.selected;
    self.isSolveBlock(RCCSResolved);
  }
}

- (void)didClickNoSolveButton:(UIButton *)sender{
  if (!sender.selected && self.solvedButton.selected) {
    sender.selected = !sender.selected;
    self.solvedButton.selected = !self.solvedButton.selected;
    self.isSolveBlock(RCCSUnresolved);
  }
}

- (UILabel *)solveTitle{
  if (!_solveTitle) {
    self.solveTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    self.solveTitle.textColor = HEXCOLOR(0x3c4d65);
    self.solveTitle.font = [UIFont systemFontOfSize:16];
    self.solveTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.solveTitle];
  }
  return _solveTitle;
}

- (RCDCSButton *)solvedButton{
  if (!_solvedButton) {
    CGFloat X = (self.frame.size.width - button_space - button_size.width*2)/2;
    _solvedButton = [[RCDCSButton alloc] initWithFrame:CGRectMake(X, CGRectGetMaxY(self.solveTitle.frame)+11, button_size.width, button_size.height)];
    [_solvedButton addTarget:self action:@selector(didClickSolveButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_solvedButton];
    _solvedButton.selected = YES;
  }
  return _solvedButton;
}

- (RCDCSButton *)noSolveButton{
  if (!_noSolveButton) {
    _noSolveButton = [[RCDCSButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.solvedButton.frame)+button_space, CGRectGetMaxY(self.solveTitle.frame)+11, button_size.width, button_size.height)];
    [_noSolveButton addTarget:self action:@selector(didClickNoSolveButton:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_noSolveButton];
  }
  return _noSolveButton;
}
@end
