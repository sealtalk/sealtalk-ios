//
//  RCDReceiptDetailsHeaderView.m
//  RCloudMessage
//
//  Created by Jue on 16/9/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsHeaderView.h"
#import "RCDCommonDefine.h"
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
#import <Masonry/Masonry.h>
#import <RongIMKit/RongIMKit.h>
@interface RCDReceiptDetailsHeaderView ()

@property (nonatomic, strong) NSDictionary *CellSubviews;

@property (nonatomic, strong) UIButton *hasReadButton;

@property (nonatomic, strong) UIButton *unReadButton;

@property (nonatomic, strong) UIView *leftSelectLine;

@property (nonatomic, strong) UIView *rightSelectLine;

@property (nonatomic, assign) BOOL displayHasreadUsers;

@property (nonatomic, assign) NSInteger hasReadUsersCount;

@property (nonatomic, assign) NSInteger unreadUsersCount;
@end

@implementation RCDReceiptDetailsHeaderView
- (instancetype)initWithFrame:(CGRect)frame hasReadCount:(NSInteger)hasReadCount unreadCount:(NSInteger)unreadCount{
    self = [super initWithFrame:frame];
    if (self) {
        self.hasReadUsersCount = hasReadCount;
        self.unreadUsersCount = unreadCount;
        self.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        [self initialize];
        [self setDisplayHasreadUsers:NO];
    }
    return self;
}

- (void)initialize {
    self.hasReadButton = [self createButton:nil];
    [self.hasReadButton addTarget:self
                           action:@selector(clickHasReadButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.hasReadButton];
    self.hasReadButton.selected = YES;

    self.leftSelectLine = [self createLine:[UIColor colorWithHexString:@"0099ff" alpha:1.f]];
    [self.hasReadButton addSubview:self.leftSelectLine];

    self.unReadButton = [self createButton:nil];
    [self.unReadButton addTarget:self
                          action:@selector(clickUnreadButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.unReadButton];

    self.rightSelectLine = [self createLine:[UIColor colorWithHexString:@"0099ff" alpha:1.f]];
    [self.unReadButton addSubview:self.rightSelectLine];
    self.rightSelectLine.hidden = YES;

    [self setAutoLayout];
}

- (UIView *)createLine:(UIColor *)lineColor {
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = lineColor;
    line.layer.masksToBounds = YES;
    line.layer.cornerRadius = 1;
    line.translatesAutoresizingMaskIntoConstraints = NO;
    return line;
}

- (UIButton *)createButton:(NSString *)buttonTitle {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    UIColor *normalColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0xa0a5ab) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.6]];
    UIColor *selectedColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0x111f2c) darkColor:[HEXCOLOR(0xffffff) colorWithAlphaComponent:0.9]];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:[RCKitConfig defaultConfig].font.thirdLevel];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (void)setAutoLayout {
    [self.unReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    
    [self.hasReadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    
    [self.leftSelectLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self.unReadButton);
        make.height.offset(2);
        make.width.offset(59);
    }];
    
    [self.rightSelectLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self.hasReadButton);
        make.height.offset(2);
        make.width.offset(59);
    }];
}

- (void)clickHasReadButton:(UIButton *)button {
    if (button.selected == YES) {
        return;
    }
    button.selected = !button.selected;
    [self setDisplayHasreadUsers:YES];
    [self.delegate clickHasReadButton];
}

- (void)clickUnreadButton:(UIButton *)button {
    if (button.selected == YES) {
        return;
    }
    button.selected = !button.selected;
    [self setDisplayHasreadUsers:NO];
    [self.delegate clickUnreadButton];
}

- (void)setDisplayHasreadUsers:(BOOL)displayHasreadUsers {
    if (displayHasreadUsers == YES) {
        self.rightSelectLine.hidden = NO;
        self.leftSelectLine.hidden = YES;
        self.unReadButton.selected = NO;
        self.hasReadButton.selected = YES;
        [self.hasReadButton setTitle:[NSString stringWithFormat:@"%@ (%ld)",RCLocalizedString(@"read"), (unsigned long)self.hasReadUsersCount] forState:UIControlStateNormal];
        [self.unReadButton setTitle:RCLocalizedString(@"unread") forState:UIControlStateNormal];
    } else {
        self.rightSelectLine.hidden = YES;
        self.leftSelectLine.hidden = NO;
        self.hasReadButton.selected = NO;
        self.unReadButton.selected = YES;
        [self.hasReadButton setTitle:RCLocalizedString(@"read") forState:UIControlStateNormal];
        [self.unReadButton setTitle:[NSString stringWithFormat:@"%@ (%ld)",RCLocalizedString(@"unread"), (unsigned long)self.unreadUsersCount] forState:UIControlStateNormal];
    }
}
@end
