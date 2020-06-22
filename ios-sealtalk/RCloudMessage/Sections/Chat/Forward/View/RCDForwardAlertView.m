//
//  RCDForwardAlertView.m
//  RongEnterpriseApp
//
//  Created by Sin on 17/3/13.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RCDForwardAlertView.h"
#import "RCDCommonDefine.h"
#import "RCDDBManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDForwardCellModel.h"
#import "RCDGroupManager.h"
#import "RCDUserInfoManager.h"
#import "DefaultPortraitView.h"
#import "RCDUtilities.h"
#define itemHight 40

@interface RCDForwardAlertView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *forwardContentLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

// data
@property (nonatomic, strong) UIImage *imageData;
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, strong) NSArray *selectedContacts;

@end

@implementation RCDForwardAlertView
+ (instancetype)alertViewWithModel:(RCConversation *)model {
    if (!model) {
        return nil;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    RCDForwardAlertView *alertV = [[self alloc] initWithFrame:keyWindow.bounds];
    [alertV setModel:model];
    return alertV;
}

+ (instancetype)alertViewWithSelectedContacts:(NSArray *)selectedContacts {
    if (selectedContacts.count <= 0) {
        return nil;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    RCDForwardAlertView *alertV = [[self alloc] initWithFrame:keyWindow.bounds];
    alertV.selectedContacts = selectedContacts;
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

#pragma mark - Target Action
- (void)confirmButtonEvent {
    [self dealDelegate:1];
}

- (void)cancelButtonEvent {
    [self dealDelegate:0];
}

#pragma mark - Private Method
- (void)loadSubviews {
    self.backgroundColor = [RCDUtilities generateDynamicColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.5]
                                                    darkColor:[HEXCOLOR(0x6a6a6a) colorWithAlphaComponent:0.6]];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.cancelButton];
    [self.contentView addSubview:self.confirmButton];
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.forwardContentLabel];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(27);
        make.center.equalTo(self);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.right.equalTo(self.contentView).inset(18);
        make.height.offset(25);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(12);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(14);
        make.height.offset(55);
    }];
    UIView *firstLine = [[UIView alloc] init];
    firstLine.backgroundColor = RCDDYCOLOR(0xE5E5E5, 0x3a3a3a);
    [self.contentView addSubview:firstLine];
    [firstLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.scrollView.mas_bottom);
        make.height.offset(1);
    }];
    [self.forwardContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView).inset(18);
        make.top.equalTo(self.scrollView.mas_bottom);
        make.height.offset(44);
    }];
    UIView *secondLine = [[UIView alloc] init];
    secondLine.backgroundColor = RCDDYCOLOR(0xE5E5E5, 0x3a3a3a);
    [self.contentView addSubview:secondLine];
    [secondLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.forwardContentLabel.mas_bottom);
        make.height.offset(1);
    }];
    UIView *separateLine = [[UIView alloc] init];
    separateLine.backgroundColor = RCDDYCOLOR(0xE5E5E5, 0x3a3a3a);
    [self.contentView addSubview:separateLine];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.forwardContentLabel.mas_bottom);
        make.right.equalTo(separateLine.mas_left);
        make.height.offset(44);
        make.bottom.equalTo(self.contentView);
    }];
    [separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.cancelButton);
        make.width.offset(1);
        make.centerX.equalTo(self.contentView);
    }];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(separateLine.mas_right);
        make.top.equalTo(self.forwardContentLabel.mas_bottom);
        make.right.equalTo(self.contentView);
        make.height.offset(44);
        make.bottom.equalTo(self.contentView);
    }];
}

- (void)setModel:(RCConversation *)model {
    _model = model;
    CGFloat originX = 18;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 7.5, itemHight, itemHight)];
    RCDForwardCellModel *cellModel = [RCDForwardCellModel createModelWith:model];
    [self loadImageWithModel:cellModel forImageView:imageView];
    imageView.layer.cornerRadius = 2;
    imageView.layer.masksToBounds = YES;
    [self.scrollView addSubview:imageView];
    [self.scrollView addSubview:self.nameLabel];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(10);
        make.centerY.height.equalTo(imageView);
        make.right.equalTo(self.scrollView).offset(-10);
    }];

    if (model.conversationType == ConversationType_PRIVATE) {
        RCDFriendInfo *userInfo;
        if ([model.targetId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
            userInfo = (RCDFriendInfo *)[RCIM sharedRCIM].currentUserInfo;
        } else {
            userInfo = [RCDDBManager getFriend:model.targetId];
        }
        self.nameLabel.text = userInfo.name;
    } else if (model.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDDBManager getGroup:model.targetId];
        self.nameLabel.text = groupInfo.groupName;
    }
}

- (void)setContacts:(NSArray *)contacts {
    _selectedContacts = contacts;
}

- (void)updateUI {
    self.titleLabel.text = RCDLocalizedString(@"SendTo");
    if (self.messageArray.count == 1) {
        RCMessageModel *messageModel = [self.messageArray firstObject];
        NSString *displayString = [self getDigest:messageModel];
        if (displayString.length > 10) {
            displayString = [[displayString substringToIndex:10] stringByAppendingString:@"..."];
        }
        self.forwardContentLabel.text = displayString;
    } else {
        self.forwardContentLabel.text =
            [NSString stringWithFormat:RCDLocalizedString(@"ForwardMessageCount"), self.messageArray.count];
    }

    if (self.selectedContacts.count > 0) {
        [self refreshScrollView];
    }
}

- (NSString *)getDigest:(RCMessageModel *)messageModel {
    NSString *displayString = @"";
    if ([messageModel.content respondsToSelector:@selector(conversationDigest)]) {
        displayString = messageModel.content.conversationDigest;
    } else if ([messageModel.content isMemberOfClass:RCRichContentMessage.class]) {
        RCRichContentMessage *richContentMessage = (RCRichContentMessage *)messageModel.content;
        displayString = richContentMessage.digest;
    } else {
        displayString = RCDLocalizedString(@"UnknownMessage");
    }

    return displayString;
}

- (void)refreshScrollView {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }

    for (int i = 0; i < self.selectedContacts.count; i++) {
        RCDForwardCellModel *model = self.selectedContacts[i];
        CGFloat originX = i * (itemHight + 5);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 7.5, itemHight, itemHight)];
        [self loadImageWithModel:model forImageView:imageView];
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(self.selectedContacts.count * (itemHight) + 5, itemHight + 15);
}

- (void)loadImageWithModel:(RCDForwardCellModel *)model forImageView:(UIImageView *)imageView {
    NSString *imageUrl = @"";
    NSString *name;
    if (model.conversationType == ConversationType_PRIVATE) {
        RCUserInfo *userInfo = [RCDUserInfoManager getUserInfo:model.targetId];
        imageUrl = userInfo.portraitUri;
        name = userInfo.name;
    } else if (model.conversationType == ConversationType_GROUP) {
        RCDGroupInfo *groupInfo = [RCDGroupManager getGroupInfo:model.targetId];
        imageUrl = groupInfo.portraitUri;
        name = groupInfo.groupName;
    }
    if (imageUrl.length > 0) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                     placeholderImage:[UIImage imageNamed:@"default_portrait_msg"]];
    } else {
        imageView.image = [DefaultPortraitView portraitView:model.targetId name:name];
    }
}

- (void)dealDelegate:(NSUInteger)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardAlertView:clickedButtonAtIndex:)]) {
        [self.delegate forwardAlertView:self clickedButtonAtIndex:event];
    }
    self.count = 0;
    [self removeFromSuperview];
}

#pragma mark - Getter && Setter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor =
            [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x000000) colorWithAlphaComponent:0.8]];
        _contentView.layer.cornerRadius = 5;
        _contentView.layer.masksToBounds = YES;
        _contentView.userInteractionEnabled = YES;
    }
    return _contentView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:RCDLocalizedString(@"cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:RCDDYCOLOR(0x262626, 0x9f9f9f) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton addTarget:self action:@selector(cancelButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:RCDLocalizedString(@"send") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:@"3A91F3" alpha:1] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_confirmButton addTarget:self
                           action:@selector(confirmButtonEvent)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
    }
    return _titleLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        _nameLabel.font = [UIFont systemFontOfSize:18];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.scrollView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)forwardContentLabel {
    if (!_forwardContentLabel) {
        _forwardContentLabel = [[UILabel alloc] init];
        _forwardContentLabel.textColor = RCDDYCOLOR(0x262626, 0x9f9f9f);
        _forwardContentLabel.font = [UIFont systemFontOfSize:17];
    }
    return _forwardContentLabel;
}

@end
