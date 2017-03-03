//
//  RPSendRedPacketDescribeTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/2.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketDescribeTableViewCell.h"
#import "RPRedpacketTool.h"
#import "RPSendRedPacketItem.h"
#import "RedpacketColorStore.h"
#import "PlaceHolderTextView.h"

@interface RPSendRedPacketDescribeTableViewCell()<UITextViewDelegate>

@property (nonatomic,strong)HTPlaceHolderTextView * describeTextView;
@property (nonatomic,strong)UIButton * changeDescribeTittleButton;

@end

@implementation RPSendRedPacketDescribeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.describeTextView = [HTPlaceHolderTextView new];
        self.describeTextView.placeholder = @"恭喜发财，大吉大利！";
        self.describeTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.describeTextView.font = [UIFont systemFontOfSize:15];
        self.describeTextView.delegate = self;
        self.describeTextView.textColor = [RedpacketColorStore rp_textColorBlack];
        [self.contentView addSubview:self.describeTextView];
        NSLayoutConstraint * describeTextViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.describeTextView
                                                                                           attribute:NSLayoutAttributeLeft
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.contentView
                                                                                           attribute:NSLayoutAttributeLeft
                                                                                          multiplier:1
                                                                                            constant:10];
        NSLayoutConstraint * describeTextViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.describeTextView
                                                                                           attribute:NSLayoutAttributeRight
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.contentView
                                                                                           attribute:NSLayoutAttributeRight
                                                                                          multiplier:1
                                                                                            constant:-70];
        NSLayoutConstraint * describeTextViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.describeTextView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:self.contentView
                                                                                          attribute:NSLayoutAttributeTop
                                                                                         multiplier:1
                                                                                           constant:6];
        NSLayoutConstraint * describeTextViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.describeTextView
                                                                                             attribute:NSLayoutAttributeBottom
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.contentView
                                                                                             attribute:NSLayoutAttributeBottom
                                                                                            multiplier:1
                                                                                              constant:0];
        [self.contentView addConstraints:@[describeTextViewTopConstraint,describeTextViewLeftConstraint,describeTextViewBottomConstraint,describeTextViewRightConstraint]];
        
        self.changeDescribeTittleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.changeDescribeTittleButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.changeDescribeTittleButton addTarget:self action:@selector(didTapChangeDescribeTittleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.changeDescribeTittleButton setImage:rpRedpacketBundleImage(@"redpacket_redpacketSend_luckBless") forState:UIControlStateNormal];
        [self.contentView addSubview:self.changeDescribeTittleButton];
        NSLayoutConstraint * changDescribeButtonRightConstraint = [NSLayoutConstraint constraintWithItem:self.changeDescribeTittleButton
                                                                                               attribute:NSLayoutAttributeRight
                                                                                               relatedBy:NSLayoutRelationEqual
                                                                                                  toItem:self.contentView
                                                                                               attribute:NSLayoutAttributeRight
                                                                                              multiplier:1
                                                                                                constant:-23];
        NSLayoutConstraint * changDescribeButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.changeDescribeTittleButton
                                                                                             attribute:NSLayoutAttributeTop
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.contentView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                            multiplier:1
                                                                                              constant:18];
        [self.contentView addConstraints:@[changDescribeButtonRightConstraint,changDescribeButtonTopConstraint]];
        
        UIView * leftCarveView = [UIView new];
        leftCarveView.translatesAutoresizingMaskIntoConstraints = NO;
        leftCarveView.backgroundColor = [RedpacketColorStore flashColorWithRed:239 green:239 blue:239 alpha:1];
        [self.contentView addSubview:leftCarveView];
        NSLayoutConstraint * leftCarveViewRightConstraint = [NSLayoutConstraint constraintWithItem:leftCarveView
                                                                                               attribute:NSLayoutAttributeRight
                                                                                               relatedBy:NSLayoutRelationEqual
                                                                                                  toItem:self.contentView
                                                                                               attribute:NSLayoutAttributeRight
                                                                                              multiplier:1
                                                                                                constant:-64];
        NSLayoutConstraint * leftCarveViewTopConstraint = [NSLayoutConstraint constraintWithItem:leftCarveView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.contentView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                            multiplier:1
                                                                                              constant:0];
        NSLayoutConstraint * leftCarveViewHeightConstraint = [NSLayoutConstraint constraintWithItem:leftCarveView
                                                                                       attribute:NSLayoutAttributeHeight
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:nil
                                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                                      multiplier:1
                                                                                        constant:64];
        NSLayoutConstraint * leftCarveViewWidthConstraint = [NSLayoutConstraint constraintWithItem:leftCarveView
                                                                                          attribute:NSLayoutAttributeWidth
                                                                                          relatedBy:NSLayoutRelationEqual
                                                                                             toItem:nil
                                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                                         multiplier:1
                                                                                           constant:0.5];
        [self.contentView addConstraints:@[leftCarveViewRightConstraint,leftCarveViewTopConstraint,leftCarveViewHeightConstraint,leftCarveViewWidthConstraint]];
    }
    return self;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!text.length) return YES;
    
    NSString * shouldChangeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return [self autoLimitTextViewString:shouldChangeString];;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (![self autoLimitTextViewString:textView.text]) {
        textView.text = ((RPSendRedPacketItem*)self.cellItem.rawItem).congratulateTittle;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (![self autoLimitTextViewString:textView.text]) {
        textView.text = ((RPSendRedPacketItem*)self.cellItem.rawItem).congratulateTittle;
    }
}

- (void)didTapChangeDescribeTittleButton:(UIButton*)sender {
    NSString * string = self.blessString;
    self.describeTextView.text = string;
    [self autoLimitTextViewString:string];
}

- (BOOL)autoLimitTextViewString:(NSString*)shouldChangeString {
    NSString * tempString = shouldChangeString.copy;
    while ([tempString lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 64) {
        tempString = [tempString substringToIndex:tempString.length -1];
    }
    ((RPSendRedPacketItem*)self.cellItem.rawItem).congratulateTittle = tempString;
    return (tempString.length == shouldChangeString.length);
}

- (NSString *)blessString {
    static int i = 1;
   
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *GreetingsArray = [defaults arrayForKey:@"GreetingsArray"];
    
    if (!GreetingsArray.count) {
        GreetingsArray = @[@"恭喜发财，大吉大利！",
                           @"情绪不对，红包安慰！",
                           @"打赏你哒！",
                           @"膜拜大神Orz",
                           @"约起来吧！"];
    }
    
    return GreetingsArray[(i++)%GreetingsArray.count];
}
@end
