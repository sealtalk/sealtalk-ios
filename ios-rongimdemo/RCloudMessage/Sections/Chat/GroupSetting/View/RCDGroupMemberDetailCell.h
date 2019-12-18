//
//  RCDGroupMyInfoCell.h
//  SealTalk
//
//  Created by 张改红 on 2019/8/6.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDTableViewCell.h"
#import "UITextViewAndPlaceholder.h"
@class RCDGroupMemberDetailCell;
static NSString *_Nullable RCDGroupMyInfoCellIdentifier = @"RCDGroupMyInfoCellIdentifier";

NS_ASSUME_NONNULL_BEGIN
@protocol RCDGroupMemberDetailCellDelegate <NSObject>
- (void)textViewWillBeginEditing:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell;

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text
                     inCell:(RCDGroupMemberDetailCell *)cell;

- (void)textViewDidChange:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell;

- (void)textViewDidEndEditing:(UITextView *)textView inCell:(RCDGroupMemberDetailCell *)cell;

- (void)onSelectPhoneRegionCode:(RCDGroupMemberDetailCell *)cell;
@end
@interface RCDGroupMemberDetailCell : RCDTableViewCell

@property (nonatomic, weak) id<RCDGroupMemberDetailCellDelegate> delegate;
@property (nonatomic, strong) UITextViewAndPlaceholder *textView;
+ (CGFloat)getCellHeight:(UITableView *)tableView leftTitle:(NSString *)leftTitle text:(NSString *)text;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)setLeftTitle:(NSString *)leftTitle placeholder:(NSString *)placeholder;

- (void)setDetailInfo:(NSString *)detail;

- (void)setPhoneRegionCode:(NSString *)code;

- (void)showClearButton:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
