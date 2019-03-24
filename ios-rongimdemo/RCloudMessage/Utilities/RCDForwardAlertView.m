//
//  RCDForwardAlertView.m
//  RongEnterpriseApp
//
//  Created by Sin on 17/3/13.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCDForwardAlertView.h"
#import "RCDCommonDefine.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#define itemHight 40

@interface RCDForwardAlertView ()
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UILabel *nameLabel;

// data
@property(nonatomic, strong) UIImage *imageData;
@property(nonatomic, copy) NSString *titleName;
@property(nonatomic, assign) NSUInteger count;
@end

@implementation RCDForwardAlertView
+ (instancetype)alertViewWithModel:(RCConversation *)model{
    if (!model) {
        return nil;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    RCDForwardAlertView *alertV = [[self alloc] initWithFrame:keyWindow.bounds];
    [alertV setModel:model];
    return alertV;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

- (void)show {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    [self updateUI];
}

- (void)setModel:(RCConversation *)model {
    _model = model;
    CGFloat originX = 18;
    UIImageView *imageView =
    [[UIImageView alloc] initWithFrame:CGRectMake(originX, 20, itemHight, itemHight)];
    imageView.image = self.imageData;
    imageView.layer.cornerRadius = 2;
    imageView.layer.masksToBounds = YES;
    [self.scrollView addSubview:imageView];
    if (model.conversationType == ConversationType_PRIVATE) {
        RCDUserInfo *userInfo;
        if ([model.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            userInfo = (RCDUserInfo *)[RCIM sharedRCIM].currentUserInfo;
        }else{
            userInfo = [[RCDataBaseManager shareInstance] getFriendInfo:model.targetId];
        }
        self.nameLabel.text = userInfo.name;
        [imageView sd_setImageWithURL:[NSURL URLWithString: userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"contact"]];
    }else if (model.conversationType == ConversationType_GROUP){
        RCDGroupInfo *groupInfo = [[RCDataBaseManager shareInstance] getGroupByGroupId:model.targetId];
        self.nameLabel.text = groupInfo.groupName;
        [imageView sd_setImageWithURL:[NSURL URLWithString: groupInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
}

- (void)updateUI {
    self.titleLabel.text = RCDLocalizedString(@"confirm_send")
;
}

- (void)loadSubviews {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:self.contentView];
    [self.contentView addSubview:[self cancelButton]];
    [self.contentView addSubview:[self confirmButton]];
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.titleLabel];
    [self addLinesToContentView];
}

- (void)addLinesToContentView {
    CGFloat contentViewHeight = self.contentView.bounds.size.height;
    CGFloat contentViewWidth = self.contentView.bounds.size.width;
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeight - 44 - 1, contentViewWidth, 1)];
    topLine.backgroundColor = HEXCOLOR(0xd8d8d8);

    UIView *separateLine =
        [[UIView alloc] initWithFrame:CGRectMake(contentViewWidth / 2, contentViewHeight - 44, 1, 44)];
    separateLine.backgroundColor = HEXCOLOR(0xd8d8d8);

    [self.contentView addSubview:topLine];
    [self.contentView addSubview:separateLine];
}

- (UIView *)contentView {
    if (!_contentView) {
        CGFloat selfHight = self.bounds.size.height;
        CGFloat selfWidth = self.bounds.size.width;
        CGFloat contentViewX = selfWidth * 0.1;
        CGFloat contentViewWidth = selfWidth - contentViewX * 2;
        CGFloat contentViewHeight = 165;
        CGFloat contentViewY = (selfHight - contentViewHeight) / 2;
        _contentView =
            [[UIView alloc] initWithFrame:CGRectMake(contentViewX, contentViewY, contentViewWidth, contentViewHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 5;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIButton *)cancelButton {
    CGFloat contentViewHeight = self.contentView.bounds.size.height;
    CGFloat contentViewWidth = self.contentView.bounds.size.width;
    CGFloat cancelButtonX = 0;
    CGFloat cancelButtonY = contentViewHeight - 44;
    CGFloat cancelButtonWidth = contentViewWidth / 2;
    CGFloat cancelButtonHeight = 44;
    UIButton *button = [[UIButton alloc]
        initWithFrame:CGRectMake(cancelButtonX, cancelButtonY, cancelButtonWidth, cancelButtonHeight)];
    [button setTitle:RCDLocalizedString(@"cancel")
 forState:UIControlStateNormal];
    [button setTitleColor:HEXCOLOR(0x262626) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button addTarget:self action:@selector(cancelButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)confirmButton {
    CGFloat contentViewHeight = self.contentView.bounds.size.height;
    CGFloat contentViewWidth = self.contentView.bounds.size.width;
    CGFloat cancelButtonX = contentViewWidth / 2;
    ;
    CGFloat cancelButtonY = contentViewHeight - 44;
    CGFloat cancelButtonWidth = contentViewWidth / 2;
    CGFloat cancelButtonHeight = 44;
    UIButton *button = [[UIButton alloc]
        initWithFrame:CGRectMake(cancelButtonX, cancelButtonY, cancelButtonWidth, cancelButtonHeight)];
    [button setTitle:RCDLocalizedString(@"send")
 forState:UIControlStateNormal];
    [button setTitleColor:HEXCOLOR(0x4093f0) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button addTarget:self action:@selector(confirmButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        CGFloat contentViewWidth = self.contentView.bounds.size.width;
        CGFloat scrollViewX = 0;
        CGFloat scrollViewY = 40;
        CGFloat scrollViewWidth = contentViewWidth;
        CGFloat scrollViewHeight = itemHight + 40;
        _scrollView = [[UIScrollView alloc]
            initWithFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat contentViewWidth = self.contentView.bounds.size.width;
        CGFloat titleLabelX = 18;
        CGFloat titleLabelY = 20;
        CGFloat titleLabelWidth = contentViewWidth - 36;
        CGFloat titleLabelHeight = 20;
        _titleLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight)];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = HEXCOLOR(0x262626);
    }
    return _titleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        CGFloat nameLabelX = 18 + itemHight + 12;
        CGFloat nameLabelY = 20;
        CGFloat nameLabelWidth = self.contentView.bounds.size.width - nameLabelX - 18;
        CGFloat nameLabelHeight = itemHight;
        _nameLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight)];
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.scrollView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (void)confirmButtonEvent {
    [self dealDelegate:1];
}

- (void)cancelButtonEvent {
    [self dealDelegate:0];
}

- (void)dealDelegate:(NSUInteger)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardAlertView:clickedButtonAtIndex:)]) {
        [self.delegate forwardAlertView:self clickedButtonAtIndex:event];
    }
    self.count = 0;
    [self removeFromSuperview];
}

@end

@interface RCDForwardMananer ()
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation RCDForwardMananer

+ (RCDForwardMananer *)shareInstance {
    static RCDForwardMananer *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)showForwardAlertViewInViewController:(UIViewController *)viewController{
    self.viewController = viewController;
    RCDForwardAlertView *alertView = [RCDForwardAlertView alertViewWithModel:self.toConversation];
    alertView.delegate = self;
    [alertView show];
}

- (void)forwardAlertView:(RCDForwardAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self doForwardMessage:alertView];
    }
}

- (void)doForwardMessage:(RCDForwardAlertView *)alertView{
    for (RCMessageModel *message in self.selectedMessages) {
        __weak typeof(self) weakSelf = self;
        [[RCIM sharedRCIM] sendMessage:self.toConversation.conversationType targetId:self.toConversation.targetId content:message.content pushContent:nil pushData:nil success:^(long messageId) {
            [weakSelf dismiss];
        } error:^(RCErrorCode nErrorCode, long messageId) {
            [weakSelf dismiss];
        }];
        [NSThread sleepForTimeInterval:0.4];
    }
}

- (void)dismiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
        [self clear];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RCDForwardMessageEnd" object:nil];
    });
}

- (BOOL)allSelectedMessagesAreLegal {
    for (RCMessageModel *model in self.selectedMessages) {
        BOOL result = [self isLegalMessage:model];
        if (!result) {
            return result; // return no
        }
    }
    return YES;
}

- (BOOL)isLegalMessage:(RCMessageModel *)model {
    //未成功发送的消息不可转发
    if (model.sentStatus == SentStatus_SENDING || model.sentStatus == SentStatus_FAILED ||
        model.sentStatus == SentStatus_CANCELED) {
        return NO;
    }
    if ([[self blackList] containsObject:model.objectName]) {
        return NO;
    }
    return YES;
}

- (NSArray<NSString *> *)blackList {
    static NSArray *blackList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blackList = @[
                      @"RC:VCAccept", @"RC:VCHangup", @"RC:VCInvite", @"RC:VCModifyMedia", @"RC:VCModifyMem", @"RC:VCRinging",
                      @"RC:VCSummary", @"RC:RLStart", @"RC:RLEnd", @"RC:RLJoin", @"RC:RLQuit", @"RCJrmf:RpMsg", @"RC:VcMsg"
                      ];
    });
    return blackList;
}

- (void)clear{
    self.isForward = NO;
    self.selectedMessages = nil;
    self.toConversation = nil;
}
@end
