//
//  SearchInfoViewController.h
//  RedpacketLib
//
//  Created by Mr.Yan on 16/5/10.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHRefreshTableViewController.h"

@protocol SearchViewDelegate <NSObject>

- (void)repackWithDiction:(NSDictionary *)dict;

@end

@interface SearchInfoViewController : YZHRefreshTableViewController

@property (nonatomic) NSArray *cardInfoarray;

@property (nonatomic,copy) NSString *keyName;

@property (nonatomic, assign)id <SearchViewDelegate> delegate;

@end
