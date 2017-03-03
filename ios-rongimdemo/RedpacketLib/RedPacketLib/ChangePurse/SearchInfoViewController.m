//
//  SearchInfoViewController.m
//  RedpacketLib
//
//  Created by Mr.Yan on 16/5/10.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "SearchInfoViewController.h"

@interface SearchInfoViewController ()<UISearchDisplayDelegate,UISearchBarDelegate>
{
    UISearchBar * searchBar;
    UISearchDisplayController *searchControl;
    NSArray *_array;
}
@end

@implementation SearchInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //searchView
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    self.tableView.tableHeaderView = searchBar;
    searchBar.showsScopeBar = YES;
    searchBar.delegate = self;
    searchBar.placeholder = @"按关键字搜索...";
    
    //搜索的时候会有左侧滑动的效果
    searchControl = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    searchControl.delegate = self;
    searchControl.searchResultsDataSource = self;
    searchControl.searchResultsDelegate = self;
    _array = self.cardInfoarray;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.titleLable.text = @"选择银行卡支行";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNavgationBarBackgroundColor:[UIColor whiteColor] titleColor:[RedpacketColorStore rp_textColorBlack] leftButtonTitle:nil rightButtonTitle:nil];
}

#pragma -mark -searchbar

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(nullable NSString *)searchString
{
    NSString *strBase = controller.searchBar.text;
    if (strBase.length == 0) {
        _array = self.cardInfoarray;
        [self.tableView reloadData];
    }else {
        for (int j = 0; j < strBase.length; j ++) {
            
            NSMutableArray *marrzy = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dict  in self.cardInfoarray) {
                NSString *name = dict[_keyName];
                
                if ([_keyName isEqualToString:@"sbname"]) {
                    NSRange range;
                    range = [name rangeOfString:@"公司"];
                    if (range.location != NSNotFound) {
                        name = [name substringFromIndex:range.location + range.length];
                    }
                }
                for (int k = 0;k < name.length; k ++) {
                    if ((k+strBase.length < name.length) || (k+strBase.length == name.length)) {
                        NSString *strInput = [name substringWithRange:NSMakeRange(k,strBase.length)];
                        if ([strInput isEqualToString:strBase]) {
                            [marrzy addObject:dict];
                        }
                    }
                }
            }
            _array = marrzy;
            [self.tableView reloadData];
        }
    }
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _array = self.cardInfoarray;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   static NSString * strID = @"SearchInfoViewControllerID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:strID];
    }
    NSDictionary *dict = _array[indexPath.row];
    NSString *str  = dict[_keyName];
    if ([_keyName isEqualToString:@"sbname"]) {
        NSRange range;
        range = [str rangeOfString:@"公司"];
        if (range.location != NSNotFound) {
            str = [str substringFromIndex:range.location + range.length];
        }
    }
    cell.textLabel.text = str;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *interim = _array[indexPath.row];
    for (NSDictionary *dict in self.cardInfoarray) {
        
        if ([interim[_keyName] isEqualToString:dict[_keyName]]) {
            NSLog(@"%@",dict);
            [self.delegate repackWithDiction:dict];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}



@end
