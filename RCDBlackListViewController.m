//
//  RCDBlackListViewController.m
//  RCloudMessage
//
//  Created by 蔡建海 on 15/7/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDBlackListViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "pinyin.h"
#import "RCDBlackListCell.h"
#import "RCDataBaseManager.h"

@interface RCDBlackListViewController ()

@property (nonatomic, strong) NSMutableDictionary *mDictData;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, assign) BOOL hideSectionHeader;
@end

@implementation RCDBlackListViewController

#pragma mark - Table view data source
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self getAllData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.tableView.tableFooterView = [UIView new];

}

#pragma mark - private

//
-(void) getAllData
{
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        [[RCDataBaseManager shareInstance] clearBlackListData];
        NSMutableArray *blacklist = [[NSMutableArray alloc]initWithCapacity:5];
        for (NSString *userID in blockUserIds) {
            // 暂不取用户信息，界面展示的时候在获取
            RCUserInfo*userInfo = [[RCUserInfo alloc]init];
            userInfo.userId = userID;
            userInfo.portraitUri = nil;
            userInfo.name = nil;
            [[RCDataBaseManager shareInstance] insertBlackListToDB:userInfo];
            [blacklist addObject:userInfo];
        }
        if (blacklist.count < 20) {
            self.hideSectionHeader = YES;
        }
        self.mDictData = [self sortedArrayWithPinYinDic:blacklist];
        // key 排序
        NSArray *keyArr = [[self.mDictData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        self.keys = [NSMutableArray arrayWithArray:keyArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } error:^(RCErrorCode status) {
        NSArray *blacklist = [[RCDataBaseManager shareInstance] getBlackList];
        if (blacklist.count < 20) {
            self.hideSectionHeader = YES;
        }
        self.mDictData = [self sortedArrayWithPinYinDic:blacklist];
        // key 排序
        NSArray *keyArr = [[self.mDictData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
        self.keys = [NSMutableArray arrayWithArray:keyArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        NSLog(@"getAllData error ");
    }];
}

//
- (void)removeFromBlackList:(NSIndexPath *)indexPath
{
    NSString *key = [self.keys objectAtIndex:indexPath.section];
    NSMutableArray *marray = [NSMutableArray arrayWithArray:[self.mDictData objectForKey:key]];
    [marray removeObjectAtIndex:indexPath.row];
    
    if (marray.count == 0)
    {
        [self.mDictData removeObjectForKey:key];
        [self.keys removeObject:key];
        
        [self.tableView reloadSectionIndexTitles];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        if (self.hideSectionHeader == NO && marray.count < 20) {
            
            self.hideSectionHeader = YES;
            [self.tableView reloadData];
        }
        else
        {
            [self.mDictData setObject:marray forKey:key];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableCellWithIdentifier = @"CellWithIdentifier";
    RCDBlackListCell *cell = (RCDBlackListCell *)[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    
    if (cell == nil) {
        cell = [[RCDBlackListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    
    NSString *key = [self.keys objectAtIndex:indexPath.section];
    RCUserInfo *info = [[self.mDictData objectForKey:key] objectAtIndex:indexPath.row];
    
    [cell setUserInfo:info];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [self.keys objectAtIndex:section];
    
    NSArray *arr = [self.mDictData objectForKey:key];
    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.keys.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

//pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.hideSectionHeader) {
        return nil;
    }
    return self.keys;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (self.hideSectionHeader) {
        return nil;
    }
    return [self.keys objectAtIndex:section];
}



#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
-(NSString *) hanZiToPinYinWithString:(NSString *)hanZi
{
    if(!hanZi) return nil;
    NSString *pinYinResult=[NSString string];
    for(int j=0;j<hanZi.length;j++){
        NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        
    }
    return pinYinResult;
}


/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */

-(NSMutableDictionary *) sortedArrayWithPinYinDic:(NSArray *) friends
{
    if(!friends) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc]initWithCapacity:5];
    
    for (RCUserInfo *user in friends)
    {
        [tempArr removeAllObjects];
        
        NSString *pyResult = [self hanZiToPinYinWithString:user.name];
        NSString *firstLetter = [pyResult substringToIndex:1];
        NSString *upperCase = [firstLetter uppercaseString]; // 大写
        
        char c = [pyResult characterAtIndex:0];
        // 一种函数：判断字符ch是否为英文字母，若为小写字母，返回2，若为大写字母，返回1。若不是字母，返回0。

        if (isalpha(c) == 0) {
            
            NSArray *array = [returnDic objectForKey:@"#"];
            if (array == nil || array.count == 0)
            {
                [tempArr addObject:user];
            }
            else
            {
                [tempArr addObjectsFromArray:array];
                [tempArr addObject:user];
            }
            [returnDic setObject:[NSArray arrayWithArray:tempArr] forKey:@"#"];
        }
        //
        else
        {
            NSArray *array = [returnDic objectForKey:upperCase];
            if (array == nil || array.count == 0)
            {
                [tempArr addObject:user];
            }
            else
            {
                [tempArr addObjectsFromArray:array];
                [tempArr addObject:user];
            }
            [returnDic setObject:[NSArray arrayWithArray:tempArr] forKey:upperCase];
        }
    }
    
    return returnDic;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *key = [self.keys objectAtIndex:indexPath.section];
        RCUserInfo *info = [[self.mDictData objectForKey:key] objectAtIndex:indexPath.row];
        
        __weak typeof(&*self) weakSelf = self;

        
        [[RCIMClient sharedRCIMClient] removeFromBlacklist:info.userId success:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf removeFromBlackList:indexPath];
            });
            
        } error:^(RCErrorCode status) {
            
            NSLog(@" ... 解除黑名单失败 ... ");
        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {

    }
}

@end
