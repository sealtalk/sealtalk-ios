//
//  RCDCSAnnounceView.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/8/31.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSAnnounceView.h"
#import "RCDCommonDefine.h"
@interface RCDCSAnnounceView ()
@property (nonatomic,strong) UIImageView *trumpetImageView;
@property (nonatomic,strong) UIImageView *arrowImageView;
@property (nonatomic,copy) NSString *layoutStr;
@end
@implementation RCDCSAnnounceView
- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = HEXCOLOR(0xfff5ed);
    [self loadSubview];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewAction)];
    [self addGestureRecognizer:tap];
  }
  return self;
}

- (void)loadSubview{
  self.content = [[UILabel alloc] init];
  self.content.textColor = HEXCOLOR(0x9D5438);
  self.content.font = [UIFont systemFontOfSize:14];
  self.trumpetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trumpet"]];
  self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
  
  [self addSubview:self.content];
  [self addSubview:self.trumpetImageView];
  [self addSubview:self.arrowImageView];
  
  self.content.translatesAutoresizingMaskIntoConstraints = NO;
  self.trumpetImageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.layoutStr = @"H:|-15-[_trumpetImageView(18.5)]-15-[_content]-7-[_arrowImageView(6.5)]-15-|";
  [self setLayout];
}

- (void)setLayout{
  NSDictionary *views = NSDictionaryOfVariableBindings(_content,_trumpetImageView,_arrowImageView);
  NSArray *array = [NSLayoutConstraint constraintsWithVisualFormat:self.layoutStr options:0 metrics:nil views:views];
  [self addConstraints:array];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_trumpetImageView(16)]" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_content(20)]" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_arrowImageView(12)]" options:0 metrics:nil views:views]];

  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.trumpetImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.content attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)setHiddenArrowIcon:(BOOL)hiddenArrowIcon{
  self.arrowImageView.hidden = hiddenArrowIcon;
  if (hiddenArrowIcon) {
    [self removeConstraints:self.constraints];
    self.layoutStr = @"H:|-15-[_trumpetImageView(18.5)]-15-[_content]-12-|";
    [self setLayout];
    [self updateConstraints];
    [self layoutIfNeeded];
  }
}

- (void)tapViewAction{
  if (self.delegate && [self.delegate respondsToSelector:@selector(didTapViewAction)]) {
    [self.delegate didTapViewAction];
  }
}
@end
