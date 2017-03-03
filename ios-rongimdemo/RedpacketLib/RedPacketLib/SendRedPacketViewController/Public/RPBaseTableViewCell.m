//
//  YXPBaseTableViewCell.m
//  YXPFordTransaction
//
//  Created by 都基鹏 on 16/5/12.
//  Copyright © 2016年 优信拍（北京）信息科技有限公司. All rights reserved.
//

#import "RPBaseTableViewCell.h"

@implementation RPBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)tableViewCellCustomAction
{
    
}

@end
