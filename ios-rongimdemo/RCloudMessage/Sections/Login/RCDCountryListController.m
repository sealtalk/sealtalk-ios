//
//  RCDCountryListController.m
//  SealTalk
//
//  Created by 张改红 on 2019/2/18.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCDCountryListController.h"
#import "RCDUtilities.h"
#import "RCDCountry.h"
#import "UIColor+RCColor.h"
#import "RCDCommonDefine.h"
#import "RCDCommonString.h"
#import "RCDLoginManager.h"
#import "RCDUIBarButtonItem.h"

@interface RCDCountryListController () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate,
                                        UISearchResultsUpdating>

@property (nonatomic, retain) UISearchController *searchController;

//数据源
@property (nonatomic, strong) NSMutableArray *countryArray;
@property (nonatomic, strong) NSMutableArray *searchListArry;

@property (nonatomic, strong) NSMutableDictionary *resultDic;
@property (nonatomic, strong) NSMutableDictionary *searchResultDic;
@property (nonatomic, strong) NSDictionary *allCountryDic;
@property (nonatomic, strong) NSDictionary *allSearchCountryDic;

@end

@implementation RCDCountryListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.title = RCDLocalizedString(@"select_country");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self configCountryData];
    //设置右侧索引
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = HEXCOLOR(0x2B73EB);
    // 添加 searchbar 到 headerview
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [self setNaviItem];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:!self.showNavigationBarWhenBack animated:YES];
    [self.searchController setActive:NO];
}

- (void)setNaviItem {
    RCDUIBarButtonItem *leftBtn = [[RCDUIBarButtonItem alloc] initWithLeftBarButton:RCDLocalizedString(@"back")
                                                                             target:self
                                                                             action:@selector(clickBackBtn)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configCountryData {
    self.countryArray = [[NSMutableArray alloc] init];
    self.allCountryDic = [[NSDictionary alloc] init];
    self.allSearchCountryDic = [[NSDictionary alloc] init];
    __weak typeof(self) weakSelf = self;

    [RCDLoginManager getRegionlist:^(NSArray *_Nonnull countryArray) {
        weakSelf.countryArray = [countryArray mutableCopy];
        weakSelf.resultDic = [weakSelf sortedArrayWithPinYinDic:countryArray];
        rcd_dispatch_main_async_safe(^{
            weakSelf.allCountryDic = weakSelf.resultDic[@"infoDic"];
            [weakSelf.tableView reloadData];
        });
    }];
}

- (NSArray *)sectionCountryTitles {
    if (self.searchController.isActive) {
        return self.searchResultDic[@"allKeys"];
    } else {
        return self.resultDic[@"allKeys"];
    }
}

- (NSArray *)countriesInSection:(NSInteger)section {
    NSString *letter = [self sectionCountryTitles][section];

    NSArray *countries;
    if (self.searchController.active) {
        countries = self.allSearchCountryDic[letter];
    } else {
        countries = self.allCountryDic[letter];
    }
    return countries;
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.5;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self sectionCountryTitles];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 21.f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, 19);
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.frame = CGRectMake(13, 3, 15, 15);
    title.font = [UIFont systemFontOfSize:15.f];
    title.textColor = RCDDYCOLOR(0x808080, 0x666666);
    [view addSubview:title];

    NSArray *sectionTitles = [self sectionCountryTitles];
    title.text = sectionTitles[section];

    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self sectionCountryTitles].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self countriesInSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *flag = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:flag];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:flag];
        cell.backgroundColor = [RCDUtilities generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    }

    NSArray *sectionUserInfoList = [self countriesInSection:indexPath.section];

    RCDCountry *countryInfo = sectionUserInfoList[indexPath.row];
    if (countryInfo) {
        [cell.textLabel setText:countryInfo.countryName];
        cell.textLabel.textColor = RCDDYCOLOR(0x000000, 0x9f9f9f);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@", countryInfo.phoneCode];
    }
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionUserInfoList = [self countriesInSection:indexPath.section];
    RCDCountry *countryInfo = sectionUserInfoList[indexPath.row];
    if (self.SelectCountryResult) {
        self.SelectCountryResult(countryInfo);
    }
    if ([self.delegate respondsToSelector:@selector(fetchCountryPhoneCode:)]) {

        [self.delegate fetchCountryPhoneCode:countryInfo];
    }
    [self.navigationController popViewControllerAnimated:NO];
    [self.searchController setActive:NO];
}

#pragma mark - UISearchController Delegate -
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //谓词搜索过滤
    NSString *searchString = [self.searchController.searchBar text];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"countryName CONTAINS[cd] %@", searchString];
    if (self.searchListArry != nil) {
        [self.searchListArry removeAllObjects];
    }
    //过滤数据
    self.searchListArry = [NSMutableArray arrayWithArray:[self.countryArray filteredArrayUsingPredicate:preicate]];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.searchResultDic = [self sortedArrayWithPinYinDic:self.searchListArry];
        self.allSearchCountryDic = self.searchResultDic[@"infoDic"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - 属性初始化 -
- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.delegate = self;
        _searchController.searchResultsUpdater = self;
        //提醒字眼
        _searchController.searchBar.placeholder = NSLocalizedStringFromTable(@"ToSearch", @"RongCloudKit", nil);
        _searchController.searchBar.barTintColor = RCDDYCOLOR(0xf0f0f6, 0x000000);
        _searchController.searchBar.layer.borderColor = RCDDYCOLOR(0xf0f0f6, 0x000000).CGColor;
        _searchController.searchBar.layer.borderWidth = 1;
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return _searchController;
}
- (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)countryList {
    if (!countryList)
        return nil;
    NSArray *_keys = @[
        @"A",
        @"B",
        @"C",
        @"D",
        @"E",
        @"F",
        @"G",
        @"H",
        @"I",
        @"J",
        @"K",
        @"L",
        @"M",
        @"N",
        @"O",
        @"P",
        @"Q",
        @"R",
        @"S",
        @"T",
        @"U",
        @"V",
        @"W",
        @"X",
        @"Y",
        @"Z",
        @"#"
    ];
    NSMutableArray *mutableList = [countryList mutableCopy];

    NSMutableDictionary *infoDic = [NSMutableDictionary new];

    for (RCDCountry *model in mutableList) {
        NSString *firstLetter;
        if (model.countryName.length > 0 && ![model.countryName isEqualToString:@""]) {
            firstLetter = [RCDUtilities getFirstUpperLetter:model.countryName];
        } else {
            firstLetter = [RCDUtilities getFirstUpperLetter:model.countryName];
        }
        if ([_keys containsObject:firstLetter]) {
            NSMutableArray *array = infoDic[firstLetter];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:firstLetter];
            } else {
                [infoDic setObject:@[ model ].mutableCopy forKey:firstLetter];
            }
        } else {
            NSMutableArray *array = infoDic[@"#"];
            if (array) {
                [array addObject:model];
                [infoDic setObject:array forKey:@"#"];
            } else {
                [infoDic setObject:@[ model ].mutableCopy forKey:@"#"];
            }
        }
    }
    NSArray *keys = [[infoDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];

    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    return resultDic;
}
@end
