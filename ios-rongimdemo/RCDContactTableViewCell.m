//
//  RCDContactTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/3/16.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDContactTableViewCell.h"
#import "UIColor+RCColor.h"

@interface RCDContactTableViewCell ()

@end

@implementation RCDContactTableViewCell

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

- (void)initialize {
    _portraitView = [[UIImageView alloc] init];
    _portraitView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_portraitView];

    _nicknameLabel = [[UILabel alloc] init];
    _nicknameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_nicknameLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
    _nicknameLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    [self.contentView addSubview:_nicknameLabel];

    _userIdLabel = [[UILabel alloc] init];
    _userIdLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_userIdLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
    _userIdLabel.textColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
    [self.contentView addSubview:_userIdLabel];

    NSDictionary *views = NSDictionaryOfVariableBindings(_portraitView, _nicknameLabel, _userIdLabel);

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_portraitView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0]];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_nicknameLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portraitView(36)]"
                                                                             options:kNilOptions
                                                                             metrics:nil
                                                                               views:views]];

    NSString *isDisplayID = [[NSUserDefaults standardUserDefaults] objectForKey:@"isDisplayID"];

    if ([isDisplayID isEqualToString:@"YES"]) {
        [self.contentView addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:
                                                 @"H:|-14-[_portraitView(36)]-9-[_nicknameLabel][_userIdLabel(90)]-40-|"
                                                                 options:kNilOptions
                                                                 metrics:nil
                                                                   views:views]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_userIdLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0f
                                                                      constant:0]];
    } else {
        [self.contentView
            addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-14-[_portraitView(36)]-9-[_nicknameLabel]-40-|"
                                                   options:kNilOptions
                                                   metrics:nil
                                                     views:views]];
    }

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5" alpha:1.0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
