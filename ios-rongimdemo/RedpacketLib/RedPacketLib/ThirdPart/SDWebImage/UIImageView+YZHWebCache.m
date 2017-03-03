/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+YZHWebCache.h"
#import "objc/runtime.h"
#import "UIView+YZHWebCacheOperation.h"

static char rp_imageURLKey;
static char RP_TAG_ACTIVITY_INDICATOR;
static char RP_TAG_ACTIVITY_STYLE;
static char RP_TAG_ACTIVITY_SHOW;

@implementation UIImageView (YZHWebCache)

- (void)rp_setImageWithURL:(NSURL *)url {
    [self rp_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)rp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self rp_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)rp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YZHSDWebImageOptions)options {
    [self rp_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)rp_setImageWithURL:(NSURL *)url completed:(YZHSDWebImageCompletionBlock)completedBlock {
    [self rp_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)rp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(YZHSDWebImageCompletionBlock)completedBlock {
    [self rp_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)rp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YZHSDWebImageOptions)options completed:(YZHSDWebImageCompletionBlock)completedBlock {
    [self rp_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)rp_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YZHSDWebImageOptions)options progress:(YZHSDWebImageDownloaderProgressBlock)progressBlock completed:(YZHSDWebImageCompletionBlock)completedBlock {
    [self rp_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &rp_imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {

        // check if activityView is enabled or not
        if ([self rp_showActivityIndicatorView]) {
            [self rp_addActivityIndicator];
        }

        __weak __typeof(self)wself = self;
        id <YZHSDWebImageOperation> operation = [YZHSDWebImageManager.sharedManager downloadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, YZHSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself rp_removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & SDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & SDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self rp_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self rp_removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:YZHSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)rp_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(YZHSDWebImageOptions)options progress:(YZHSDWebImageDownloaderProgressBlock)progressBlock completed:(YZHSDWebImageCompletionBlock)completedBlock {
    NSString *key = [[YZHSDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[YZHSDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self rp_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options progress:progressBlock completed:completedBlock];    
}

- (NSURL *)rp_imageURL {
    return objc_getAssociatedObject(self, &rp_imageURLKey);
}

- (void)rp_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self rp_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self)wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <YZHSDWebImageOperation> operation = [YZHSDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, YZHSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self rp_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)rp_cancelCurrentImageLoad {
    [self rp_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)rp_cancelCurrentAnimationImagesLoad {
    [self rp_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}


#pragma mark -
- (UIActivityIndicatorView *)rp_activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &RP_TAG_ACTIVITY_INDICATOR);
}

- (void)setRp_activityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &RP_TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)setRP_showActivityIndicatorView:(BOOL)show{
    objc_setAssociatedObject(self, &RP_TAG_ACTIVITY_SHOW, [NSNumber numberWithBool:show], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)rp_showActivityIndicatorView{
    return [objc_getAssociatedObject(self, &RP_TAG_ACTIVITY_SHOW) boolValue];
}

- (void)setRP_indicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &RP_TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)getRp_indicatorStyle{
    return [objc_getAssociatedObject(self, &RP_TAG_ACTIVITY_STYLE) intValue];
}

- (void)rp_addActivityIndicator {
    if (!self.rp_activityIndicator) {
        self.rp_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self getRp_indicatorStyle]];
        self.rp_activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

        dispatch_main_async_safe(^{
            [self addSubview:self.rp_activityIndicator];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rp_activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rp_activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        });
    }

    dispatch_main_async_safe(^{
        [self.rp_activityIndicator startAnimating];
    });

}

- (void)rp_removeActivityIndicator {
    if (self.rp_activityIndicator) {
        [self.rp_activityIndicator removeFromSuperview];
        self.rp_activityIndicator = nil;
    }
}

@end


