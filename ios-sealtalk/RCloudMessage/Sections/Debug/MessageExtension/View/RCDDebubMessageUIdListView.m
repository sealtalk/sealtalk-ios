//
//  RCDDebubMessageUIdList.m
//  SealTalk
//
//  Created by 张改红 on 2020/8/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDDebubMessageUIdListView.h"
@interface RCDDebubMessageUIdListView()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, assign) RCConversationType type;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) void (^selectMessageBlock)(RCMessage *message);
@end
@implementation RCDDebubMessageUIdListView
+ (void)showMessageUIdListView:(UIView *)inview conversationType:(RCConversationType)type targetId:(NSString *)targetId selectMessageBlock:(void (^)(RCMessage *message))selectMessageBlock{
    NSArray *array = [[RCIMClient sharedRCIMClient] getHistoryMessages:type targetId:targetId oldestMessageId:-1 count:10];
    CGFloat height = 300;
    if (array.count < 10) {
        height = array.count * 30 + 40;
    }
    RCDDebubMessageUIdListView *listView= [[RCDDebubMessageUIdListView alloc] initWithFrame:CGRectMake(20, 150, inview.frame.size.width-40, height) style:(UITableViewStyleGrouped)];
    listView.type = type;
    listView.targetId = targetId;
    listView.array = array;
    listView.selectMessageBlock = selectMessageBlock;
    listView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, listView.frame.size.width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    listView.tableHeaderView = label;
    label.text = @"选择 MessageUId";
    [listView reloadData];
    [inview addSubview:listView];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    RCMessage *message = self.array[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    if (message) {
        cell.textLabel.text = [NSString stringWithFormat:@"Id:%ld;;;UId:%@;;;Support_Ex:%d",message.messageId,message.messageUId,message.canIncludeExpansion];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectMessageBlock) {
        self.selectMessageBlock(self.array[indexPath.row]);
        [self removeFromSuperview];
    }
}
@end
