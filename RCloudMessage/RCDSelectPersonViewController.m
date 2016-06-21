//
//  RCDSelectPersonViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSelectPersonViewController.h"
#import "RCDSelectPersonTableViewCell.h"
#import "RCDUserInfo.h"
#import "UIImageView+WebCache.h"
#import "RCDRCIMDataSource.h"
#import "RCDChatViewController.h"

@implementation RCDSelectPersonViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"选择联系人";
    
    //控制多选
    self.tableView.allowsMultipleSelection = YES;
    
    //rightBarButtonItem click event
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickedDone:)];

}



//clicked done
-(void) clickedDone:(id) sender
{
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    if (!indexPaths||indexPaths.count == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请选择联系人!" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    //get seleted users
    NSMutableArray *seletedUsers = [NSMutableArray new];
    for (NSIndexPath *indexPath in indexPaths) {
        NSString *key = [self.allKeys objectAtIndex:indexPath.section];
        NSArray *arrayForKey = [self.allFriends objectForKey:key];
        RCDUserInfo *user = arrayForKey[indexPath.row];
        //转成RCDUserInfo
        RCUserInfo *userInfo = [RCUserInfo new];
        userInfo.userId = user.userId;
        userInfo.name = user.name;
        userInfo.portraitUri = user.portraitUri;
        [[RCIM sharedRCIM]refreshUserInfoCache:userInfo withUserId:userInfo.userId];
        [seletedUsers addObject:userInfo];
    }
    

    
    //excute the clickDoneCompletion
    if (self.clickDoneCompletion) {
        self.clickDoneCompletion(self,seletedUsers);
    }
    

}




//override delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.f;
}


//override datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"RCDAddressBookSelectedCell";
    RCDSelectPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];

    [cell setUserInteractionEnabled:YES];
    NSString *key = [self.allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [self.allFriends objectForKey:key];
    
    RCDUserInfo *user = arrayForKey[indexPath.row];
    if(user){
        cell.lblName.text = user.name;
        [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    
    //设置选中状态
    for (RCUserInfo *userInfo in self.seletedUsers) {
        if ([user.userId isEqualToString:userInfo.userId]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [cell setUserInteractionEnabled:NO];
        }
    }


    return cell;
}


//override delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCDSelectPersonTableViewCell *cell = (RCDSelectPersonTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCDSelectPersonTableViewCell *cell = (RCDSelectPersonTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}


@end
