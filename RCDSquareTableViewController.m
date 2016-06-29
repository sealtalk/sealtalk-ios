//
//  RCDSquareTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDSquareTableViewController.h"
#import "RCDSquareChatRoomTableViewCell.h"
#import "RCDSquareTableViewCell.h"
#import "UIColor+RCColor.h"
#import "RCDHttpTool.h"
#import "RCDCommonDefine.h"
#import "RCDGroupInfo.h"
#import "RCDChatViewController.h"
#import "DefaultPortraitView.h"
#import "MBProgressHUD.h"
#import "RCDataBaseManager.h"

@interface RCDSquareTableViewController ()

@end

@implementation RCDSquareTableViewController
{
    NSMutableArray *chatRoomIdList;
    NSMutableArray *chatRoomNames;
    MBProgressHUD* hud ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"square_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [UIView new];
    
    chatRoomNames = [NSMutableArray new];
    chatRoomIdList = [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *squareInfoList = [userDefaults mutableArrayValueForKey:@"SquareInfoList"];
    for (NSDictionary *info in squareInfoList) {
        NSString *type = info[@"type"];
        if ([type isEqualToString:@"chatroom"]) {
            [chatRoomIdList addObject:info[@"id"]];
            [chatRoomNames addObject:info[@"name"]];
        }
    }
    [self.tableView reloadData];
    
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        for (NSDictionary *info in result) {
            NSString *type = info[@"type"];
            if ([type isEqualToString:@"chatroom"]) {
                [chatRoomIdList addObject:info[@"id"]];
                [chatRoomNames addObject:info[@"name"]];
            }
        }
        //保存默认聊天室id
        [DEFAULTS setObject:chatRoomIdList forKey:@"defaultChatRoomIdList"];
        [DEFAULTS synchronize];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{

    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (chatRoomNames.count == 0) {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (chatRoomNames.count == 0) {
        rows = 0;
    }
    else{
        switch (section) {
            case 0:
                rows = chatRoomNames.count;
                break;
            
            default:
                break;
        }
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        if (chatRoomNames.count == 0 || chatRoomNames == nil) {
            return  nil;
        }
    static NSString *CellIdentifier = @"RCDSquareTableViewCell";
    RCDSquareTableViewCell *cell = (RCDSquareTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSArray *chatroomIcons = [[NSArray alloc] initWithObjects:@"icon_1-1",@"icon_2-1",@"icon_3-1",@"icon_4-1", nil];
    // Configure the cell...
    cell.ChatroomName.text = chatRoomNames[indexPath.row];
   cell.ChatroomPortrait.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",chatroomIcons[indexPath.row]]];

        return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35)];
    sectionHeaderView.backgroundColor = HEXCOLOR(0xf0f0f6);
    sectionHeaderView.layer.borderColor = [HEXCOLOR(0xdfdfdd) CGColor];
    sectionHeaderView.layer.borderWidth = 0.5;
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    [Title setTextColor:HEXCOLOR(0x000000)];
    [Title setFont:[UIFont systemFontOfSize:16.f]];
    
    [sectionHeaderView addSubview:Title];
    switch (section) {
        case 0:
            Title.text = @"聊天室";
            break;
            
        default:
            break;
    }
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    switch (indexPath.section) {
        case 0:
            height = 68;
            break;
            
        default:
            break;
    }
    
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *chatroomId;
    chatroomId = chatRoomIdList[indexPath.row];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:chatroomId];
    chatVC.title = chatRoomNames[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - 本类私有方法

-(void)gotoChatRoomConversation:(UITapGestureRecognizer *)recognizer
{
    NSArray *chatRoomNameArr = [[NSArray alloc] initWithObjects:@"聊天室1",@"聊天室2",@"聊天室3",@"聊天室4", nil];
    if (chatRoomIdList.count == 0) {
        return;
    }
    NSString *chatroomId;
    NSInteger tag = recognizer.view.tag;
    chatroomId = chatRoomIdList[tag - 10];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_CHATROOM targetId:chatroomId];
    chatVC.title = chatRoomNameArr[tag - 10];
    [self.navigationController pushViewController:chatVC animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
