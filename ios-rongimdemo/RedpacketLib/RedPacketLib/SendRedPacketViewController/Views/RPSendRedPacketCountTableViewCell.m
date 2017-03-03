//
//  RPSendRedPacketChangeTableViewCell.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/8/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPSendRedPacketCountTableViewCell.h"
#import "RPSendRedPacketItem.h"
#import "RedpacketColorStore.h"
#import "RPLayout.h"

@interface RPSendRedPacketCountTableViewCell()<UITextFieldDelegate>
@property (nonatomic,strong)UILabel * countLable;
@property (nonatomic,strong)UITextField * inputField;
@end
@implementation RPSendRedPacketCountTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.describeLable.text = @"红包个数";
        self.unitsLable.text = @"个";
        
        self.countLable = [UILabel new];
        [self.contentView addSubview:self.countLable];
        self.countLable.font = [UIFont systemFontOfSize:11];
        self.countLable.textColor = [RedpacketColorStore flashColorWithRed:158 green:158 blue:158 alpha:1];
        self.countLable.translatesAutoresizingMaskIntoConstraints = NO;
        [self.countLable rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(self.contentView.rpm_bottom).offset(-14);
        }];
        
        self.inputField = [UITextField new];
        self.inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.inputField.translatesAutoresizingMaskIntoConstraints = NO;
        self.inputField.delegate = self;
        [self.contentView addSubview:self.inputField];
        self.inputField.textAlignment = NSTextAlignmentRight;
        self.inputField.placeholder = @"填写个数";
        self.inputField.keyboardType = UIKeyboardTypeNumberPad;
        self.inputField.textColor = [RedpacketColorStore rp_textColorBlack];
        self.inputField.font = [UIFont systemFontOfSize:15];
        [self.inputField rpm_makeConstraints:^(RPConstraintMaker *make) {
            make.centerY.equalTo(self.describeLable);
            make.right.equalTo(self.unitsLable.rpm_left).offset(-5);
            make.width.offset(200);
        }];
    }
    return self;
}
- (CGFloat)spaceViewHeight{
    return 26;
}
- (void)setCellItem:(RPBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    NSAssert([self.cellItem.rawItem isKindOfClass:[RPSendRedPacketItem class]], @"source type error");
    RPSendRedPacketItem * item = ((RPSendRedPacketItem*)self.cellItem.rawItem);
    
    NSMutableString * countLableText = [NSMutableString stringWithFormat:@"本群共%@人",@(item.memberCount)];
    switch (item.redPacketType) {
        case RedpacketTypeMember:
            [countLableText appendFormat:@"，当前已指定%@人领取",@(item.memberList.count)];
            break;
        default:
            break;
    }

    self.countLable.text = countLableText;
    self.countLable.hidden = !(item.memberCount > 0);
    
    if (item.redPacketType == RedpacketTypeMember && item.memberList.count){
        self.inputField.text = [NSString stringWithFormat:@"%@",@(item.memberList.count)];
        self.inputField.userInteractionEnabled = NO;
    }else{
        self.inputField.userInteractionEnabled = YES;
        self.inputField.text = item.packetCount > 0 ? [NSString stringWithFormat:@"%@",item.packetCount]:@"";
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSAssert([self.cellItem.rawItem isKindOfClass:[RPSendRedPacketItem class]], @"source type error");
    RPSendRedPacketItem * item = ((RPSendRedPacketItem*)self.cellItem.rawItem);
    if (item.redPacketType == RedpacketTypeMember) return NO;
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    RPCheckNmuberStringType checkType = [RPUntility checkNumberString:text
                                                         decimalLimit:@(0)
                                                           wholeLimit:@(9)
                                                            minNumber:@(CGFLOAT_MIN)
                                                            maxNumber:@(CGFLOAT_MAX)
                                                        decimalLength:nil
                                                          wholeLength:nil];
    switch (checkType) {
        case RPNmuberStringInputError:
        case RPNmuberStringDecimalError:
        case RPNmuberStringWholeLimitError:
        case RPNmuberStringDecimalLimitError: {
            return NO;
            break;
        }
        case RPNmuberStringSuccess:
        case RPNmuberStringMaxNumberError:
        case RPNmuberStringMinNumberError:{
            break;
        }
    }
    ((RPSendRedPacketItem*)self.cellItem.rawItem).packetCount = [NSDecimalNumber decimalNumberWithString:text.length?text:@"0"];
    if ([self.RPCellDelagete respondsToSelector:@selector(didChangePacketCount)]) {
        [self.RPCellDelagete didChangePacketCount];
    }
    return YES;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        
        return self.inputField;
    }
    return nil;
}
@end
