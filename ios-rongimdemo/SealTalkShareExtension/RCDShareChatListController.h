//
//  RCDShareChatListController.h
//  ShareExtention
//
//  Created by 张改红 on 16/8/4.
//  Copyright © 2016年 张改红. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCDShareChatListController : UITableViewController
@property(nonatomic, copy) NSString *titleString;
@property(nonatomic, copy) NSString *contentString;
@property(nonatomic, copy) NSString *imageString;
@property(nonatomic, copy) NSString *url;

- (void)enableSendMessage:(BOOL)sender;
@end
