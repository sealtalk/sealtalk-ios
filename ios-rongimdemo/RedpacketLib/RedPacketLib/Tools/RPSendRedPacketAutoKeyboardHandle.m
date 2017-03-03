//
//  RPSendRedPacketAutoKeyboardHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/11.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketAutoKeyboardHandle.h"
#import <UIKit/UIKit.h>
@interface RPSendRedPacketAutoKeyboardHandle()
@property (nonatomic,weak)UIView * textFieldView;
@property (nonatomic,weak)UIScrollView * lastScrollView;
@property (nonatomic,assign)CGSize kbSize;
@property (nonatomic,assign)UIEdgeInsets contentInset;
@property (nonatomic,assign)CGFloat animationDuration;

@end
@implementation RPSendRedPacketAutoKeyboardHandle{
    BOOL _isKeyboardShowing;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        
        _isKeyboardShowing = NO;
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary*info=[notification userInfo];
    self.kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    self.animationDuration = 0.25;
    [self adjustFrame];
    
}
-(void)keyboardWillHidden:(NSNotification*)notification{
    self.kbSize = CGSizeZero;
    _isKeyboardShowing = NO;
    if (self.lastScrollView) {
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self.lastScrollView setContentInset:self.contentInset];
        } completion:nil];
    }
    
}
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification{
    _textFieldView = notification.object;
    [self adjustFrame];
}
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    _isKeyboardShowing = NO;
    _textFieldView = nil;
}
-(void)adjustFrame
{
    if (_textFieldView == nil || CGSizeEqualToSize(self.kbSize, CGSizeZero) || _textFieldView.hidden)   return;
    
    if (_isKeyboardShowing) return;
    
    UIWindow *keyWindow = [self keyWindow];
    UIViewController *rootController = [self viewTopMostController];
    if (rootController == nil)  rootController = [self windowTopMostController:keyWindow];
    CGRect textFieldViewRect = [[_textFieldView superview] convertRect:_textFieldView.frame toView:keyWindow];
    
    
    CGSize kbSize = _kbSize;
    
    CGFloat move = MAX(CGRectGetMaxY(textFieldViewRect)- (CGRectGetHeight(keyWindow.frame)- kbSize.height) + 20 + self.topMargin, 0);
    
    UIScrollView *superScrollView = nil;
    UIScrollView *superView = (UIScrollView*)[self superviewOfClassType:[UIScrollView class] view:self.textFieldView];
    
    while (superView)
    {
        if (superView.isScrollEnabled){
            superScrollView = superView;
            break;
        }else{
            superView = (UIScrollView*)[self superviewOfClassType:[UIScrollView class] view:superView];
        }
    }
    
    if (superScrollView && move != 0) {
        _isKeyboardShowing = YES;
        self.lastScrollView = superScrollView;
        self.contentInset = superScrollView.contentInset;
        [UIView animateWithDuration:self.animationDuration animations:^{
            [superScrollView setContentInset:UIEdgeInsetsMake(superScrollView.contentInset.top - move , superScrollView.contentInset.left, superScrollView.contentInset.bottom, superScrollView.contentInset.right)];
        } completion:nil];
    }
}
-(UIView*)superviewOfClassType:(Class)classType view:(UIView*)view
{
    UIView *superview = view.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:classType] &&
            ([superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")] == NO) &&
            ([superview isKindOfClass:NSClassFromString(@"UITableViewWrapperView")] == NO))
        {
            return superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

-(UIWindow *)keyWindow
{
    if (_textFieldView.window)
    {
        return _textFieldView.window;
    }
    else
    {
        static UIWindow *_keyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
        
        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow != nil &&
            _keyWindow != originalKeyWindow)
        {
            _keyWindow = originalKeyWindow;
        }
        
        return _keyWindow;
    }
}

- (UIViewController*)windowTopMostController:(UIWindow*)window
{
    UIViewController *topController = [window rootViewController];
    
    //  Getting topMost ViewController
    while ([topController presentedViewController])	topController = [topController presentedViewController];
    
    //  Returning topMost ViewController
    return topController;
}

-(UIViewController *)viewTopMostController
{
    NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];
    
    UIViewController *topController = self.textFieldView.window.rootViewController;
    
    if (topController)
    {
        [controllersHierarchy addObject:topController];
    }
    
    while ([topController presentedViewController]) {
        
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }
    
    UIResponder *matchController = [self viewController];
    
    while (matchController != nil && [controllersHierarchy containsObject:matchController] == NO)
    {
        do
        {
            matchController = [matchController nextResponder];
            
        } while (matchController != nil && [matchController isKindOfClass:[UIViewController class]] == NO);
    }
    
    return (UIViewController*)matchController;
}
-(UIViewController*)viewController
{
    UIResponder *nextResponder = self.textFieldView;
    
    do
    {
        nextResponder = [nextResponder nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
        
    } while (nextResponder != nil);
    
    return nil;
}

@end
