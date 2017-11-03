//
//  RCDSearchMoreViewCell.m
//  RCloudMessage
//
//  Created by 张改红 on 16/9/26.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSearchMoreViewCell.h"
#import "RCDCommonDefine.h"

@implementation RCDSearchMoreViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadView];
    }

    return self;
}

- (void)loadView {
    self.searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (45 - 13) / 2, 13, 13)];
    self.searchImageView.image = [UIImage imageNamed:@"search_blue"];
    [self.contentView addSubview:self.searchImageView];

    self.moreLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchImageView.frame) + 4, (45 - 17) / 2,
                                                  self.contentView.frame.size.width - 20 - 17, 17)];
    self.moreLabel.font = [UIFont systemFontOfSize:15.0];
    self.moreLabel.textColor = HEXCOLOR(0x7ca1c9);
    [self.contentView addSubview:self.moreLabel];
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
