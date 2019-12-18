//
//  RCDReceiptDetailsTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsTableViewCell.h"
#import "RCDCommonDefine.h"
#import "UIColor+RCColor.h"
#import "RCDUtilities.h"
@interface RCDReceiptDetailsTableViewCell ()

@property (nonatomic, strong) NSDictionary *CellSubviews;

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIButton *hasReadButton;

@property (nonatomic, strong) UIButton *unReadButton;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *leftSelectLine;

@property (nonatomic, strong) UIView *rightSelectLine;
@end

@implementation RCDReceiptDetailsTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDReceiptDetailsTableViewCell *cell = (RCDReceiptDetailsTableViewCell *)[tableView
        dequeueReusableCellWithIdentifier:RCDReceiptDetailsTableViewCellIdentifier];
    if (!cell) {
        cell = [[RCDReceiptDetailsTableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.verticalLine = [self createLine:RCDDYCOLOR(0xdfdfdf, 0x3a3a3a)];
    [self.contentView addSubview:self.verticalLine];

    self.hasReadButton = [self
        createButton:[NSString stringWithFormat:RCDLocalizedString(@"x_people_had_read"), self.hasReadUsersCount]];
    [self.hasReadButton addTarget:self
                           action:@selector(clickHasReadButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.hasReadButton];
    self.hasReadButton.selected = YES;

    self.leftSelectLine = [self createLine:[UIColor colorWithHexString:@"0099ff" alpha:1.f]];
    [self.hasReadButton addSubview:self.leftSelectLine];

    self.unReadButton = [self createButton:RCDLocalizedString(@"zero_people_unread")];
    [self.unReadButton addTarget:self
                          action:@selector(clickUnreadButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.unReadButton];

    self.rightSelectLine = [self createLine:[UIColor colorWithHexString:@"0099ff" alpha:1.f]];
    [self.unReadButton addSubview:self.rightSelectLine];
    self.rightSelectLine.hidden = YES;

    self.line = [self createLine:[UIColor colorWithHexString:@"dfdfdf" alpha:1.f]];
    [self.contentView addSubview:self.line];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.CellSubviews = NSDictionaryOfVariableBindings(_verticalLine, _hasReadButton, _unReadButton, _line);
    [self setAutoLayout];
}

- (UIView *)createLine:(UIColor *)lineColor {
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = lineColor;
    line.translatesAutoresizingMaskIntoConstraints = NO;
    return line;
}

- (UIButton *)createButton:(NSString *)buttonTitle {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    UIColor *normalColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
    UIColor *selectedColor = [UIColor colorWithHexString:@"0099ff" alpha:1.f];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:selectedColor forState:UIControlStateHighlighted];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (void)setAutoLayout {
    [self.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hasReadButton(width)][_verticalLine(1)]"
                                                               options:0
                                                               metrics:@{
                                                                   @"width" : @(RCDScreenWidth / 2 - 1)
                                                               }
                                                                 views:self.CellSubviews]];
    [self.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hasReadButton(44)][_line(0.5)]"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.CellSubviews]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_verticalLine
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.hasReadButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_verticalLine(24)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.CellSubviews]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_unReadButton(width)]|"
                                                                             options:0
                                                                             metrics:@{
                                                                                 @"width" : @(RCDScreenWidth / 2 - 1)
                                                                             }
                                                                               views:self.CellSubviews]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_unReadButton(44)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.CellSubviews]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_line]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.CellSubviews]];

    [self.hasReadButton
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftSelectLine]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(
                                                                           _leftSelectLine, _rightSelectLine)]];
    [self.hasReadButton
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftSelectLine(2)]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(
                                                                           _leftSelectLine, _rightSelectLine)]];
    [self.unReadButton
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rightSelectLine]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(
                                                                           _leftSelectLine, _rightSelectLine)]];
    [self.unReadButton
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightSelectLine(2)]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:NSDictionaryOfVariableBindings(
                                                                           _leftSelectLine, _rightSelectLine)]];
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
        self.leftSelectLine.hidden = NO;
        self.rightSelectLine.hidden = YES;
        self.unReadButton.selected = NO;
        self.hasReadButton.selected = YES;
    } else {
        self.leftSelectLine.hidden = YES;
        self.rightSelectLine.hidden = NO;
        self.hasReadButton.selected = NO;
        self.unReadButton.selected = YES;
    }
}

- (void)setHasReadUsersCount:(NSInteger)hasReadUsersCount {
    [self.hasReadButton
        setTitle:[NSString stringWithFormat:RCDLocalizedString(@"x_people_had_read"), (unsigned long)hasReadUsersCount]
        forState:UIControlStateNormal];
}

- (void)setUnreadUsersCount:(NSInteger)unreadUsersCount {
    [self.unReadButton
        setTitle:[NSString stringWithFormat:RCDLocalizedString(@"x_people_unread"), (unsigned long)unreadUsersCount]
        forState:UIControlStateNormal];
}
@end
