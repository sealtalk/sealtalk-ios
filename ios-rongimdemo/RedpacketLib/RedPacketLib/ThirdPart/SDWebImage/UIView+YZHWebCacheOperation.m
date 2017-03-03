/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+YZHWebCacheOperation.h"
#import "objc/runtime.h"

static char rp_loadOperationKey;

@implementation UIView (YZHWebCacheOperation)

- (NSMutableDictionary *)operationDictionary {
    NSMutableDictionary *operations = objc_getAssociatedObject(self, &rp_loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &rp_loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)rp_setImageLoadOperation:(id)operation forKey:(NSString *)key {
    [self rp_cancelImageLoadOperationWithKey:key];
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary setObject:operation forKey:key];
}

- (void)rp_cancelImageLoadOperationWithKey:(NSString *)key {
    // Cancel in progress downloader from queue
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <YZHSDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(YZHSDWebImageOperation)]){
            [(id<YZHSDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)rp_removeImageLoadOperationWithKey:(NSString *)key {
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary removeObjectForKey:key];
}

@end
