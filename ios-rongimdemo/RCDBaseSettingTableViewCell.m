//
//  RCDBaseSettingTableViewCell.m
//  RCloudMessage
//
//  Created by Jue on 16/8/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDBaseSettingTableViewCell.h"
#import "UIColor+RCColor.h"

@interface RCDBaseSettingTableViewCell()

@property(nonatomic, strong) NSDictionary *cellSubViews;

@property(nonatomic, strong) NSArray *leftLabelConstraints;

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

-(id)initWithLeftImage:(UIImage *)leftImage
         leftImageSize:(CGSize)leftImageSize
             rightImae:(UIImage *)rightImage
        rightImageSize:(CGSize)rightImageSize {
  self = [super init];
  if (self) {
//    [self initialize];
    if (leftImage != nil) {
      self.leftImageView = [[UIImageView alloc] init];
      self.leftImageView.translatesAutoresizingMaskIntoConstraints = NO;
      self.leftImageView.image = leftImage;
      [self.contentView addSubview:self.leftImageView];
      
      self.cellSubViews = NSDictionaryOfVariableBindings(_leftLabel,_rightLabel,_rightArrow,_switchButton,_leftImageView);

      if (self.leftLabelConstraints != nil) {
        [self.contentView removeConstraints:self.leftLabelConstraints];
      }
      self.leftLabelConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-10-[_leftImageView(width)]-10-[_leftLabel]"
                                   options:0
                                   metrics:@{@"width":@(leftImageSize.width)}
                                   views:self.cellSubViews];
      [self.contentView
       addConstraints:[NSLayoutConstraint
                       constraintsWithVisualFormat:@"V:[_leftImageView(height)]"
                       options:0
                       metrics:@{@"height":@(leftImageSize.height)}
                       views:self.cellSubViews]];
      
      [self.contentView
       addConstraint:[NSLayoutConstraint constraintWithItem:_leftImageView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0]];
      
      [self.contentView addConstraints:self.leftLabelConstraints];
      
      [self setNeedsUpdateConstraints];
      [self updateConstraintsIfNeeded];
      [self layoutIfNeeded];
    }
    
    if (rightImage != nil) {
      self.rightImageView = [[UIImageView alloc] init];
      self.rightImageView.translatesAutoresizingMaskIntoConstraints = NO;
      self.rightImageView.image = rightImage;
      [self.contentView addSubview:self.rightImageView];
      
      self.cellSubViews = NSDictionaryOfVariableBindings(_leftLabel,_rightLabel,_rightArrow,_switchButton,_rightImageView);
      
      if (self.rightLabelConstraints != nil) {
        [self.contentView removeConstraints:self.rightLabelConstraints];
      }
      self.rightLabelConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:[_rightImageView(width)]-13-[_rightArrow]-10-|"
                                   options:0
                                   metrics:@{@"width":@(rightImageSize.width)}
                                   views:self.cellSubViews];
      [self.contentView
       addConstraints:[NSLayoutConstraint
                       constraintsWithVisualFormat:@"V:[_rightImageView(height)]"
                       options:0
                       metrics:@{@"height":@(rightImageSize.height)}
                       views:self.cellSubViews]];
      
      [self.contentView
       addConstraint:[NSLayoutConstraint constraintWithItem:_rightImageView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1
                                                   constant:0]];
      
      [self.contentView addConstraints:self.rightLabelConstraints];
      
      [self setNeedsUpdateConstraints];
      [self updateConstraintsIfNeeded];
      [self layoutIfNeeded];
    }
  }
  return self;
}

- (void)initialize {
  self.leftLabel = [[UILabel alloc] init];
  self.leftLabel.font = [UIFont systemFontOfSize:16.f];
  self.leftLabel.textColor = [UIColor colorWithHexString:@"000000"
                                                   alpha:1.0];
  self.leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  self.rightLabel = [[UILabel alloc] init];
  self.rightLabel.font = [UIFont systemFontOfSize:14.f];
  self.rightLabel.textColor = [UIColor colorWithHexString:@"999999"
                                                   alpha:1.0];
  self.rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
  
  self.rightArrow = [[UIImageView alloc] init];
  self.rightArrow.image = [UIImage imageNamed:@"right_arrow"];
  self.rightArrow.translatesAutoresizingMaskIntoConstraints = NO;
  
  self.switchButton = [[UISwitch alloc] init];
  [self.switchButton addTarget:self
                        action:@selector(onClickSwitch:)
              forControlEvents:UIControlEventValueChanged];
  self.switchButton.on = self.switchButtonStatus;
  self.switchButton.translatesAutoresizingMaskIntoConstraints = NO;
  
  self.bottomLine = [[UIView alloc] init];
  self.bottomLine.backgroundColor = [UIColor colorWithHexString:@"dfdfdf"
                                                          alpha:1.0];
  self.bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
  
  [self.contentView addSubview:self.leftLabel];
  [self.contentView addSubview:self.rightLabel];
  [self.contentView addSubview:self.rightArrow];
  [self.contentView addSubview:self.switchButton];
  [self.contentView addSubview:self.bottomLine];
  
  self.cellSubViews = NSDictionaryOfVariableBindings(_leftLabel, _rightLabel, _rightArrow, _switchButton, _bottomLine);
  [self setLayout];
}

- (void)setLayout {
  
  self.leftLabelConstraints = [NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-10-[_leftLabel]"
                                   options:0
                                   metrics:nil
                                   views:self.cellSubViews];
  [self.contentView addConstraints:self.leftLabelConstraints];
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"V:[_leftLabel(21)]"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  [self.contentView
   addConstraint:[NSLayoutConstraint constraintWithItem:_leftLabel
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0]];
  
  self.rightLabelConstraints = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[_rightLabel]-10-|"
                               options:0
                               metrics:nil
                               views:self.cellSubViews];
  [self.contentView addConstraints:self.rightLabelConstraints];
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"V:[_rightLabel(21)]"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  [self.contentView
   addConstraint:[NSLayoutConstraint constraintWithItem:_rightLabel
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0]];
  
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:[_rightArrow(8)]-10-|"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"V:[_rightArrow(13)]"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  [self.contentView
   addConstraint:[NSLayoutConstraint constraintWithItem:_rightArrow
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0]];
  
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:[_switchButton]-10-|"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];

  [self.contentView
   addConstraint:[NSLayoutConstraint constraintWithItem:_switchButton
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                               constant:0]];
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"V:[_bottomLine(0.5)]|"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  
  [self.contentView
   addConstraints:[NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:|-10-[_bottomLine]|"
                   options:0
                   metrics:nil
                   views:self.cellSubViews]];
  
}

//设置cell的style
- (void)setCellStyle:(RCDBaseSettingCellStyle)style {
  switch (style) {
    case DefaultStyle: {
      self.rightLabel.hidden = YES;
      self.switchButton.hidden = YES;
    }
      break;
      
    case DefaultStyle_RightLabel_WithoutRightArrow: {
      self.rightArrow.hidden = YES;
      self.switchButton.hidden = YES;
    }
      break;
      
    case DefaultStyle_RightLabel: {
      self.switchButton.hidden = YES;
      if (self.rightLabelConstraints != nil) {
        [self.contentView removeConstraints:self.rightLabelConstraints];
      }
      self.cellSubViews = NSDictionaryOfVariableBindings(_leftLabel,_rightLabel,_rightArrow,_switchButton);
      self.rightLabelConstraints = [NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:[_rightLabel]-13-[_rightArrow]-10-|"
                                    options:0
                                    metrics:nil
                                    views:self.cellSubViews];
      
      [self.contentView addConstraints:self.rightLabelConstraints];
      
      [self setNeedsUpdateConstraints];
      [self updateConstraintsIfNeeded];
      [self layoutIfNeeded];

    }
      break;
      
    case OnlyDisplayLeftLabelStyle: {
      self.rightLabel.hidden = YES;
      self.rightArrow.hidden = YES;
      self.switchButton.hidden = YES;
    }
      break;
      
    case SwitchStyle: {
    self.rightLabel.hidden = YES;
    self.rightArrow.hidden = YES;
    }
      break;
    default:
      break;
  }
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

@end
