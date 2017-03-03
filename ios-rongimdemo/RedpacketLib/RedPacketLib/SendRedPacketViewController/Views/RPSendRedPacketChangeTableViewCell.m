//
//  RPSendRedPacketChangeTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//
#import "RPSendRedPacketChangeTableViewCell.h"
#import "RPSendRedPacketItem.h"
#import "RPSendRedPacketItem.h"
#import "RedpacketColorStore.h"
#import "RPSendRedPacketChangeCellItem.h"

NSString * const RPSendRedPacketChangeButtonNormalTitle = @"改为普通红包";
NSString * const RPSendRedPacketChangeButtonSeletedTitle = @"改为拼手气红包";
NSString * const RPSendRedPacketSubDescribeNormalTitle = @"当前为拼手气红包，";
NSString * const RPSendRedPacketSubDescribeSeletedTitle = @"当前为普通红包，";


@interface RPSendRedPacketChangeTableViewCell() <UITextFieldDelegate>
@property (nonatomic,strong)UILabel * subDescribeLable;
@property (nonatomic,strong)UITextField * inputField;
@property (nonatomic,strong)UIButton * typeButton;

@property (nonatomic,strong)UILabel * symbolLable;
@end
@implementation RPSendRedPacketChangeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.describeLable.text = @"总金额";
        self.unitsLable.text = @"元";
        
        self.symbolLable = [UILabel new];
        [self.contentView addSubview:self.symbolLable];
        self.symbolLable.font = [UIFont systemFontOfSize:11];
        self.symbolLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.symbolLable.textColor = [UIColor whiteColor];
        self.symbolLable.textAlignment = NSTextAlignmentCenter;
        NSLayoutConstraint * symbolLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.symbolLable
                                                                                      attribute:NSLayoutAttributeLeft
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.describeLable
                                                                                      attribute:NSLayoutAttributeRight
                                                                                     multiplier:1
                                                                                       constant:4];
        
        NSLayoutConstraint * symbolLableCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.symbolLable
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.describeLable
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                        multiplier:1
                                                                                          constant:0];
        NSLayoutConstraint * symbolLableWidthConstraint = [NSLayoutConstraint constraintWithItem:self.symbolLable
                                                                                            attribute:NSLayoutAttributeWidth
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:nil
                                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                                           multiplier:1
                                                                                             constant:13];
        NSLayoutConstraint * symbolLableHeightConstraint = [NSLayoutConstraint constraintWithItem:self.symbolLable
                                                                                             attribute:NSLayoutAttributeHeight
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:nil
                                                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                                                            multiplier:1
                                                                                              constant:13];
        [self.contentView addConstraints:@[symbolLableLeftConstraint,symbolLableCenterYConstraint,symbolLableWidthConstraint,symbolLableHeightConstraint]];
        
        self.subDescribeLable = [UILabel new];
        [self.contentView addSubview:self.subDescribeLable];
        self.subDescribeLable.font = [UIFont systemFontOfSize:12];
        self.subDescribeLable.translatesAutoresizingMaskIntoConstraints = NO;
        self.subDescribeLable.text = RPSendRedPacketSubDescribeNormalTitle;
        NSLayoutConstraint * subDescribeLableLeftConstraint = [NSLayoutConstraint constraintWithItem:self.subDescribeLable
                                                                                           attribute:NSLayoutAttributeLeft
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.contentView
                                                                                           attribute:NSLayoutAttributeLeft
                                                                                          multiplier:1
                                                                                            constant:15];
        
        NSLayoutConstraint * subDescribeLableCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.subDescribeLable
                                                                                              attribute:NSLayoutAttributeCenterY
                                                                                              relatedBy:NSLayoutRelationEqual
                                                                                                 toItem:self.contentView
                                                                                              attribute:NSLayoutAttributeBottom
                                                                                             multiplier:1
                                                                                               constant:-22];
        [self.contentView addConstraints:@[subDescribeLableLeftConstraint,subDescribeLableCenterYConstraint]];
        
        self.typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.typeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.typeButton];
        self.typeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.typeButton setTitle:RPSendRedPacketChangeButtonNormalTitle forState:UIControlStateNormal];
        [self.typeButton setTitle:RPSendRedPacketChangeButtonSeletedTitle forState:UIControlStateSelected];
        [self.typeButton setTitleColor:[RedpacketColorStore rp_textColorBlue] forState:UIControlStateNormal];
        [self.typeButton addTarget:self action:@selector(didChangeType:) forControlEvents:UIControlEventTouchUpInside];
        NSLayoutConstraint * typeButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:self.typeButton
                                                                                           attribute:NSLayoutAttributeLeft
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.subDescribeLable
                                                                                           attribute:NSLayoutAttributeRight
                                                                                          multiplier:1
                                                                                            constant:0];
        
        NSLayoutConstraint * typeButtonCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.typeButton
                                                                                              attribute:NSLayoutAttributeCenterY
                                                                                              relatedBy:NSLayoutRelationEqual
                                                                                                 toItem:self.subDescribeLable
                                                                                              attribute:NSLayoutAttributeCenterY
                                                                                             multiplier:1
                                                                                               constant:0];
        [self.contentView addConstraints:@[typeButtonLeftConstraint,typeButtonCenterYConstraint]];
        
        
        self.inputField = [UITextField new];
        self.inputField.borderStyle = UITextBorderStyleNone;
        self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
        self.inputField.keyboardType = UIKeyboardTypeDecimalPad;
        self.inputField.textAlignment = NSTextAlignmentRight;
        self.inputField.textColor = [RedpacketColorStore rp_textColorBlack];
        self.inputField.font = [UIFont systemFontOfSize:15];
        self.inputField.delegate = self;
        [self.contentView addSubview:self.inputField];
        self.inputField.placeholder = @"填写金额";
        
        NSLayoutConstraint * inputFieldCenterConstraint = [NSLayoutConstraint constraintWithItem:self.inputField
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.describeLable
                                                                                       attribute:NSLayoutAttributeCenterY
                                                                                      multiplier:1
                                                                                        constant:0];
        NSLayoutConstraint * inputFieldRightConstraint = [NSLayoutConstraint constraintWithItem:self.inputField
                                                                                      attribute:NSLayoutAttributeRight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.unitsLable
                                                                                      attribute:NSLayoutAttributeLeft
                                                                                     multiplier:1
                                                                                       constant:-5];
        NSLayoutConstraint * inputFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:self.inputField
                                                                                      attribute:NSLayoutAttributeWidth
                                                                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1
                                                                                       constant:260];
        [self.contentView addConstraints:@[inputFieldCenterConstraint,inputFieldRightConstraint,inputFieldWidthConstraint]];
                
    }
    return self;
}

- (CGFloat)spaceViewHeight{
    return ((RPSendRedPacketChangeCellItem*)self.cellItem).spaceViewHeight;
}
- (void)setCellItem:(RPBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    NSAssert([self.cellItem.rawItem isKindOfClass:[RPSendRedPacketItem class]], @"source type error");
    
    self.subDescribeLable.textColor = [RedpacketColorStore rp_textColorBlack];
    RPSendRedPacketItem * item = (RPSendRedPacketItem*)self.cellItem.rawItem;
    self.symbolLable.text = @"拼";
    
    switch (item.redPacketType) {
        case RedpacketTypeSingle: {
            self.typeButton.hidden = YES;
            self.subDescribeLable.hidden = YES;
            self.describeLable.text = @"金额";
            self.symbolLable.hidden = YES;
            break;
        }
        case RedpacketTypeRand: {
            self.typeButton.hidden = NO;
            self.subDescribeLable.hidden = NO;
            self.symbolLable.hidden = NO;
            self.subDescribeLable.text = RPSendRedPacketSubDescribeNormalTitle;
            self.describeLable.text = @"总金额";
            self.symbolLable.backgroundColor = [RedpacketColorStore flashColorWithRed:250 green:188 blue:61 alpha:1];
            break;
        }
        case RedpacketTypeAvg: {
            self.typeButton.hidden = NO;
            self.subDescribeLable.hidden = NO;
            self.describeLable.text = @"单个金额";
            self.symbolLable.hidden = YES;
            self.subDescribeLable.text = RPSendRedPacketSubDescribeSeletedTitle;
            break;
        }
        case RedpacketTypeMember: {
            if (item.memberList.count) {
                self.typeButton.hidden = YES;
                self.subDescribeLable.hidden = NO;
                self.symbolLable.hidden = NO;
                self.subDescribeLable.text = @"当前为专属红包";
                self.subDescribeLable.textColor = [RedpacketColorStore rp_textColorGray];
                self.describeLable.text = @"总金额";
                self.symbolLable.text = @"专";
                self.symbolLable.backgroundColor = [RedpacketColorStore rp_colorWithHEX:0xf57c56];
            }
            break;
        }
        default:
            break;
    }
    [self checkoutInputNumberWithString:self.inputField.text];
}

- (void)tableViewCellCustomAction {
    RPSendRedPacketItem * item = (RPSendRedPacketItem*)self.cellItem.rawItem;
    [self setCellItem:self.cellItem];
    if ([@(item.inputMoney.floatValue/100.0f) compare:item.minTotalMoney] == NSOrderedAscending && self.inputField.text.length) {
        self.inputField.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
        self.describeLable.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
    } else {
        self.inputField.textColor = [RedpacketColorStore rp_textColorBlack];
        self.describeLable.textColor = [RedpacketColorStore rp_textColorBlack];
    }
    
    if ([self.RPCellDelagete respondsToSelector:@selector(didChangePacketInputMoney)]) {
        [self.RPCellDelagete didChangePacketInputMoney];
    }
}

- (void)didChangeType:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    RPSendRedPacketItem * rawItem = ((RPSendRedPacketItem*)self.cellItem.rawItem);
    [rawItem alterRedpacketPlayType];
    self.inputField.text = ([rawItem.inputMoney compare:@(0)] == NSOrderedDescending)?[NSString stringWithFormat:@"%.2f",rawItem.inputMoney.floatValue/100.0f]:@"";
    
    if ([self.RPCellDelagete respondsToSelector:@selector(didChangePacketPlayType)]) {
        [self.RPCellDelagete didChangePacketPlayType];
    }
}

#pragma mark --
#pragma mark - textfiled delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    RPSendRedPacketItem * item = (RPSendRedPacketItem*)self.cellItem.rawItem;
    if (textField.text.length) {
        item.checkChangeWarningTitle  = YES;
    }
    [self tableViewCellCustomAction];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL returnValue = [self checkoutInputNumberWithString:text];

    if ([self.RPCellDelagete respondsToSelector:@selector(didChangePacketInputMoney)]) {
        [self.RPCellDelagete didChangePacketInputMoney];
    }
    return returnValue;
}

- (BOOL)checkoutInputNumberWithString:(NSString*)text {
    RPSendRedPacketItem * rawItem = (RPSendRedPacketItem*)self.cellItem.rawItem;
    rawItem.checkChangeWarningTitle  = NO;
    NSNumber * decimalLimit = @(2);
    NSNumber * wholeLimit = @(9);
    NSNumber * decimalLength = @(0);
    NSNumber * wholeLength = @(0);
    RPCheckNmuberStringType checkType = [RPUntility checkNumberString:text
                                                         decimalLimit:decimalLimit
                                                           wholeLimit:wholeLimit
                                                            minNumber:rawItem.minTotalMoney
                                                            maxNumber:rawItem.maxTotalMoney
                                                        decimalLength:&decimalLength
                                                          wholeLength:&wholeLength];
    switch (checkType) {
        case RPNmuberStringInputError:
        case RPNmuberStringDecimalError:
        case RPNmuberStringWholeLimitError:
        case RPNmuberStringDecimalLimitError: {
            return NO;
            break;
        }
        case RPNmuberStringSuccess:{
            self.inputField.textColor = [RedpacketColorStore rp_textColorBlack];
            self.describeLable.textColor = [RedpacketColorStore rp_textColorBlack];
            break;
        }
        case RPNmuberStringMaxNumberError:{
            self.inputField.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
            self.describeLable.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
            break;
        }
        case RPNmuberStringMinNumberError:{
            if ([decimalLength compare:decimalLimit] == NSOrderedSame) {
                rawItem.checkChangeWarningTitle  = YES;
                self.inputField.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
                self.describeLable.textColor = [UIColor colorWithRed:161/255.0 green:23/255.0 blue:16/255.0 alpha:1.0];
            }else{
                self.inputField.textColor = [RedpacketColorStore rp_textColorBlack];
                self.describeLable.textColor = [RedpacketColorStore rp_textColorBlack];
            }
            break;
        }
    }
    
    NSDecimalNumber * inputMoney = [NSDecimalNumber decimalNumberWithString:(text.length?text:@"0")];
    rawItem.inputMoney = [inputMoney decimalNumberByMultiplyingByPowerOf10:2];
    if ([self.RPCellDelagete respondsToSelector:@selector(didChangePacketInputMoney)]) {
        [self.RPCellDelagete didChangePacketInputMoney];
    }
    
    return YES;
}
@end
