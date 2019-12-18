//
//  RCDUserListCollectionView.m
//  SealTalk
//
//  Created by 张改红 on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDUserListCollectionView.h"
#import "RCDUserListCollectionItem.h"
#import "RCDUserInfoManager.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDUtilities.h"
@interface RCDUserListCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *userList;
@property (nonatomic, assign) BOOL isAllowAdd;
@property (nonatomic, assign) BOOL isAllowDelete;
@end
@implementation RCDUserListCollectionView
- (instancetype)initWithFrame:(CGRect)frame isAllowAdd:(BOOL)isAllowAdd isAllowDelete:(BOOL)isAllowDelete {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:flowLayout];
    if (self) {
        self.isAllowAdd = isAllowAdd;
        self.isAllowDelete = isAllowDelete;
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
        [self registerClass:[RCDUserListCollectionItem class] forCellWithReuseIdentifier:@"RCDUserListCollectionItem"];
        [self registerClass:[RCDUserListCollectionItem class]
            forCellWithReuseIdentifier:@"RCDUserListCollectionItemForSigns"];
    }
    return self;
}

#pragma mark - Api
- (void)reloadData:(NSArray *)userList {
    self.userList = userList;
    [self reloadData];
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
    NSInteger row = self.userList.count;
    if (self.isAllowAdd) {
        row += 1;
        if (self.isAllowDelete) {
            row += 1;
        }
    }
    return row;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (indexPath.row < self.userList.count) {
        RCDUserListCollectionItem *settingCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDUserListCollectionItem" forIndexPath:indexPath];
        settingCell.groupId = self.groupId;
        [settingCell setUserModel:self.userList[indexPath.row]];

        settingCell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
        cell = settingCell;
    } else {
        UIImage *image = [UIImage imageNamed:@"add_member"];
        if (self.isAllowDelete) {
            if (indexPath.row == self.userList.count + 1) {
                image = [UIImage imageNamed:@"delete_member"];
            }
        }
        RCDUserListCollectionItem *cellForSigns =
            [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDUserListCollectionItemForSigns"
                                                      forIndexPath:indexPath];
        cellForSigns.ivAva.image = nil;
        cellForSigns.ivAva.image = image;
        cellForSigns.titleLabel.text = @"";
        cell = cellForSigns;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.userList.count) {
        RCUserInfo *user = self.userList[indexPath.row];
        if ([self.userList[indexPath.row] isKindOfClass:[NSString class]]) {
            user = [RCDUserInfoManager getUserInfo:self.userList[indexPath.row]];
        }
        if (self.userListCollectionViewDelegate &&
            [self.userListCollectionViewDelegate respondsToSelector:@selector(didTipHeaderClicked:)]) {
            [self.userListCollectionViewDelegate didTipHeaderClicked:user.userId];
        }
    } else if (self.isAllowAdd && indexPath.row == self.userList.count) {
        if (self.userListCollectionViewDelegate &&
            [self.userListCollectionViewDelegate respondsToSelector:@selector(addButtonDidClicked)]) {
            [self.userListCollectionViewDelegate addButtonDidClicked];
        }
    } else if (self.isAllowDelete && indexPath.row == self.userList.count + 1) {
        if (self.userListCollectionViewDelegate &&
            [self.userListCollectionViewDelegate respondsToSelector:@selector(deleteButtonDidClicked)]) {
            [self.userListCollectionViewDelegate deleteButtonDidClicked];
        }
    }
}
@end
