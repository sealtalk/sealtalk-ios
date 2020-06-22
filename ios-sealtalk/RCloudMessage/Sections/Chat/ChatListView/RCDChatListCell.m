//
//  RCDChatListCell.m
//  RCloudMessage
//
//  Created by Liv on 15/4/15.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDChatListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDUserInfoManager.h"
#import "RCDContactNotificationMessage.h"
#import "RCDUtilities.h"
@interface RCDChatListCell ()
@property (nonatomic, strong) UIImageView *ivAva;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UILabel *lblDetail;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) UILabel *labelTime;
@end

@implementation RCDChatListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    RCDChatListCell *cell = (RCDChatListCell *)[tableView dequeueReusableCellWithIdentifier:RCDChatListCellIdentifier];
    if (!cell) {
        cell = [[RCDChatListCell alloc] init];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setupSubviews];
    }
    return self;
}

- (void)setDataModel:(RCConversationModel *)model {
    self.model = model;
    __block NSString *userName = nil;
    __block NSString *portraitUri = nil;
    //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
    if (nil == model.extend) {
        // Not finished yet, To Be Continue...
        if (model.conversationType == ConversationType_SYSTEM) {
            NSString *sourceUserId;
            if ([model.lastestMessage isMemberOfClass:[RCDContactNotificationMessage class]]) {
                RCDContactNotificationMessage *_contactNotificationMsg =
                    (RCDContactNotificationMessage *)model.lastestMessage;
                sourceUserId = _contactNotificationMsg.sourceUserId;
            } else if ([model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]) {
                RCContactNotificationMessage *_contactNotificationMsg =
                    (RCContactNotificationMessage *)model.lastestMessage;
                sourceUserId = _contactNotificationMsg.sourceUserId;
            }

            if (sourceUserId == nil) {
                self.lblDetail.text = RCDLocalizedString(@"friend_request");
                [self.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                              placeholderImage:[UIImage imageNamed:@"system_notice"]];
                return;
            }
            NSDictionary *_cache_userinfo = [DEFAULTS objectForKey:sourceUserId];
            if (_cache_userinfo) {
                userName = _cache_userinfo[@"username"];
                portraitUri = _cache_userinfo[@"portraitUri"];
            } else {
                __weak typeof(self) weakSelf = self;
                [RCDUserInfoManager getUserInfoFromServer:sourceUserId
                                                 complete:^(RCUserInfo *user) {
                                                     if (user == nil) {
                                                         return;
                                                     }
                                                     [weakSelf setDataInfo:user.name portraitUri:user.portraitUri];
                                                     [weakSelf cacheUserInfo:user];
                                                 }];
            }
        }
    } else {
        RCDFriendInfo *user = (RCDFriendInfo *)model.extend;
        if (user.displayName.length > 0) {
            userName = user.displayName;
        } else {
            userName = user.name;
        }
        portraitUri = user.portraitUri;
    }
    [self setDataInfo:userName portraitUri:portraitUri];
}

- (void)setDataInfo:(NSString *)userName portraitUri:(NSString *)portraitUri {
    NSString *operation;
    if ([(self.model.lastestMessage) isMemberOfClass:[RCDContactNotificationMessage class]]) {
        RCDContactNotificationMessage *_contactNotificationMsg =
            (RCDContactNotificationMessage *)(self.model.lastestMessage);
        operation = _contactNotificationMsg.operation;
    } else if ([(self.model.lastestMessage) isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *_contactNotificationMsg =
            (RCContactNotificationMessage *)(self.model.lastestMessage);
        operation = _contactNotificationMsg.operation;
    }
    NSString *operationContent;
    if ([operation isEqualToString:RCDContactNotificationMessage_ContactOperationRequest]) {
        operationContent = [NSString stringWithFormat:RCDLocalizedString(@"from_someone_friend_request"), userName];
    } else if ([operation isEqualToString:RCDContactNotificationMessage_ContactOperationAcceptResponse]) {
        operationContent =
            [NSString stringWithFormat:RCDLocalizedString(@"someone_accept_you_friend_request"), userName];
    }
    rcd_dispatch_main_async_safe(^{
        self.lblDetail.text = operationContent;
        [self.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri]
                      placeholderImage:[UIImage imageNamed:@"system_notice"]];
        self.labelTime.text = [RCKitUtility ConvertMessageTime:self.model.sentTime / 1000];
    });
}

- (void)cacheUserInfo:(RCUserInfo *)user {
    RCDFriendInfo *rcduserinfo_ = [RCDFriendInfo new];
    rcduserinfo_.name = user.name;
    rcduserinfo_.userId = user.userId;
    rcduserinfo_.portraitUri = user.portraitUri;
    self.model.extend = rcduserinfo_;
    // local cache for userInfo
    NSDictionary *userinfoDic = @{ @"username" : rcduserinfo_.name, @"portraitUri" : rcduserinfo_.portraitUri };
    [DEFAULTS setObject:userinfoDic forKey:user.userId];
    [DEFAULTS synchronize];
}

- (void)setupSubviews {
    _ivAva = [UIImageView new];
    _ivAva.clipsToBounds = YES;
    _ivAva.layer.cornerRadius = 5.0f;
    if ([[RCIM sharedRCIM] globalConversationAvatarStyle] == RC_USER_AVATAR_CYCLE) {
        _ivAva.layer.cornerRadius = [[RCIM sharedRCIM] globalConversationPortraitSize].height / 2;
    }

    [_ivAva setBackgroundColor:[UIColor blackColor]];

    _lblDetail = [UILabel new];
    [_lblDetail setFont:[UIFont systemFontOfSize:14.f]];
    [_lblDetail setTextColor:HEXCOLOR(0x8c8c8c)];
    _lblDetail.text = [NSString stringWithFormat:RCDLocalizedString(@"from_someone_friend_request"), _userName];

    _lblName = [UILabel new];
    [_lblName setFont:[UIFont boldSystemFontOfSize:16.f]];
    [_lblName setTextColor:RCDDYCOLOR(0x252525, 0x9f9f9f)];
    _lblName.text = RCDLocalizedString(@"friend_news");

    _labelTime = [[UILabel alloc] init];
    _labelTime.backgroundColor = [UIColor clearColor];
    _labelTime.font = [UIFont systemFontOfSize:14];
    _labelTime.textColor = [RCDUtilities generateDynamicColor:[UIColor lightGrayColor] darkColor:HEXCOLOR(0x707070)];
    _labelTime.textAlignment = NSTextAlignmentRight;

    [self.contentView addSubview:_ivAva];
    [self.contentView addSubview:_lblDetail];
    [self.contentView addSubview:_lblName];
    [self.contentView addSubview:_labelTime];
    _ivAva.translatesAutoresizingMaskIntoConstraints = NO;
    _lblName.translatesAutoresizingMaskIntoConstraints = NO;
    _lblDetail.translatesAutoresizingMaskIntoConstraints = NO;
    _labelTime.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *_bindingViews = NSDictionaryOfVariableBindings(_ivAva, _lblName, _lblDetail, _labelTime);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-11-[_labelTime(20)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_labelTime)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_labelTime(200)]-11-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_labelTime)]];

    [self
        addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:|-13-[_ivAva(width)]"
                                               options:0
                                               metrics:@{
                                                   @"width" : @([RCIM sharedRCIM].globalConversationPortraitSize.width)
                                               }
                                                 views:NSDictionaryOfVariableBindings(_ivAva)]];

    [self addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|-10-[_ivAva(height)]"
                                                 options:0
                                                 metrics:@{
                                                     @"height" :
                                                         @([RCIM sharedRCIM].globalConversationPortraitSize.height)
                                                 }
                                                   views:NSDictionaryOfVariableBindings(_ivAva)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lblName(18)]-[_lblDetail(18)]"
                                                                 options:kNilOptions
                                                                 metrics:kNilOptions
                                                                   views:_bindingViews]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblName
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_ivAva
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:2.f]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblName
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_ivAva
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:8]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblDetail
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_lblName
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:1]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_lblDetail
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_labelTime
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-30]];
}
@end
