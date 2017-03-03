//
//  ServerSelectionViewController.m
//  RedpacketLib
//
//  Created by Mr.Yang on 16/8/24.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPServerSelectionViewController.h"
#import "RPServerHostManager.h"

@interface RPServerSelectionViewController ()

@end

@implementation RPServerSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLable.text = @"零钱";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [RPServerHostManager serverHosts].count;
}

static NSString *selection  = nil;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    NSArray *array = [RPServerHostManager serverHosts];
    if (cell) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        
        selection = [RPServerHostManager selectedServerHost];
        NSString *server = [array objectAtIndex:indexPath.row];
        if ([selection isEqualToString:server]) {
            cell.textLabel.textColor = [UIColor redColor];
            cell.selected = YES;
        }
        
        cell.textLabel.text = server;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [RPServerHostManager selectServerHostAtIndex:indexPath.row];
    
    if (_selectChanged) {
        _selectChanged();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
