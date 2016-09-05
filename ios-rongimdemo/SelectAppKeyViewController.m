//
//  SelectAppKeyViewController.m
//  RCloudMessage
//
//  Created by litao on 15/5/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

//本文件为了切换appkey测试用的，请应用开发者忽略关于本文件的信息。
#import "SelectAppKeyViewController.h"
#import "AddAppKeyViewController.h"

@interface SelectAppKeyViewController ()
@property(nonatomic, strong) NSMutableArray *models;
@end

@implementation SelectAppKeyViewController
- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onAdd:)];
}
- (void)onAdd:(id)sender {
  AddAppKeyViewController *aakvc = [[AddAppKeyViewController alloc] init];
  aakvc.result = ^(AppkeyModel *addedKey) {
    if (addedKey) {
      [self.models addObject:addedKey];
      NSMutableArray *keys = [[NSMutableArray alloc] init];
      NSMutableArray *envs = [[NSMutableArray alloc] init];
      for (AppkeyModel *model in self.models) {
        [keys addObject:model.appKey];
        [envs addObject:[NSNumber numberWithInt:model.env]];
      }
      [[NSUserDefaults standardUserDefaults] setObject:keys forKey:@"keys"];
      [[NSUserDefaults standardUserDefaults] setObject:envs forKey:@"envs"];
      [[NSUserDefaults standardUserDefaults] synchronize];
    }
  };
  [self.navigationController pushViewController:aakvc animated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView reloadData];
}
- (NSMutableArray *)models {
  if (!_models) {
    _models = [[NSMutableArray alloc] init];
    NSArray *keys =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"keys"];
    NSArray *envs =
        [[NSUserDefaults standardUserDefaults] objectForKey:@"envs"];
    for (int i = 0; i < keys.count; i++) {
      NSString *key = keys[i];
      NSNumber *env = envs[i];
      AppkeyModel *model =
          [[AppkeyModel alloc] initWithKey:key env:env.intValue];
      [_models addObject:model];
    }
  }

  return _models;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                             reuseIdentifier:@"appkeycell"];
  AppkeyModel *model = self.models[indexPath.row];
  cell.textLabel.text = model.appKey;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", model.env];
  return cell;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return self.models.count;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  AppkeyModel *model = self.models[indexPath.row];
  [self.navigationController popViewControllerAnimated:YES];
  self.result(model);
}
@end
