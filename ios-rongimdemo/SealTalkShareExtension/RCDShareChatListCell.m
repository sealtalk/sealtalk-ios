//
//  RCDShareChatListCell.m
//  RCloudMessage
//
//  Created by 张改红 on 16/8/4.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDShareChatListCell.h"
#import "DefaultPortraitView.h"

@interface RCDShareChatListCell ()
@property(nonatomic, strong) UIImageView *selectImageView;
@end

@implementation RCDShareChatListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.headerImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height / 2 - 30 / 2, 30, 30)];
    self.headerImageView.layer.cornerRadius = 4;
    self.headerImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.headerImageView];

    self.nameLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headerImageView.frame) + 5,
                                                  self.contentView.frame.size.height / 2 - 20 / 2, 120, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.nameLabel];

    self.selectImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 52,
                                                      (self.contentView.frame.size.height - 10) / 2, 13, 10)];
    self.selectImageView.image = [UIImage imageNamed:@"check"];
    [self.contentView addSubview:self.selectImageView];
}

- (void)setDataDic:(NSDictionary *)dataDic {
    if (dataDic) {
        //    NSURL *url = [NSURL URLWithString:dataDic[@"portraitUri"]];
        //    NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image;
        if (1) { // todo
            DefaultPortraitView *portraitView = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [portraitView setColorAndLabel:dataDic[@"targetId"] Nickname:dataDic[@"name"]];
            image = [portraitView imageFromView];
        }
        self.headerImageView.image = image;
        NSString *str = dataDic[@"name"];
        if (!str) {
            str = dataDic[@"targetId"];
        }
        self.nameLabel.text = str;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.selectImageView.hidden = NO;
    } else {
        self.selectImageView.hidden = YES;
    }
}

@end
