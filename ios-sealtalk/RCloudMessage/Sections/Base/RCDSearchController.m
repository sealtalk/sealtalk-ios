//
//  RCDSearchController.m
//  SealTalk
//
//  Created by 张改红 on 2020/7/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDSearchController.h"
#import "RCDCommonDefine.h"
#import "RCDUtilities.h"
@interface RCDSearchController ()<UITextFieldDelegate>
// placeholder 和icon 和 间隙的整体宽度
@property (nonatomic, assign) CGFloat placeholderWidth;
@property (nonatomic, strong) UITextField *textField;
@end

// icon宽度
static CGFloat const searchIconW = 20.0;
// icon与placeholder间距
static CGFloat const iconSpacing = 10.0;
// 占位文字的字体大小
static CGFloat const placeHolderFont = 15.0;

@implementation RCDSearchController
- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController{
    if (self = [super initWithSearchResultsController:searchResultsController]) {
        //提醒字眼
        self.searchBar.placeholder = RCDLocalizedString(@"search");
        self.searchBar.keyboardType = UIKeyboardTypeDefault;
        if (@available(iOS 13.0, *)) {
            self.textField = self.searchBar.searchTextField;
        }else{
            self.textField = [self.searchBar valueForKey:@"searchField"];
        }
        self.textField.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xf9f9f9)
                                                             darkColor:HEXCOLOR(0x202020)];
        self.textField.delegate = self;
        
        self.searchBar.barTintColor = RCDDYCOLOR(0xffffff, 0x191919);
        self.searchBar.layer.borderColor = RCDDYCOLOR(0xffffff, 0x191919).CGColor;
        self.searchBar.layer.borderWidth = 1;
        [self makeTextFieldCenter:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if ([self isActive]) {
        self.searchBar.superview.backgroundColor = RCDDYCOLOR(0xffffff, 0x191919);
        [self makeTextFieldCenter:NO];
    }else{
        [self makeTextFieldCenter:YES];
    }
}

// 1.默认居中placeholder
- (void)makeTextFieldCenter:(BOOL)isCenter {
    UIOffset offset = UIOffsetZero;
    if(isCenter && self.textField.text.length == 0) {
        // 8 为左右边距
        offset = UIOffsetMake((self.searchBar.frame.size.width - 8 * 2 - self.placeholderWidth) / 2, 0);
    }
    // iOS 11 之前就是居中的，所以只有 iOS 11 及其以后需要代码进行居中
    if (@available(iOS 11.0, *)) {
        [self.searchBar setPositionAdjustment:offset forSearchBarIcon:UISearchBarIconSearch];
    }
}

// 2.开始编辑的时候重置为靠左
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL retValue = YES;
    if ([self.searchBar.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        retValue = [self.searchBar.delegate searchBarShouldBeginEditing:self.searchBar];
    }
    [self makeTextFieldCenter:NO];
    return retValue;
}

// 计算placeholder、icon、icon和placeholder间距的总宽度
- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [self.searchBar.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:placeHolderFont]} context:nil].size;
        _placeholderWidth = size.width + iconSpacing + searchIconW;
    }
    return _placeholderWidth;
}

@end
