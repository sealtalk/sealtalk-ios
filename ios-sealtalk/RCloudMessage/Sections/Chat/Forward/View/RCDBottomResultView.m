//
//  RCDBottomResultView.m
//  SealTalk
//
//  Created by 孙浩 on 2019/6/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDBottomResultView.h"
#import "UIColor+RCColor.h"
#import <Masonry/Masonry.h>
#import "RCDForwardManager.h"
#import "RCDHaveSelectedViewController.h"
#import "RCDUtilities.h"
@interface RCDBottomResultView ()

@property (nonatomic, strong) UIButton *resultButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, assign) NSInteger selectedResult;
@property (nonatomic, strong) NSArray *selectedResults;

@property (nonatomic, strong) UIViewController *currentVC;

@end

@implementation RCDBottomResultView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.selectedResult = 0;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {

    self.backgroundColor = RCDDYCOLOR(0xFAFAFA, 0x1a1a1a);

    [self addSubview:self.confirmButton];
    [self addSubview:self.resultButton];

    [self.resultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.height.offset(RCDBottomResultViewHeight);
        make.bottom.equalTo(self).offset(-RCDExtraBottomHeight);
        make.right.mas_lessThanOrEqualTo(self.confirmButton.mas_left);
    }];

    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resultButton);
        make.right.equalTo(self).offset(-12);
        make.height.offset(RCDBottomResultViewHeight);
        make.width.offset(70);
    }];
}

- (void)updateSelectResult {

    RCDForwardManager *forwardManager = [RCDForwardManager sharedInstance];
    [self updateSelectResult:forwardManager.friendCount groupCount:forwardManager.groupCount];
}

- (void)updateSelectResult:(NSUInteger)result {
    self.selectedResult = result;
    NSString *text = [NSString stringWithFormat:RCDLocalizedString(@"ChoosedPersonCount"), (int)result];
    [self.resultButton setTitle:text forState:UIControlStateNormal];
    if (result > 0) {
        [self.resultButton setTitleColor:[UIColor colorWithHexString:@"3A91F3" alpha:1] forState:UIControlStateNormal];
        [self.confirmButton setTitleColor:[UIColor colorWithHexString:@"3A91F3" alpha:1] forState:UIControlStateNormal];
    } else {
    }
}

- (void)updateSelectResult:(NSUInteger)result groupCount:(NSUInteger)groupCount {
    self.selectedResult = result + groupCount;
    NSString *text = nil;
    self.resultButton.hidden = NO;
    if (result == 0 && groupCount > 0) {
        text = [NSString stringWithFormat:RCDLocalizedString(@"ChoosedGroupCount"), (int)groupCount];
    } else if (result > 0 && groupCount == 0) {
        text = [NSString stringWithFormat:RCDLocalizedString(@"ChoosedPersonCount"), (int)result];
    } else if (result > 0 && groupCount > 0) {
        text = [NSString stringWithFormat:RCDLocalizedString(@"ChoosedPersonGroupCount"), (int)result, (int)groupCount];
    } else {
        text = RCDLocalizedString(@"ChooseNoOne");
    }
    [self.resultButton setTitle:text forState:UIControlStateNormal];
    UIColor *resultColor = result + groupCount > 0 ? [UIColor colorWithHexString:@"3A91F3" alpha:1]
                                                   : [UIColor colorWithHexString:@"B2B2B2" alpha:1];
    [self.resultButton setTitleColor:resultColor forState:UIControlStateNormal];

    UIColor *confirmColor = result + groupCount > 0 ? [UIColor colorWithHexString:@"3A91F3" alpha:1]
                                                    : [UIColor colorWithHexString:@"B2B2B2" alpha:1];
    [self.confirmButton setTitleColor:confirmColor forState:UIControlStateNormal];
}

//确定按钮点击事件
- (void)confirmButtonEvent {
    if (self.selectedResult < 1) {
        return;
    }
    if (self.confirmButtonBlock) {
        self.confirmButtonBlock();
    } else {
        if (self.currentVC != nil) {
            [[RCDForwardManager sharedInstance] showForwardAlertViewInViewController:self.currentVC];
        }
    }
}

- (void)resultButtonEvent {
    if (self.selectedResult < 1) {
        return;
    }

    if (self.resultButtonBlock) {
        self.resultButtonBlock();
    } else {
        if (self.currentVC != nil) {
            [self pushHaveSelectedVC];
        }
    }
}

- (void)pushHaveSelectedVC {
    RCDHaveSelectedViewController *haveSelectedVC = [[RCDHaveSelectedViewController alloc] init];
    haveSelectedVC.confirmButtonBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadBottomResultView" object:nil];
    };
    [self.currentVC.navigationController pushViewController:haveSelectedVC animated:YES];
}

- (UIViewController *)currentVC {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

- (UIButton *)resultButton {
    if (!_resultButton) {
        _resultButton = [[UIButton alloc] init];
        NSString *text = RCDLocalizedString(@"ChooseNoOne");
        _resultButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _resultButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_resultButton setTitleColor:[UIColor colorWithHexString:@"3A91F3" alpha:1] forState:UIControlStateNormal];
        [_resultButton setTitle:text forState:UIControlStateNormal];
        [_resultButton addTarget:self action:@selector(resultButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resultButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [_confirmButton setTitle:RCDLocalizedString(@"ConfirmBtnTitle") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:@"3A91F3" alpha:1] forState:UIControlStateNormal];
        [_confirmButton addTarget:self
                           action:@selector(confirmButtonEvent)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
