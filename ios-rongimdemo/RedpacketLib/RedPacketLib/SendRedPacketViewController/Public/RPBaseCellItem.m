//
//  YXPCellItem.m
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import "RPBaseCellItem.h"
#import "RPBaseTableViewCell.h"
@implementation RPBaseCellItem
- (Class)cellClass{
    return [RPBaseTableViewCell class];
}
- (UINib *)nib{
    return nil;
}
- (NSString *)cellReuseIdentifier{
    if (self.nib) {
        return NSStringFromClass(self.class);
    }
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass(self.class),NSStringFromClass(self.cellClass)];
}
- (UITableViewCellStyle)cellStyle{
    return UITableViewCellStyleDefault;
}
- (UITableViewCellSelectionStyle)cellSelectionStyle{
    return UITableViewCellSelectionStyleGray;
}
- (CGFloat)cellHeight{
    return 40.0f;
}
- (BOOL)deselect{
    return YES;
}

@end
