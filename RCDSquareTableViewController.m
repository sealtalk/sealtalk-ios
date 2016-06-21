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
    NSMutableArray *groupIdList;
    NSMutableArray *groupList;
    NSMutableArray *chatRoomIdList;
    NSMutableArray *chatRoomNames;
    NSMutableArray *isJoinIndex;
    NSMutableArray *groupNames;
    MBProgressHUD* hud ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [UIView new];
    
    groupNames = [NSMutableArray new];
    groupIdList = [NSMutableArray new];
    groupList   = [NSMutableArray new];
    chatRoomNames = [NSMutableArray new];
    chatRoomIdList = [NSMutableArray new];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *squareInfoList = [userDefaults mutableArrayValueForKey:@"SquareInfoList"];
    for (NSDictionary *info in squareInfoList) {
        NSString *type = info[@"type"];
        if ([type isEqualToString:@"group"]) {
            [groupIdList addObject:info[@"id"]];
            [groupList addObject:info];
            [groupNames addObject:info[@"name"]];
        }
        if ([type isEqualToString:@"chatroom"]) {
            [chatRoomIdList addObject:info[@"id"]];
            [chatRoomNames addObject:info[@"name"]];
        }
    }
    isJoinIndex = [NSMutableArray new];
    for (int i = 0; i < groupIdList.count; i++) {
        RCDGroupInfo *group=[[RCDataBaseManager shareInstance] getGroupByGroupId:groupIdList[i]];
        if (group != nil) {
            [isJoinIndex addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [self.tableView reloadData];
    
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        for (NSDictionary *info in result) {
            NSString *type = info[@"type"];
            if ([type isEqualToString:@"group"]) {
                [groupIdList addObject:info[@"id"]];
                [groupList addObject:info];
                [groupNames addObject:info[@"name"]];
            }
            if ([type isEqualToString:@"chatroom"]) {
                [chatRoomIdList addObject:info[@"id"]];
                [chatRoomNames addObject:info[@"name"]];
            }
        }
        //保存默认群组id和聊天室id
        [DEFAULTS setObject:groupIdList forKey:@"defaultGroupIdList"];
        [DEFAULTS setObject:chatRoomIdList forKey:@"defaultChatRoomIdList"];
        [DEFAULTS synchronize];
        [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result)
        {
            isJoinIndex = [NSMutableArray new];
            for (RCDGroupInfo *group in result) {
                NSString *groupId = group.groupId;
                for (int i = 0; i < groupIdList.count; i++)
                {
                    if ([groupIdList[i] isEqualToString:groupId]) {
                        [isJoinIndex addObject:[NSString stringWithFormat:@"%d",i]];
                    }
                }
            }
            [self.tableView reloadData];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(quitDefaultGroup:)
                                                 name:@"quitDefaultGroup" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
//    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
//    titleView.backgroundColor = [UIColor clearColor];
//    titleView.font = [UIFont boldSystemFontOfSize:19];
//    titleView.textColor = [UIColor whiteColor];
//    titleView.textAlignment = NSTextAlignmentCenter;
//    titleView.text = @"广场";
//    self.tabBarController.navigationItem.titleView = titleView;
    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
//    if (groupNames == nil || groupNames.count == 0) {
//        return;
//    }
    [RCDHTTPTOOL getSquareInfoCompletion:^(NSMutableArray *result) {
        [groupList removeAllObjects];
        for (int i = 0; i < result.count; i++) {
            NSDictionary *info = result[i];
            NSString *type = info[@"type"];
            if ([type isEqualToString:@"group"]) {
                [groupList addObject:info];
                RCDSquareTableViewCell *cell = (RCDSquareTableViewCell *)[self.tableView viewWithTag:i + 100];
                cell.GroupNumber.text = [NSString stringWithFormat:@"%@/%@",info[@"memberCount"],info[@"maxMemberCount"]];
            }
        }
    }];
    
    [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result)
     {
         isJoinIndex = [NSMutableArray new];
         for (RCDGroupInfo *group in result) {
             NSString *groupId = group.groupId;
             for (int i = 0; i < groupIdList.count; i++)
             {
                 if ([groupIdList[i] isEqualToString:groupId]) {
                     [isJoinIndex addObject:[NSString stringWithFormat:@"%d",i]];
                 }
             }
         }
         [self.tableView reloadData];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (groupNames.count == 0 ||chatRoomNames.count == 0) {
        return 0;
    }
    else
    {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    if (groupNames.count == 0 || chatRoomNames.count == 0) {
        rows = 0;
    }
    else{
        switch (section) {
            case 0:
                rows = 1;
                break;
            
            case 1:
                rows = 3;
                break;
            
            default:
                break;
        }
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (chatRoomNames.count == 0 || chatRoomNames == nil) {
            return  nil;
        }
        static NSString *CellIdentifier = @"RCDSquareChatRoomTableViewCell";
        RCDSquareChatRoomTableViewCell *cell = (RCDSquareChatRoomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.ChatRoom1Image.userInteractionEnabled = YES;
        cell.ChatRoom1Image.tag = 10;
        cell.ChatRoom1Title.text = [chatRoomNames objectAtIndex:0];
        cell.ChatRoom2Image.userInteractionEnabled = YES;
        cell.ChatRoom2Image.tag = 11;
        cell.ChatRoom2Title.text = [chatRoomNames objectAtIndex:1];
        cell.ChatRoom3Image.userInteractionEnabled = YES;
        cell.ChatRoom3Image.tag = 12;
        cell.ChatRoom3Title.text = [chatRoomNames objectAtIndex:2];
        cell.ChatRoom4Image.userInteractionEnabled = YES;
        cell.ChatRoom4Image.tag = 13;
        cell.ChatRoom4Title.text = [chatRoomNames objectAtIndex:3];

        UITapGestureRecognizer *clickCR1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoChatRoomConversation:)];
        [cell.ChatRoom1Image addGestureRecognizer:clickCR1];
        
        UITapGestureRecognizer *clickCR2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoChatRoomConversation:)];
        [cell.ChatRoom2Image addGestureRecognizer:clickCR2];
        
        UITapGestureRecognizer *clickCR3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoChatRoomConversation:)];
        [cell.ChatRoom3Image addGestureRecognizer:clickCR3];
        
        UITapGestureRecognizer *clickCR4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoChatRoomConversation:)];
        [cell.ChatRoom4Image addGestureRecognizer:clickCR4];
        
        
        // Configure the cell...
        
        return cell;
    }
    if (groupNames.count == 0 || groupNames == nil) {
        return  nil;
    }
    static NSString *CellIdentifier = @"RCDSquareTableViewCell";
    RCDSquareTableViewCell *cell = (RCDSquareTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row + 100;
//    NSArray *groupIcons = [[NSArray alloc] initWithObjects:@"group_1",@"group_2",@"group_3", nil];
    // Configure the cell...
    cell.GroupName.text = groupNames[indexPath.row];
    if (groupList.count > 0) {
        NSDictionary *groupInfo = groupList[indexPath.row];
        cell.GroupNumber.text = [NSString stringWithFormat:@"%@/%@",groupInfo[@"memberCount"],groupInfo[@"maxMemberCount"]];
        
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:groupInfo[@"id"] Nickname:groupInfo[@"name"]];
        UIImage *portrait = [defaultPortrait imageFromView];
        cell.GroupPortrait.image = portrait;
        cell.GroupPortrait.layer.masksToBounds = YES;
        cell.GroupPortrait.layer.cornerRadius = 6.f;
    }
//    cell.GroupPortrait.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",groupIcons[indexPath.row]]];
    [cell.JoinGroupBtn setBackgroundColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];
    [cell.JoinGroupBtn setTitle:@"加入" forState:UIControlStateNormal];
    [cell.JoinGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cell.JoinGroupBtn.layer.cornerRadius = 6.f;
    cell.JoinGroupBtn.hidden = YES;
    cell.JoinGroupBtn.tag = indexPath.row;
    [cell.JoinGroupBtn addTarget:self action:@selector(clickJoinGroupBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.ChatBtn setBackgroundColor:[UIColor colorWithHexString:@"F5F5F5" alpha:1.0f]];
    [cell.ChatBtn setTitle:@"聊天" forState:UIControlStateNormal];
    [cell.ChatBtn setTitleColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f] forState:UIControlStateNormal];
    cell.ChatBtn.layer.cornerRadius = 6.f;
    cell.ChatBtn.hidden = YES;
    cell.ChatBtn.tag = indexPath.row;
    [cell.ChatBtn addTarget:self action:@selector(clickGroupChatBtn:) forControlEvents:UIControlEventTouchUpInside];
    

        if (isJoinIndex != nil)
        {
//            if (isJoinIndex.count == 0) {
//                cell.ChatBtn.hidden = YES;
//                cell.JoinGroupBtn.hidden = NO;
//            }
            if (isJoinIndex.count > 0)
            {
                BOOL isJoin = NO;
                for (NSString *index in isJoinIndex) {
                    if (index.intValue == indexPath.row) {
                        isJoin = YES;
                        break;
                    }
                }
                
                if (isJoin == NO) {
                    cell.ChatBtn.hidden = YES;
                    cell.JoinGroupBtn.hidden = NO;
                } else {
                    cell.ChatBtn.hidden = NO;
                    cell.JoinGroupBtn.hidden = YES;
                    }
            }
            else
            {
                cell.ChatBtn.hidden = YES;
                cell.JoinGroupBtn.hidden = NO;
            }
        }
    else
    {
        cell.ChatBtn.hidden = YES;
        cell.JoinGroupBtn.hidden = NO;
    }
        return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 40)];
    
    UIView *littleView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 3, 20)];
    littleView.backgroundColor = [UIColor colorWithHexString:@"0195ff" alpha:1.0f];
    [sectionHeaderView addSubview:littleView];
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, 20)];
    [sectionHeaderView addSubview:Title];
    switch (section) {
        case 0:
            Title.text = @"聊天室";
            break;
            
        case 1:
            Title.text = @"群组";
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
            height = 100;
            break;
            
        case 1:
            height = 70;
            break;
            
        default:
            break;
    }
    
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

#pragma mark - 本类私有方法
-(void)quitDefaultGroup:(NSNotification *)notifycation
{
    for (int i = 0; i < groupIdList.count; i++) {
        if ([[notifycation object] isEqualToString:groupIdList[i]]) {
            RCDSquareTableViewCell *cell = (RCDSquareTableViewCell *)[self.tableView viewWithTag:i + 100];
            
            cell.JoinGroupBtn.hidden = NO;
            cell.ChatBtn.hidden = YES;
        }
    }
}

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

-(void)clickJoinGroupBtn:(id)sender
{
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"加入中...";
    [hud show:YES];
    
    NSInteger i = [sender tag];
    NSString *groupId = groupIdList[i];
    [RCDHTTPTOOL joinGroupWithGroupId:groupId
                             complete:^(BOOL result) {
                                 if (result == YES) {
                                     [groupIdList addObject:groupId];

                                     RCDSquareTableViewCell *cell = (RCDSquareTableViewCell *)[self.tableView viewWithTag:i + 100];
                                     NSDictionary *groupInfo = groupList[i];
                                     NSString *memberCount = [NSString stringWithFormat:@"%d",[groupInfo[@"memberCount"] intValue] + 1];
                                     cell.GroupNumber.text = [NSString stringWithFormat:@"%@/%@",memberCount,groupInfo[@"maxMemberCount"]];
    
                                         cell.JoinGroupBtn.hidden = YES;
                                         cell.ChatBtn.hidden = NO;
                                     //关闭HUD
                                     [hud hide:YES];
                                     [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
                                         
                                     }];

                                 }
                                 else
                                 {
                                     //关闭HUD
                                     [hud hide:YES];
                                 }
                             }];
}

-(void)clickGroupChatBtn:(id)sender
{
    NSInteger i = [sender tag];
    NSString *groupId = groupIdList[i];
    RCDChatViewController *chatVC = [[RCDChatViewController alloc] initWithConversationType:ConversationType_GROUP targetId:groupId];
    chatVC.title = groupNames[i];
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
