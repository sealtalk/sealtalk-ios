//
//  RCDBaseSettingTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/8/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDBaseSettingTableViewCell.h"
#import "UIColor+RCColor.h"
#import "UIImageView+WebCache.h"

@interface RCDBaseSettingTableViewCell ()

@property(nonatomic, strong) NSDictionary *cellSubViews;

//@property(nonatomic, strong) NSArray *leftLabelConstraints;

@property(nonatomic, strong) NSArray *rightLabelConstraints;

@end

@implementation RCDBaseSettingTableViewCell
@synthesize baseSettingTableViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithLeftImageStr:(NSString *)leftImageStr
             leftImageSize:(CGSize)leftImageSize
              rightImaeStr:(NSString *)rightImageStr
            rightImageSize:(CGSize)rightImageSize {
    self = [super init];
    if (self) {
        if (leftImageStr != nil) {
            self.leftImageView = [[UIImageView alloc] init];
            self.leftImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.leftImageView.clipsToBounds = YES;
            [self setImageView:self.leftImageView ImageStr:leftImageStr imageSize:leftImageSize LeftOrRight:0];
        }
        if (rightImageStr != nil) {
            self.rightImageView = [[UIImageView alloc] init];
            self.rightImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.rightImageView.clipsToBounds = YES;
            [self setImageView:self.rightImageView ImageStr:rightImageStr imageSize:rightImageSize LeftOrRight:1];
        }
    }
    return self;
}

- (void)initialize {
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.font = [UIFont systemFontOfSize:16.f];
    self.leftLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.font = [UIFont systemFontOfSize:14.f];
    self.rightLabel.textColor = [UIColor colorWithHexString:@"999999" alpha:1.0];
    self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;

    self.rightArrow = [[UIImageView alloc] init];
    self.rightArrow.image = [UIImage imageNamed:@"right_arrow"];
    self.rightArrow.translatesAutoresizingMaskIntoConstraints = NO;

    self.switchButton = [[UISwitch alloc] init];
    [self.switchButton addTarget:self action:@selector(onClickSwitch:) forControlEvents:UIControlEventValueChanged];
    self.switchButton.on = self.switchButtonStatus;
    self.switchButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0];
    self.bottomLine.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.rightLabel];
    [self.contentView addSubview:self.rightArrow];
    [self.contentView addSubview:self.switchButton];
    [self.contentView addSubview:self.bottomLine];

    self.cellSubViews =
        NSDictionaryOfVariableBindings(_leftLabel, _rightLabel, _rightArrow, _switchButton, _bottomLine);
    [self setLayout];
}

- (void)setLayout {
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftLabel(21)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_leftLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightLabel(21)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rightLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightArrow(13)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_rightArrow
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomLine]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomLine(0.5)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_switchButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
}

//设置cell的style
- (void)setCellStyle:(RCDBaseSettingCellStyle)style {
    NSString *constraints;
    switch (style) {
    case DefaultStyle: {
        self.rightLabel.hidden = YES;
        self.switchButton.hidden = YES;
        constraints = @"H:|-10-[_leftLabel]-(>=10)-[_rightArrow(8)]-10-|";
    } break;

    case DefaultStyle_RightLabel_WithoutRightArrow: {
        self.rightArrow.hidden = YES;
        self.switchButton.hidden = YES;
        constraints = @"H:|-10-[_leftLabel]-(>=10)-[_rightLabel]-10-|";
    } break;

    case DefaultStyle_RightLabel: {
        self.switchButton.hidden = YES;
        constraints = @"H:|-10-[_leftLabel]-(>=10)-[_rightLabel]-13-[_rightArrow(8)]-10-|";
    } break;

    case OnlyDisplayLeftLabelStyle: {
        self.rightLabel.hidden = YES;
        self.rightArrow.hidden = YES;
        self.switchButton.hidden = YES;
        constraints = @"H:|-10-[_leftLabel]-10-|";
    } break;

    case SwitchStyle: {
        self.rightLabel.hidden = YES;
        self.rightArrow.hidden = YES;
        self.switchButton.hidden = NO;
        constraints = @"H:|-10-[_leftLabel]-(>=10)-[_switchButton]-10-|";
    } break;
    default:
        break;
    }
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints
                                                                             options:0
                                                                             metrics:nil
                                                                               views:self.cellSubViews]];
}

- (void)onClickSwitch:(id)sender {
    if ([baseSettingTableViewDelegate respondsToSelector:@selector(onClickSwitchButton:)]) {
        [baseSettingTableViewDelegate onClickSwitchButton:sender];
    }
}

- (void)setSwitchButtonStatus:(BOOL)switchButtonStatus {
    self.switchButton.on = switchButtonStatus;
    self.switchButtonStatus = switchButtonStatus;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImageView:(UIImageView *)imageView
            ImageStr:(NSString *)imageStr
           imageSize:(CGSize)imageSize
         LeftOrRight:(NSInteger)LeftOrRight {
    self.switchButton.hidden = YES;
    if (imageView == nil) {
        imageView = [[UIImageView alloc] init];
    }
    if (imageStr != nil) {
        if ([imageStr hasPrefix:@"http"] || [imageStr hasPrefix:@"file:"]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil];
        } else {
            imageView.image = [UIImage imageNamed:imageStr];
        }
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:imageView];
        self.cellSubViews =
            NSDictionaryOfVariableBindings(_leftLabel, _rightLabel, _rightArrow, _switchButton, imageView);

        if (LeftOrRight == 0) {
            if (self.leftLabelConstraints != nil) {
                [self.contentView removeConstraints:self.leftLabelConstraints];
            }
            self.leftImageView = imageView;
            self.leftLabelConstraints = [NSLayoutConstraint
                constraintsWithVisualFormat:@"H:|-10-[imageView(width)]-8-[_leftLabel]-10-[_rightArrow(8)]-10-|"
                                    options:0
                                    metrics:@{
                                        @"width" : @(imageSize.width)
                                    }
                                      views:self.cellSubViews];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
                                                                                     options:0
                                                                                     metrics:@{
                                                                                         @"height" : @(imageSize.height)
                                                                                     }
                                                                                       views:self.cellSubViews]];

            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0]];

            [self.contentView addConstraints:self.leftLabelConstraints];
        }
        if (LeftOrRight == 1) {
            if (self.rightLabelConstraints != nil) {
                [self.contentView removeConstraints:self.rightLabelConstraints];
            }
            self.rightImageView = imageView;
            self.rightLabelConstraints = [NSLayoutConstraint
                constraintsWithVisualFormat:@"H:|-10-[_leftLabel]-(>=10)-[imageView(width)]-13-[_rightArrow(8)]-10-|"
                                    options:0
                                    metrics:@{
                                        @"width" : @(imageSize.width)
                                    }
                                      views:self.cellSubViews];
            [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
                                                                                     options:0
                                                                                     metrics:@{
                                                                                         @"height" : @(imageSize.height)
                                                                                     }
                                                                                       views:self.cellSubViews]];

            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:0]];
            [self.contentView addConstraints:self.rightLabelConstraints];
        }
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }
}

- (void)setLeftImageCornerRadius:(CGFloat)leftImageCornerRadius {
    self.leftImageView.layer.masksToBounds = YES;
    self.leftImageView.layer.cornerRadius = leftImageCornerRadius;
}

- (void)setRightImageCornerRadius:(CGFloat)rightImageCornerRadius {
    self.rightImageView.layer.masksToBounds = YES;
    self.rightImageView.layer.cornerRadius = rightImageCornerRadius;
}

@end
