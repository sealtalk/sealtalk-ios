//
//  RCDReceiptDetailsTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/9/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDReceiptDetailsTableViewCell.h"
#import "RCDCommonDefine.h"
#import "RCDConversationSettingTableViewHeaderItem.h"
#import "RCDataBaseManager.h"
#import "UIColor+RCColor.h"

@interface RCDReceiptDetailsTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) NSDictionary *CellSubviews;

@property(nonatomic, strong) UIView *verticalLine;

@property(nonatomic, strong) UIButton *hasReadButton;

@property(nonatomic, strong) UIButton *unReadButton;

@property(nonatomic, strong) UIView *line;

@property(nonatomic, strong) UIView *leftSelectLine;

@property(nonatomic, strong) UIView *rightSelectLine;

@property(nonatomic, strong) UICollectionView *userListView;

@property(nonatomic, strong) NSMutableArray *collectionViewResource;

@end

@implementation RCDReceiptDetailsTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.collectionViewResource = [NSMutableArray new];

    self.verticalLine = [self createLine:[UIColor colorWithHexString:@"dfdfdf" alpha:1.f]];
    [self.contentView addSubview:self.verticalLine];

    self.hasReadButton =
        [self createButton:[NSString stringWithFormat:RCDLocalizedString(@"x_people_had_read"), (unsigned long)self.userList.count]];
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
    self.userListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.userListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userListView.delegate = self;
    self.userListView.dataSource = self;
    self.userListView.scrollEnabled = YES;
    self.userListView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.userListView];
    [self.userListView registerClass:[RCDConversationSettingTableViewHeaderItem class]
          forCellWithReuseIdentifier:@"RCDConversationSettingTableViewHeaderItem"];
    
    self.CellSubviews = NSDictionaryOfVariableBindings(_verticalLine, _hasReadButton, _unReadButton, _line, _userListView);
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
    UIColor *normalColor = [UIColor colorWithHexString:@"000000" alpha:1.f];
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
                                                                   @"width" : @(RCDscreenWidth / 2 - 1)
                                                               }
                                                                 views:self.CellSubviews]];
    [self.contentView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hasReadButton(44)][_line(0.5)][_userListView]"
                                                               options:0
                                                               metrics:nil
                                                                 views:self.CellSubviews]];
    
    [self.contentView
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_userListView]|"
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
                                                                                 @"width" : @(RCDscreenWidth / 2 - 1)
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)clickHasReadButton:(UIButton *)button {
    if (button.selected == YES) {
        return;
    }
    button.selected = !button.selected;
    [self.delegate clickHasReadButton];
}

- (void)clickUnreadButton:(UIButton *)button {
    if (button.selected == YES) {
        return;
    }
    button.selected = !button.selected;
    [self.delegate clickUnreadButton];
}

- (void)setUserList:(NSArray *)userList {
    _userList = userList;
    for (NSString *userId in userList) {
        for (RCUserInfo *user in self.groupMemberList) {
            if ([userId isEqualToString:user.userId]) {
                [self.collectionViewResource addObject:user];
            }
        }
    }
    if (self.collectionViewResource.count == userList.count) {
        // cell的高度 - button的高度 - 蓝色线的高度 = collectionView的高度
        [self.contentView
         addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userListView(height)]"
                                                                options:0
                                                                metrics:@{
                                                                          @"height" : @(self.cellHeight - 44 - 1)
                                                                          }
                                                                  views:self.CellSubviews]];
        [self.userListView reloadData];
    }
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

- (void)setHasReadUsersCount:(NSUInteger)hasReadUsersCount {
    [self.hasReadButton setTitle:[NSString stringWithFormat:RCDLocalizedString(@"x_people_had_read"), (unsigned long)hasReadUsersCount]
                        forState:UIControlStateNormal];
}

- (void)setUnreadUsersCount:(NSUInteger)unreadUsersCount {
    [self.unReadButton setTitle:[NSString stringWithFormat:RCDLocalizedString(@"x_people_unread"), (unsigned long)unreadUsersCount]
                       forState:UIControlStateNormal];
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = 55;
    float height = width + 15 + 9;

    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.minimumLineSpacing = 12;
    return UIEdgeInsetsMake(15, 10, 10, 10);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionViewResource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDConversationSettingTableViewHeaderItem *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDConversationSettingTableViewHeaderItem"
                                                  forIndexPath:indexPath];

    if (self.collectionViewResource.count > 0) {
        RCUserInfo *user = self.collectionViewResource[indexPath.row];
        if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            [cell.btnImg setHidden:YES];
        }
        [cell setUserModel:user];
    }
    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate clickPortrait:[_userList objectAtIndex:indexPath.row]];
}

@end
