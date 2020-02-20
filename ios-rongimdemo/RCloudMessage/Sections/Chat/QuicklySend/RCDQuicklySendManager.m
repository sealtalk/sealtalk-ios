//
//  RCDQuicklySendManager.m
//  SealTalk
//
//  Created by 孙浩 on 2019/8/1.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDQuicklySendManager.h"
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface RCDQuicklySendManager ()

@property (nonatomic, strong) UIImage *currentImage;

@property (nonatomic, strong) NSString *currentImageURL;

@property (nonatomic, strong) RCDQuicklySendView *quicklySendView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RCDQuicklySendManager

+ (RCDQuicklySendManager *)sharedManager {
    static RCDQuicklySendManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[[self class] alloc] init];
        manager.currentImageURL = @"";
    });
    return manager;
}

- (void)showQuicklySendViewWithframe:(CGRect)frame {
    [self getRecentlyAddedPhoto:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.quicklySendView) {
                    [self hideQuicklySendView];
                }
                self.quicklySendView = [RCDQuicklySendView quicklSendViewWithFrame:frame image:image];
                UITapGestureRecognizer *tap =
                    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
                [self.quicklySendView addGestureRecognizer:tap];
                [self.quicklySendView show];
                // 30s 倒计时消失
                [self startHideTimer];
            });
        }
    }];
}

- (void)hideQuicklySendView {
    [self stopTimerIfNeed];
    if (self.quicklySendView) {
        [self.quicklySendView hide];
    }
}

- (void)tapAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(quicklySendViewDidTapImage:)]) {
        [self.delegate quicklySendViewDidTapImage:self.currentImage];
    }
}

- (void)getRecentlyAddedPhoto:(void (^)(UIImage *_Nullable image, NSDictionary *_Nullable info))resultHandler {
    // 获取相册
    PHFetchResult *collectionResult =
        [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                 subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                 options:nil];

    // 获取资源时的参数
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.wantsIncrementalChangeDetails = YES;
    options.predicate =
        [NSPredicate predicateWithFormat:@"creationDate > %@", [[NSDate date] dateByAddingTimeInterval:(-30)]];
    options.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO] ];

    if (collectionResult.count > 0) {
        PHFetchResult *fetchResult =
            [PHAsset fetchAssetsInAssetCollection:[collectionResult firstObject] options:options];
        if (fetchResult.count > 0) {
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.synchronous = YES;
            // 获取原图
            [[PHImageManager defaultManager]
                requestImageForAsset:[fetchResult firstObject]
                          targetSize:PHImageManagerMaximumSize
                         contentMode:PHImageContentModeAspectFit
                             options:requestOptions
                       resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
                           if (result) {
                               PHAsset *asset = [fetchResult firstObject];
                               if (![[asset valueForKey:@"uniformTypeIdentifier"]
                                       isEqualToString:(__bridge NSString *)kUTTypeQuickTimeMovie]) {
                                   NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                                   [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
                                   NSString *formattedDate = [dateformatter stringFromDate:asset.creationDate];
                                   if (formattedDate && ![formattedDate isEqualToString:self.currentImageURL]) {
                                       self.currentImageURL = formattedDate;
                                       self.currentImage = result;
                                       resultHandler(result, info);
                                   } else {
                                       resultHandler(nil, nil);
                                   }
                               } else {
                                   resultHandler(nil, nil);
                               }

                           } else {
                           }
                       }];
        }
        resultHandler(nil, nil);
    } else {
        resultHandler(nil, nil);
    }
}

- (void)startHideTimer {
    [self stopTimerIfNeed];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30
                                                  target:self
                                                selector:@selector(hideQuicklySendView)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)stopTimerIfNeed {
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
