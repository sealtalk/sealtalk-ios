//
//  RCDReceiptDetailHeader.m
//  SealTalk
//
//  Created by 张改红 on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailHeader.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"
@interface RCDReceiptDetailHeader ()
@property (nonatomic, strong) RCMessageModel *message;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *messageContentLabel;

@property (nonatomic, strong) UIButton *openAndCloseButton;

@property (nonatomic, assign) CGFloat headerViewHeight;
@end
@implementation RCDReceiptDetailHeader
- (instancetype)initWithMessage:(RCMessageModel *)message {
    if (self = [super init]) {
        self.message = message;
        [self addSubbiews];
    }
    return self;
}

#pragma mark - target action
- (void)openAndCloseMessageContentLabel:(UIButton *)button {
    [button setSelected:!button.selected];
    if (button.selected == YES) {
        self.messageContentLabel.numberOfLines = 0;
        self.headerViewHeight =
            70 +
            [self.messageContentLabel sizeThatFits:CGSizeMake(self.messageContentLabel.frame.size.width, MAXFLOAT)]
                .height;
    } else {
        self.headerViewHeight = 145;
        self.messageContentLabel.numberOfLines = 4;
    }
    [self updateHeaderViewFrame:self.headerViewHeight];
}

#pragma mark - helper
- (void)addSubbiews {
    [self addSubview:self.nameLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.messageContentLabel];
    [self addSubview:self.openAndCloseButton];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(7.5);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-100);
        make.height.offset(21);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(7.5);
        make.right.equalTo(self).offset(-10);
        make.height.offset(21);
    }];
    [self.messageContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(7);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
    }];
    NSUInteger lines = [self numberOfRowsInLabel:self.messageContentLabel];
    if (lines <= 4) {
        self.openAndCloseButton.hidden = YES;
        [self.openAndCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageContentLabel.mas_bottom).offset(8.5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.offset(0);
        }];
        self.headerViewHeight =
            47 +
            [self.messageContentLabel sizeThatFits:CGSizeMake(self.messageContentLabel.frame.size.width, MAXFLOAT)]
                .height;
    } else {
        self.headerViewHeight = 145;
        self.openAndCloseButton.hidden = NO;
        [self.openAndCloseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageContentLabel.mas_bottom).offset(8.5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.offset(14);
        }];
    }
    [self updateHeaderViewFrame:self.headerViewHeight];
}

- (void)updateHeaderViewFrame:(CGFloat)height {
    self.frame = CGRectMake(0, 0, RCDScreenWidth, height);
    if (self.delegate && [self.delegate respondsToSelector:@selector(receiptDetailHeaderDidUpdate:)]) {
        [self.delegate receiptDetailHeaderDidUpdate:!self.openAndCloseButton.selected];
    }
}

- (NSInteger)numberOfRowsInLabel:(UILabel *)label {
    CGFloat labelWidth = RCDScreenWidth - 20;
    NSDictionary *attrs = @{NSFontAttributeName : label.font};
    CGSize maxSize = CGSizeMake(labelWidth, MAXFLOAT);
    CGFloat textH = [label.text boundingRectWithSize:maxSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attrs
                                             context:nil]
                        .size.height;
    CGFloat lineHeight = label.font.lineHeight;
    NSInteger lineCount = textH / lineHeight;
    return lineCount;
}

#pragma mark - getter & setter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:16.f];
        _nameLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        _nameLabel.text = [RCIM sharedRCIM].currentUserInfo.name;
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = RCDDYCOLOR(0x999999, 0x666666);
        _timeLabel.text = [RCKitUtility ConvertMessageTime:self.message.sentTime / 1000];
    }
    return _timeLabel;
}

- (UILabel *)messageContentLabel {
    if (!_messageContentLabel) {
        _messageContentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageContentLabel.font = [UIFont systemFontOfSize:16.f];
        _messageContentLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        RCTextMessage *messageContent = (RCTextMessage *)self.message.content;
        _messageContentLabel.text = messageContent.content;
        _messageContentLabel.numberOfLines = 4;
    }
    return _messageContentLabel;
}

- (UIButton *)openAndCloseButton {
    if (!_openAndCloseButton) {
        _openAndCloseButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_openAndCloseButton setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
        [_openAndCloseButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
        [_openAndCloseButton addTarget:self
                                action:@selector(openAndCloseMessageContentLabel:)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return _openAndCloseButton;
}
@end
