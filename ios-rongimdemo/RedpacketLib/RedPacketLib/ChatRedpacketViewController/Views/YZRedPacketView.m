//
//  RedPacketView.m
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/2/27.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "YZRedPacketView.h"
#import "RPRedpacketTool.h"
#import "RedPacketToView.h"
#import "NSBundle+RedpacketBundle.h"

@interface YZRedPacketView()

@property (nonatomic, assign)   IBOutlet UIImageView *backImageView;
@property (nonatomic, assign)   IBOutlet UIButton *closeButton;
@property (nonatomic, assign)   IBOutlet UIButton *luckButton;
@property (nonatomic, assign)   IBOutlet UIButton *doLuckButton;
@property (nonatomic, assign)   IBOutlet UILabel *nameLabel;
@property (nonatomic, assign)   IBOutlet UILabel *promptingLabel;
@property (weak, nonatomic)     IBOutlet UILabel *type;

@end

@implementation YZRedPacketView
- (instancetype)initWithRedpacketBoxStatusType:(RedpacketBoxStatusType)boxStatusType{
    
    NSBundle *nibBundle = [NSBundle RedpacketBundle];

    switch (boxStatusType) {
        case RedpacketBoxStatusTypeAvgRobbed:
        case RedpacketBoxStatusTypeRandRobbing:
        case RedpacketBoxStatusTypeRobbing:
        case RedpacketBoxStatusTypePoint:
        case RedpacketBoxStatusTypeAvgRobbing:
        case RedpacketBoxStatusTypeOverdue: {
            self = [[nibBundle loadNibNamed:NSStringFromClass([YZRedPacketView class]) owner:self options:nil] lastObject];
            break;
        }
        case RedpacketBoxStatusTypeMember: {
            self = [[RedPacketToView alloc]init];
            break;
        }
        default:{
            self = [[RedPacketToView alloc]init];
            break;
        }
    }
    
    if (self) {
        self.boxStatusType = boxStatusType;
    }
    return self;
}
- (void)setMessageModel:(RedpacketMessageModel *)messageModel
{
    if (_messageModel != messageModel) {
        _messageModel = messageModel;
        [self configWithModel:messageModel];
    }
}

- (void)configWithModel:(RedpacketMessageModel *)messageModel
{
    NSURL *headerUrl = [NSURL URLWithString:messageModel.redpacketSender.userAvatar];
    [self.headerImageView rp_setImageWithURL:headerUrl placeholderImage:rpRedpacketBundleImage(@"redpacket_header")];
    self.headerImageView.backgroundColor = [RedpacketColorStore rp_headBackGroundColor];
    self.nameLabel.text = [self nameStringWith:messageModel.redpacketSender.userNickname];
}

- (void)setBoxStatusType:(RedpacketBoxStatusType)boxStatusType
{
    _boxStatusType = boxStatusType;
    
    //非拆红包状态界面
    _promptingLabel.text = @"";
    _promptingLabel.numberOfLines = 2;
    _type.text = @"";
    
    if (_boxStatusType == RedpacketBoxStatusTypeOverdue) {
        _luckButton.hidden = YES;
        _doLuckButton.hidden = YES;
        _promptingLabel.text = @"超过一天未领取，红包已经失效";
        
    }else if (_boxStatusType == RedpacketBoxStatusTypeAvgRobbing){
        _luckButton.hidden = YES;
        _doLuckButton.hidden = YES;
        _promptingLabel.text = @"手慢了，红包派完了";
        
    }else if (_boxStatusType == RedpacketBoxStatusTypeAvgRobbed){
        _luckButton.hidden = YES;
        _doLuckButton.hidden = YES;
        _promptingLabel.text = @"红包派发完毕";
        
    }else if (_boxStatusType == RedpacketBoxStatusTypeRandRobbing){
        _luckButton.hidden = NO;
        _doLuckButton.hidden = YES;
        _promptingLabel.text = @"手慢了，红包派完了";
        
    }else{
        // 拆红包界面
        NSString *greeting = _messageModel.redpacket.redpacketGreeting;
        if (greeting.length > 22) {
            greeting = [greeting substringToIndex:22];
        }
        self.promptingLabel.text = greeting;
        _doLuckButton.hidden = NO;
        _luckButton.hidden = YES;
        
        if (_messageModel.redpacketType == RedpacketTypeSingle) {
            self.type.text = @"给你发了一个红包";
            
        }else if (_messageModel.redpacketType == RedpacketTypeRand || _messageModel.redpacketType == RedpacketTypeRandpri){
            if (_messageModel.isRedacketSender) {
                _luckButton.hidden = NO;
            }
            _type.text = @"发了一个红包，金额随机";
            
        }else if (_messageModel.redpacketType == RedpacketTypeAvg){
            self.type.text = @"给你发了一个红包";
        }
        
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.closeButton setImage:rpRedpacketBundleImage(@"payView_close_high") forState:UIControlStateNormal];
    [self.headerImageView setImage:rpRedpacketBundleImage(@"redpacket_header")];
    self.headerImageView.layer.cornerRadius = 77.0f / 2.0f;
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.borderWidth = 3.0;
    self.headerImageView.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
    
    
    self.doLuckButton.layer.cornerRadius = 20.0f;
    self.doLuckButton.layer.masksToBounds = YES;
    self.doLuckButton.layer.borderWidth = 0.5;
    self.doLuckButton.layer.borderColor = [RedpacketColorStore rp_textcolorYellow].CGColor;
    [self.doLuckButton setBackgroundColor:[RedpacketColorStore rp_textcolorYellow]];
    [self.doLuckButton setTitleColor:[RedpacketColorStore rp_textColorRed] forState:UIControlStateNormal];

    
    //加载网络图片
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *urlstr = [defaults stringForKey:@"HbImageOpenURL"];
    
    if (urlstr.length >2) {
        [self.backImageView rp_setImageWithURL:[NSURL URLWithString:urlstr]
                              placeholderImage:rpRedpacketBundleImage(@"redpacket_background")];
    }
}

- (NSString *)nameStringWith:(NSString *)natureName
{
    if (natureName.length > 18) {
        return [[natureName substringToIndex:18] stringByAppendingString:@"..."];
    }
    return natureName;
}

- (IBAction)closeButtonSender:(id)sender
{
    if (_closeButtonBlock) {
        _closeButtonBlock(self);
    }
}

//  查看手气
- (IBAction)luckButtonSender:(id)sender
{
    if (_boxStatusType == RedpacketBoxStatusTypeRobbing) {
        _submitButtonBlock(RedpacketBoxStatusTypeRobbing,self);
    }else if (_boxStatusType == RedpacketBoxStatusTypeRandRobbing){
        _submitButtonBlock(RedpacketBoxStatusTypeRandRobbing,self);
    }else if (_submitButtonBlock) {
        _submitButtonBlock(RedpacketBoxStatusTypeOverdue,self);
    }
}

//  拆红包
- (IBAction)doLuckButtonSender:(id)sender
{
    if (_boxStatusType == RedpacketBoxStatusTypePoint) {
        _submitButtonBlock(RedpacketBoxStatusTypePoint,self);
    }else if (_submitButtonBlock) {
        _submitButtonBlock(RedpacketBoxStatusTypePoint,self);
    }
}

@end
