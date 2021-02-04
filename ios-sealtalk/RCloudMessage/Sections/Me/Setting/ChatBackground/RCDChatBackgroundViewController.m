//
//  RCDChatBackgroundViewController.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/8.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDChatBackgroundViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+RCColor.h"
#import "RCDChatBackgroundCell.h"
#import "RCDChatBgDetailViewController.h"
#import "RCDCommonString.h"

#define RCDChatBackgroundCellID @"RCDChatBackgroundCellIdentifier"
@interface RCDChatBackgroundViewController () <UICollectionViewDelegate, UICollectionViewDataSource,
                                               UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *albumSelectLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UICollectionView *bgCollectionView;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *imageDetailArray;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation RCDChatBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupData];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *imageName = [DEFAULTS objectForKey:RCDChatBackgroundKey];
    self.selectIndex = imageName.length > 0 ? [self.imageDetailArray indexOfObject:imageName] : 0;
    [self.bgCollectionView reloadData];
}

#pragma mark - Private Method
- (void)setupData {
    self.dataArray = @[
        @"chat_bg_select_0",
        @"chat_bg_select_1",
        @"chat_bg_select_2",
        @"chat_bg_select_3",
        @"chat_bg_select_4",
        @"chat_bg_select_5"
    ];
    self.imageDetailArray =
        @[ @"chat_bg_select_0", @"chat_bg_1", @"chat_bg_2", @"chat_bg_3", @"chat_bg_4", @"chat_bg_5" ];
}

- (void)setupSubviews {
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.bgCollectionView];
    [self.headerView addSubview:self.albumSelectLabel];
    [self.headerView addSubview:self.arrowImageView];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(15);
        make.height.offset(44);
    }];
    [self.albumSelectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(10);
        make.centerY.height.equalTo(self.headerView);
        make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
    }];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.headerView).offset(-10);
        make.centerY.equalTo(self.headerView);
        make.width.offset(8);
        make.height.offset(13);
    }];
    [self.bgCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(15);
        make.left.right.equalTo(self.view).inset(3.5);
        make.bottom.equalTo(self.view).offset(-RCDExtraBottomHeight);
    }];
}

#pragma mark - Target Action
- (void)tapAction {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = self.imageDetailArray[indexPath.item];
    RCDChatBgDetailViewController *detailVC =
        [[RCDChatBgDetailViewController alloc] initWithChatBgDetailType:RCDChatBgDetailTypeDefault imageName:imageName];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDChatBackgroundCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:RCDChatBackgroundCellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[RCDChatBackgroundCell alloc] init];
    }

    NSString *imageName = self.dataArray[indexPath.item];
    cell.imageName = imageName;
    if (indexPath.item == self.selectIndex) {
        cell.imgHidden = NO;
    } else {
        cell.imgHidden = YES;
    }
    return cell;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication sharedApplication].statusBarHidden = NO;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqual:@"public.image"]) {
        UIImage *originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        RCDChatBgDetailViewController *detailVC =
            [[RCDChatBgDetailViewController alloc] initWithChatBgDetailType:RCDChatBgDetailTypeAlbum image:originImage];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setter && Getter
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor =
            [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                     darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_headerView addGestureRecognizer:tap];
    }
    return _headerView;
}

- (UILabel *)albumSelectLabel {
    if (!_albumSelectLabel) {
        _albumSelectLabel = [[UILabel alloc] init];
        _albumSelectLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        _albumSelectLabel.text = RCDLocalizedString(@"SelectFromAlbum");
        _albumSelectLabel.font = [UIFont systemFontOfSize:15];
    }
    return _albumSelectLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"right_arrow"];
    }
    return _arrowImageView;
}

- (UICollectionView *)bgCollectionView {
    if (!_bgCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat widthScale = RCDScreenWidth / 375;
        //        if (widthScale > 1) {
        //            widthScale = 1;
        //        }
        flowLayout.itemSize = CGSizeMake(114 * widthScale, 152 * widthScale);
        flowLayout.minimumLineSpacing = 6.5;
        CGFloat space = (RCDScreenWidth - 114 * widthScale * 3 - 7) / 4 / 2;
        flowLayout.minimumInteritemSpacing = space;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, space, 15.0, space);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

        _bgCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _bgCollectionView.backgroundColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _bgCollectionView.delegate = self;
        _bgCollectionView.dataSource = self;
        _bgCollectionView.scrollEnabled = YES;
        [_bgCollectionView registerClass:[RCDChatBackgroundCell class]
              forCellWithReuseIdentifier:RCDChatBackgroundCellID];
    }
    return _bgCollectionView;
}

@end
