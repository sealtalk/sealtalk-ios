//
//  RCDDebugSelectItem.m
//  SealTalk
//
//  Created by 张改红 on 2020/8/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebugSelectView.h"
#import "RCDUtilities.h"
#import "UIColor+RCColor.h"
#import <RongIMKit/RongIMKit.h>
@interface RCDDebugSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *titleList;
@end
@implementation RCDDebugSelectView
- (instancetype)initWithFrame:(CGRect)rect titleList:(NSArray *)titleList{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(rect.size.width/2-10, 40);
    self = [super initWithFrame:rect collectionViewLayout:flowLayout];
    if (self) {
        self.titleList = titleList;
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor clearColor];
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"RCDDebugCollectionItem"];
    }
    return self;
}

#pragma mark - Api
- (void)reloadData:(NSArray *)titleList{
    self.titleList = titleList;
    [self reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:@"RCDDebugCollectionItem" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, cell.contentView.frame.size.width-20, cell.contentView.frame.size.height - 10)];
    lable.layer.cornerRadius = 4;
    lable.layer.masksToBounds = YES;
    lable.layer.borderWidth = 0.5;
    lable.layer.borderColor = [UIColor blackColor].CGColor;
    lable.font = [UIFont systemFontOfSize:15];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = self.titleList[indexPath.row];
    [cell.contentView addSubview:lable];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.debugSelectViewDelegate &&
        [self.debugSelectViewDelegate respondsToSelector:@selector(didTipItemClicked:)]) {
        [self.debugSelectViewDelegate didTipItemClicked:indexPath];
    }
}

@end
