//
//  RCDConversationSettingTableViewHeader.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDConversationSettingTableViewHeader.h"
#import "RCDCommonDefine.h"
#import "RCDConversationSettingTableViewHeaderItem.h"
#import "RCDUtilities.h"
#import "UIImageView+WebCache.h"

@interface RCDConversationSettingTableViewHeader () <RCDConversationSettingTableViewHeaderItemDelegate>

@end
@implementation RCDConversationSettingTableViewHeader

- (NSArray *)users {
    if (!_users) {
        _users = [@[] mutableCopy];
    }
    return _users;
}

- (instancetype)init {
    CGRect tempRect = CGRectMake(0, 0, RCDscreenWidth, 120);
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:tempRect collectionViewLayout:flowLayout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        [self registerClass:[RCDConversationSettingTableViewHeaderItem class]
            forCellWithReuseIdentifier:@"RCDConversationSettingTableViewHeaderItem"];
        self.isAllowedInviteMember = YES;
    }
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isAllowedDeleteMember) {
        return self.users.count + 2;
    } else {
        if (self.isAllowedInviteMember) {
            return self.users.count + 1;
        } else {
            return self.users.count;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDConversationSettingTableViewHeaderItem *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDConversationSettingTableViewHeaderItem"
                                                  forIndexPath:indexPath];

    if (self.users.count && (self.users.count - 1 >= indexPath.row)) {
        RCUserInfo *user = self.users[indexPath.row];
        if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
            [cell.btnImg setHidden:YES];
        } else {
            [cell.btnImg setHidden:!self.showDeleteTip];
        }
        [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri]
                      placeholderImage:[UIImage imageNamed:@"icon_person"]];
        cell.titleLabel.text = user.name;
        cell.userId = user.userId;

        cell.delegate = self;

        //长按显示减号
        UILongPressGestureRecognizer *longPressGestureRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showDeleteTip:)];
        longPressGestureRecognizer.minimumPressDuration = 0.28;
        [cell addGestureRecognizer:longPressGestureRecognizer];
        // cell.tag=[NSString stringWithFormat:@"%@",user.userId];
        //点击隐藏减号
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidesDeleteTip:)];
        [cell addGestureRecognizer:tap];

    } else if (self.users.count >= indexPath.row) {

        cell.btnImg.hidden = YES;
        cell.gestureRecognizers = nil;
        cell.titleLabel.text = @"";
        [cell.ivAva setImage:[RCDUtilities imageNamed:@"add_members" ofBundle:@"RongCloud.bundle"]];

    } else {
        cell.btnImg.hidden = YES;
        cell.gestureRecognizers = nil;
        cell.titleLabel.text = @"";
        [cell.ivAva setImage:[RCDUtilities imageNamed:@"delete_members" ofBundle:@"RongCloud.bundle"]];
        //长按显示减号
        //        UILongPressGestureRecognizer *longPressGestureRecognizer =
        //        [[UILongPressGestureRecognizer alloc]
        //         initWithTarget:self
        //         action:@selector(showDeleteTip:)];
        //        longPressGestureRecognizer.minimumPressDuration = 0.28;
        //        [cell addGestureRecognizer:longPressGestureRecognizer];

        //点击去除减号
        //        UITapGestureRecognizer *singleTapGestureRecognizer =
        //        [[UITapGestureRecognizer alloc]
        //         initWithTarget:self
        //         action:@selector(notShowDeleteTip:)];
        //        [cell addGestureRecognizer:singleTapGestureRecognizer];
    }

    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

#pragma mark - RCConversationSettingTableViewHeaderItemDelegate
- (void)deleteTipButtonClicked:(RCDConversationSettingTableViewHeaderItem *)item {

    NSIndexPath *indexPath = [self indexPathForCell:item];
    RCUserInfo *user = self.users[indexPath.row];
    if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:NSLocalizedStringFromTable(@"CanNotRemoveSelf", @"RongCloudKit", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                             otherButtonTitles:nil, nil];
        ;
        [alertView show];
        return;
    }
    [self.users removeObjectAtIndex:indexPath.row];
    [self deleteItemsAtIndexPaths:@[ indexPath ]];

    if (self.settingTableViewHeaderDelegate &&
        [self.settingTableViewHeaderDelegate respondsToSelector:@selector(deleteTipButtonClicked:)]) {
        [self.settingTableViewHeaderDelegate deleteTipButtonClicked:indexPath];
        [self reloadData];
    }
}

//长按显示减号
- (void)showDeleteTip:(RCDConversationSettingTableViewHeaderItem *)cell {
    if (self.isAllowedDeleteMember) {
        self.showDeleteTip = YES;
        [self reloadData];
    }
}

//点击去除减号
//- (void)notShowDeleteTip:(RCDConversationSettingTableViewHeaderItem *)cell {
//
//    if (self.showDeleteTip == YES) {
//
//        self.showDeleteTip = NO;
//
//        [self reloadData];
//
//    }
//
//}

//点击隐藏减号
- (void)hidesDeleteTip:(UITapGestureRecognizer *)recognizer {
    if (self.showDeleteTip) {
        self.showDeleteTip = NO;
        [self reloadData];
    } else {
        if (self.settingTableViewHeaderDelegate &&
            [self.settingTableViewHeaderDelegate respondsToSelector:@selector(didTipHeaderClicked:)]) {
            RCDConversationSettingTableViewHeaderItem *cell =
                (RCDConversationSettingTableViewHeaderItem *)recognizer.view;
            [self.settingTableViewHeaderDelegate didTipHeaderClicked:cell.userId];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = 56;
    float height = width + 15 + 5;

    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.users.count + 1) {
        if (self.isAllowedDeleteMember) {
            self.showDeleteTip = !self.showDeleteTip;
            [self reloadData];
        }
    }
    if (indexPath && self.settingTableViewHeaderDelegate &&
        [self.settingTableViewHeaderDelegate
            respondsToSelector:@selector(settingTableViewHeader:indexPathOfSelectedItem:allTheSeletedUsers:)]) {
        [self.settingTableViewHeaderDelegate settingTableViewHeader:self
                                            indexPathOfSelectedItem:indexPath
                                                 allTheSeletedUsers:self.users];
    }
}

@end
