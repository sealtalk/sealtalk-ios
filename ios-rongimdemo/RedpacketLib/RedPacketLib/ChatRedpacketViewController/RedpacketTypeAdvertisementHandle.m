//
//  RedpacketTypeAdvertisementHandle.m
//  RedpacketLib
//
//  Created by 都基鹏 on 16/9/12.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RedpacketTypeAdvertisementHandle.h"
#import "RPAdvertisementDetailModel.h"
@implementation RedpacketTypeAdvertisementHandle

- (void)getRedpacketDetail {
    [super getRedpacketDetail];
    
    rpWeakSelf;
    NSError * error;
    RPAdvertisementDetailModel * model = [RPAdvertisementDetailModel modelWithDictionary:self.redpacketDetailDic[@"Info"] error:&error];
    if (model && !error) {
        weakSelf.messageModel.redpacketType = RedpacketTypeAdvertisement;
        [self showRedPacketDetailViewController:weakSelf.messageModel arguments:model];
        [[RedpacketDataRequester alloc]analysisADDataWithADName:@"rp.hb.ad.open_hb" andADID:model.rpID];
    }

}

@end
