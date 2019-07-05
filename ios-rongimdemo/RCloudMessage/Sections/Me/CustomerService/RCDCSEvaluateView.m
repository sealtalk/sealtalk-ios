//
//  RCDCSEvaluateView.m
//  RCloudMessage
//
//  Created by 张改红 on 2017/9/6.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCDCSEvaluateView.h"
#import "RCDCSSolveView.h"
#import "RCDCSStarView.h"
#import "RCDCSTagView.h"
#import "RCDCSInputView.h"
#import "RCDCommonDefine.h"
#import "RCDCSEvaluateModel.h"
#define WIDTH self.frame.size.width
#define title_height 50.5
#define submit_height 55
#define MAX_backgroundView_height (self.frame.size.height-20)
@interface RCDCSEvaluateView ()<RCDCSStarViewDelegate,UIScrollViewDelegate>

@property (nonatomic,assign) RCCSResolveStatus resolveStatus;
@property (nonatomic,strong) NSDictionary *selectTags;


@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic,strong)UIView *titleView;
@property (nonatomic,strong)UIButton *submitButton;


@property (nonatomic,strong)UIScrollView *scrollView;

@property (nonatomic,strong)RCDCSSolveView *solveView;
@property (nonatomic,strong)RCDCSStarView *starView;
@property (nonatomic,strong)RCDCSTagView *tagView;
@property (nonatomic,strong)RCDCSInputView *inputView;

@property (nonatomic,strong)NSDictionary *evaStarDic;
@property (nonatomic,strong)RCDCSEvaluateModel *model;

@property (nonatomic,assign)CGRect backgroundViewFrame;
@end

@implementation RCDCSEvaluateView
- (instancetype)initWithEvaStarDic:(NSDictionary *)evaStarDic{
    self = [super init];
    if (self) {
        self.resolveStatus = RCCSResolved;
        self.evaStarDic = evaStarDic;
        self.model = self.evaStarDic[@"5"];
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.5];
        [self addSubview:self.backgroundView];
        
        [self.backgroundView addSubview:self.titleView];
        [self.backgroundView addSubview:self.scrollView];
        [self.backgroundView addSubview:self.submitButton];
        self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        self.submitButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self setSubViewsOfbackgroundViewLayout];
        
        [self.scrollView addSubview:self.solveView];
        [self.scrollView addSubview:self.starView];
        [self.scrollView addSubview:self.tagView];
        [self.scrollView addSubview:self.inputView];
        self.solveView.translatesAutoresizingMaskIntoConstraints = NO;
        self.starView.translatesAutoresizingMaskIntoConstraints = NO;
        self.tagView.translatesAutoresizingMaskIntoConstraints = NO;
        self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setAutolayout];
        
        [self.solveView setSubview];
        [self.starView setSubviews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
        
        //注册通知,监听键盘弹出事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
        
        //注册通知,监听键盘消失事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)didClickSubmitButton{
    if (self.model.isTagMust && self.model.tags.count > 0) {
        if (self.selectTags.count == 0) {
            [self showAlertWarning:RCDLocalizedString(@"choose_tag")];
            return;
        }
    }
    if (self.model.isInputMust && self.inputView.suggestText.text.length == 0) {
        [self showAlertWarning:RCDLocalizedString(@"type_idea")];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSubmitEvaluate:star:tagString:suggest:)]) {
        [self.delegate didSubmitEvaluate:self.resolveStatus star:self.model.score tagString:[self getTagString] suggest:self.inputView.suggestText.text];
    }
    [self hide];
}

- (NSString *)getTagString{
    NSString *tagString = @"";
    for (NSString *key in self.selectTags) {
        if (tagString.length > 0) {
            tagString = [tagString stringByAppendingString:@","];
        }
        tagString = [tagString stringByAppendingString:[NSString stringWithFormat:@"%@",self.selectTags[key]]];
    }
    return tagString;
}

- (void)cancelEvaAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissEvaluateView)]) {
        [self.delegate dismissEvaluateView];
    }
}

#pragma mark -- RCDCSStarViewDelegate

- (void)didSelectStar:(int)star{
    if (star == self.model.score) {
        return;
    }
    
    //默认5颗星，没有输入框，这个时候不需要释放输入框的第一响应
    //避免在inputView还没有frame时调用输入框放弃响应导致输入框创建，这个时候创建的输入框的父视图还没有，导致输入框frame不合要求
    if (self.model.score != 5) {
        [self resignInputViewFirstResponder];
    }
    
    if (star > 0 && star <= 5) {
        NSString *starKey = [NSString stringWithFormat:@"%d",star];
        self.model = self.evaStarDic[starKey];
    }
    
    [self resetViewsFrame:star];
    
    [self setAutolayout];
    
    [self.tagView isMustSelect:self.model.isTagMust];
    
    self.inputView.placeHolderString = self.model.inputPlaceHolder;
    
    if (self.model.tags.count > 0) {
        [self.tagView setTags:self.model.tags];
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self resignInputViewFirstResponder];
}

#pragma mark -- layout

- (void)resetViewsFrame:(int)star{
    CGRect backgroundViewRect = self.backgroundView.frame;
    backgroundViewRect.origin.y = self.frame.size.height-[self getBackgroundViewHeight];
    backgroundViewRect.size.height = [self getBackgroundViewHeight];
    self.backgroundView.frame = backgroundViewRect;
    
    [self setSubViewsOfbackgroundViewLayout];
    [self.backgroundView updateConstraints];
    [self.backgroundView layoutIfNeeded];
}

- (CGFloat)getBackgroundViewHeight{
    CGFloat height = 220;
    if (self.model.isQuestionFlag) {
        //solveView height + space
        height += 62 + 28;
    }
    
    if (self.model.tags.count > 0) {
        //tagView height + space
        height += [self getTagViewHeight] +13;
    }
    
    if (self.model.score != 5 && self.model.score != 0){
        //inputView height + space
        height += 80 + 15;
    }
    
    if ([self isMoreWithWindows:height]) {
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width, height-title_height-submit_height);
        height = MAX_backgroundView_height;
    }
    return height;
}

//判断最大高度是否超过时间状态栏
- (BOOL)isMoreWithWindows:(CGFloat)height{
    if (height > MAX_backgroundView_height) {
        return YES;
    }
    return NO;
}

- (CGFloat)getTagViewHeight{
    if (self.model.tags.count == 0) {
        self.tagView.hidden = YES;
        return 0;
    }
    self.tagView.hidden = NO;
    //title_height + titleAndButton_space
    CGFloat height = 20+13;
    height += ((self.model.tags.count-1)/2)*(button_height+vertical_space)+button_height;
    return height;
}


- (void)setAutolayout{
    [self.scrollView removeConstraints:self.scrollView.constraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_solveView,_starView,_tagView,_inputView);
    if (self.model.isQuestionFlag) {
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-28-[_solveView(62)]" options:0 metrics:nil views:views]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.solveView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.solveView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_solveView]-29-[_starView(65)]" options:0 metrics:nil views:views]];
    }else{
        [self.solveView removeFromSuperview];
        [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-29-[_starView(65)]" options:0 metrics:nil views:views]];
    }
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_starView(width)]" options:0 metrics:@{@"width":@(WIDTH-(WIDTH-25.5*5-12*4))} views:views]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.starView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_starView(65)]-13-[_tagView(TAGHEIGHT)]" options:0 metrics:@{@"TAGHEIGHT":@([self getTagViewHeight])} views:views]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.tagView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    if (self.model.score != 5 && self.model.score != 0) {
        self.inputView.hidden = NO;
        if (self.model.tags.count == 0) {
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_starView(65)]-15-[_inputView(80)]" options:0 metrics:@{@"TAGHEIGHT":@([self getTagViewHeight])} views:views]];
        }else{
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tagView(TAGHEIGHT)]-15-[_inputView(80)]" options:0 metrics:@{@"TAGHEIGHT":@([self getTagViewHeight])} views:views]];
        }
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }else{
        self.inputView.hidden = YES;
    }
    [self.scrollView updateConstraints];
    [self.scrollView layoutIfNeeded];
}

- (void)setSubViewsOfbackgroundViewLayout{
    [self.backgroundView removeConstraints:self.backgroundView.constraints];
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleView,_scrollView,_submitButton);
    [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_titleView(TITLEHEIGHT)]-0-[_scrollView]-0-[_submitButton(SUBMITHEIGHT)]-0-|" options:0 metrics:@{@"TITLEHEIGHT":@(title_height),@"SUBMITHEIGHT":@(submit_height)} views:views]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.submitButton attribute:NSLayoutAttributeCenterX relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.submitButton attribute:NSLayoutAttributeWidth relatedBy:(NSLayoutRelationEqual) toItem:self.backgroundView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
}

#pragma mark -- view show or hiden
- (void)keyboardDidShow:(NSNotification *)notification{
    [self.inputView.suggestText becomeFirstResponder];
    //获取键盘高度
    NSValue *keyboardObject = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardObject CGRectValue];
    CGRect inputViewRect = [self.scrollView convertRect:self.inputView.frame toView:self];
    if (CGRectGetMaxY(inputViewRect) > keyboardRect.origin.y) {
        CGFloat height = CGRectGetMaxY(inputViewRect)- keyboardRect.origin.y;
        CGRect backgroundViewRect = self.backgroundView.frame;
        if (backgroundViewRect.origin.y - height < 20) {
            backgroundViewRect.origin.y = 20;
        }else{
            backgroundViewRect.origin.y -= height;
        }
        CGFloat movedY = CGRectGetMinY(self.backgroundView.frame) -
        backgroundViewRect.origin.y;
        CGPoint currentPoint = self.scrollView.contentOffset;
        CGFloat pointY = keyboardRect.origin.y - (CGRectGetMaxY(inputViewRect)-movedY);
        if (pointY < 10) {
            self.scrollView.contentOffset = CGPointMake(0, -pointY+10+(currentPoint.y));
        }
        if (movedY == 0) {
            return;
        }
        [UIView animateWithDuration:0.0 animations:^{
            self.backgroundView.transform = CGAffineTransformIdentity;
        }];
        [UIView animateKeyframesWithDuration:0.0f
                                       delay:0.0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:^{
                                      self.backgroundView.transform = CGAffineTransformMakeTranslation(0,-(CGRectGetMinY(self.backgroundView.frame)- CGRectGetMinY(backgroundViewRect)));
                                  }
                                  completion:^(BOOL finished) {
                                      
                                  }];
        
        self.backgroundView.frame = backgroundViewRect;
        
    }
}

- (void)keyboardDidHidden{
    self.scrollView.contentOffset = CGPointMake(0, 0);
    if (CGRectGetMaxY(self.backgroundView.frame) < self.frame.size.height){
        [UIView animateWithDuration:0.0 animations:^{
            self.backgroundView.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)show{
    if([NSThread isMainThread]){
        [self showAtWindow:YES];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAtWindow:YES];
        });
    }
}

- (void)hide {
    if([NSThread isMainThread]){
        [self showAtWindow:NO];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAtWindow:NO];
        });
    }
}

- (void)showAtWindow:(BOOL)isShow {
    if(isShow){
        [[UIApplication sharedApplication].delegate.window addSubview:self];
    }else {
        [self removeFromSuperview];
    }
}

- (void)showAlertWarning:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:RCDLocalizedString(@"i_know_it")
, nil];
    [alertView show];
}

- (void)resignInputViewFirstResponder{
    if ([self.inputView.suggestText isFirstResponder]) {
        [self.inputView.suggestText resignFirstResponder];
    }
}

- (void)didTap{
    [self resignInputViewFirstResponder];
}

#pragma mark -- lazy init --
- (UIView *)backgroundView{
    if (!_backgroundView) {
        CGFloat height = [self getBackgroundViewHeight];
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-height, self.frame.size.width, height)];
        self.backgroundViewFrame = self.backgroundView.frame;
        _backgroundView.backgroundColor = HEXCOLOR(0xffffff);
    }
    return _backgroundView;
}

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, title_height)];
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        cancelButton.imageEdgeInsets = UIEdgeInsetsMake(18, 15, 18, 21);
        [cancelButton setImage:[UIImage imageNamed:@"eva_cancel"] forState:(UIControlStateNormal)];
        [cancelButton addTarget:self action:@selector(cancelEvaAction) forControlEvents:(UIControlEventTouchUpInside)];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        titleLabel.textColor = HEXCOLOR(0x333333);
        titleLabel.text = RCDLocalizedString(@"remark");
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 0.5)];
        line.backgroundColor = HEXCOLOR(0xeceef3);
        
        [_titleView addSubview:cancelButton];
        [_titleView addSubview:titleLabel];
        [_titleView addSubview:line];
    }
    return _titleView;
}

- (UIButton *)submitButton{
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] init];
        _submitButton.backgroundColor =  HEXCOLOR(0x0099ff);
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_submitButton setTitle:RCDLocalizedString(@"submit_remark") forState:(UIControlStateNormal)];
        [_submitButton addTarget:self action:@selector(didClickSubmitButton) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _submitButton;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (RCDCSSolveView *)solveView{
    if (!_solveView) {
        _solveView = [[RCDCSSolveView alloc] init];
        __weak typeof(self) weakSelf = self;
        [_solveView setIsSolveBlock:^(RCCSResolveStatus solveStatus){
            weakSelf.resolveStatus = solveStatus;
        }];
    }
    return _solveView;
}

- (RCDCSStarView *)starView{
    if (!_starView) {
        _starView = [[RCDCSStarView alloc] init];
        _starView.starDelegate = self;
    }
    return _starView;
}

- (RCDCSTagView *)tagView{
    if (!_tagView) {
        _tagView = [[RCDCSTagView alloc] init];
        __weak typeof(self) weakSelf = self;
        [_tagView setIsSelectedTags:^(NSDictionary *selectTags){
            weakSelf.selectTags = selectTags;
        }];
    }
    return _tagView;
}

- (RCDCSInputView *)inputView{
    if (!_inputView) {
        _inputView = [[RCDCSInputView alloc] init];
    }
    return _inputView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
@end
