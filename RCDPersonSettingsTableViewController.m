//
//  RCDPersonSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/30.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDPersonSettingsTableViewController.h"
#import "RCDPersonSettingsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "RCDataBaseManager.h"
#import "DefaultPortraitView.h"
#import "RCDHttpTool.h"

@interface RCDPersonSettingsTableViewController ()

@end

@implementation RCDPersonSettingsTableViewController
{
    RCConversation *currentConversation;
    BOOL enableNotification;
    NSArray *TitleList;
    BOOL isInBlacklist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    TitleList = [NSArray arrayWithObjects:@"消息免打扰",@"会话置顶",@"黑名单",@"清除聊天纪录", nil];
    self.tableView.tableFooterView = [UIView new];
    
    /******************添加headerview*******************/
    UIView *hearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 85)];
    
    UIImageView *portraitImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
    portraitImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [hearView addSubview:portraitImageView];
    if ([RCIM sharedRCIM].globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE && [RCIM sharedRCIM].globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        portraitImageView.layer.masksToBounds = YES;
        portraitImageView.layer.cornerRadius = 30.f;
    }
    else
    {
        portraitImageView.layer.masksToBounds = YES;
        portraitImageView.layer.cornerRadius = 6.f;
    }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [hearView addSubview:nameLabel];
    
    RCUserInfo *user = [[RCDataBaseManager shareInstance] getUserByUserId:_targetId];
    if ([user.portraitUri isEqualToString:@""]) {
        DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
        UIImage *portrait = [defaultPortrait imageFromView];
        portraitImageView.image = portrait;
    }
    else
    {
        [portraitImageView sd_setImageWithURL:[NSURL URLWithString:user.portraitUri] placeholderImage:[UIImage imageNamed:@"icon_person"]];
    }
    nameLabel.text = user.name;
    
    NSDictionary *views=NSDictionaryOfVariableBindings(portraitImageView,nameLabel);
    
    [hearView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[portraitImageView]-10-|" options:0 metrics:nil views:views]];
    
    [hearView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel(20)]" options:0 metrics:nil views:views]];
    
    [hearView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[portraitImageView(65)]-10-[nameLabel]-10-|" options:0 metrics:nil views:views]];
    
    [hearView addConstraint:[NSLayoutConstraint
                             constraintWithItem:nameLabel
                             attribute:NSLayoutAttributeCenterY
                             relatedBy:NSLayoutRelationEqual
                             toItem:hearView
                             attribute:NSLayoutAttributeCenterY
                             multiplier:1.0f
                             constant:0
                             ]];
    
    self.tableView.tableHeaderView = hearView;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self startLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 本类私有方法
-(void)startLoad
{
    currentConversation = [[RCIMClient sharedRCIMClient] getConversation:ConversationType_PRIVATE
                                                                targetId:_targetId];

        [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:ConversationType_PRIVATE
                                                                targetId:_targetId
                                                                 success:^(RCConversationNotificationStatus nStatus) {
                                                                     enableNotification = NO;
                                                                     if (nStatus == NOTIFY) {
                                                                         enableNotification = NO;
                                                                     }
                                                                     else
                                                                     {
                                                                         enableNotification = YES;
                                                                     }
                                                                     [self.tableView reloadData];
                                                                 }
                                                                   error:^(RCErrorCode status){
                                                                       
                                                                }];
    [RCDHTTPTOOL getBlacklistcomplete:^(NSMutableArray *result) {
        if (result.count == 0) {
            isInBlacklist = NO;
            [self.tableView reloadData];
        }
        else
        {
            for (NSDictionary *userInfo in result) {
                NSDictionary *user = userInfo[@"user"];
                if ([user[@"id"] isEqualToString:_targetId]) {
                    isInBlacklist = YES;
                }else{
                    isInBlacklist = NO;
                }
            }
            [self.tableView reloadData];
        }
    }];
}

-(void)clickNotificationBtn:(id)sender
{
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:ConversationType_PRIVATE
                                                            targetId:_targetId
                                                           isBlocked:!enableNotification
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 enableNotification = !enableNotification;
                                                                 //                                                                 [self.tableView reloadData];
                                                                 
                                                             } error:^(RCErrorCode status) {
                                                                 
                                                             }];
}

-(void)clickIsTopBtn:(id)sender
{
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_PRIVATE
                                               targetId:_targetId
                                                  isTop:!currentConversation.isTop];
}

-(void)clickAddOrRemoveToBlacklistBtn:(id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    if (switchBtn.isOn == NO) {
        [RCDHTTPTOOL RemoveToBlacklist:_targetId
                              complete:^(BOOL result) {
                                  
                              }];
    }
    else
    {
        [RCDHTTPTOOL AddToBlacklist:_targetId
                           complete:^(BOOL result) {
                               
                           }];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [TitleList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RCDPersonSettingsTableViewCell";
    RCDPersonSettingsTableViewCell *cell = (RCDPersonSettingsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.TitleLabel.text = [TitleList objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            cell.SwitchBtn.on = enableNotification;
            [cell.SwitchBtn addTarget:self action:@selector(clickNotificationBtn:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 1:
        {
            cell.SwitchBtn.on = currentConversation.isTop;
            [cell.SwitchBtn addTarget:self action:@selector(clickIsTopBtn:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 2:
        {
            cell.SwitchBtn.on = isInBlacklist;
            [cell.SwitchBtn addTarget:self action:@selector(clickAddOrRemoveToBlacklistBtn:) forControlEvents:UIControlEventValueChanged];
        }
            break;
            
        case 3:
        {
            cell.SwitchBtn.hidden = YES;
        }
            break;
            
            
        default:
            break;
    }
    
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"确定清除聊天记录？"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:@"确定"
                           otherButtonTitles:nil];
        
        [actionSheet showInView:self.view];
        actionSheet.tag = 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
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

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100)
    {
        [[RCIMClient sharedRCIMClient] clearMessages:ConversationType_PRIVATE
                                            targetId:_targetId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearHistoryMsg" object:nil];
    }
}

@end
