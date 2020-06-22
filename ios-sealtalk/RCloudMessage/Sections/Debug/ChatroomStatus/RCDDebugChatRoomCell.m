//
//  RCDDebugChatRoomCell.m
//  SealTalk
//
//  Created by 孙浩 on 2019/10/17.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDDebugChatRoomCell.h"
#import <Masonry/Masonry.h>

@implementation RCDDebugChatRoomCell

- (instancetype)init {

    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {

    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.contentLabel];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.contentView).inset(10);
        make.height.mas_lessThanOrEqualTo(@10000);
    }];
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.font = [UIFont systemFontOfSize:17];
    }
    return _contentLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
