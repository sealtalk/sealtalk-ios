//
//  RCDGroupTableViewCell.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol JoinQuitGroupDelegate;

@interface RCDGroupTableViewCell : UITableViewCell

@property (nonatomic,copy) NSString *groupID;

@property (weak, nonatomic) IBOutlet UILabel *lblGroupName;
@property (weak, nonatomic) IBOutlet UILabel *lblPersonNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblInstru;
@property (weak, nonatomic) IBOutlet UIImageView *imvGroupPort;
@property (weak, nonatomic) IBOutlet UIButton *btJoin;

@property(nonatomic,assign) id<JoinQuitGroupDelegate> delegate;

/** 是否加入 */
@property(nonatomic, assign) BOOL  isJoin;

- (IBAction)btnJoin:(id)sender;
@end
@protocol JoinQuitGroupDelegate <NSObject>


@required

- (void)joinGroupCallback:(BOOL ) result withGroupId:(NSString*)groupId;

-(void) quitGroupCallback:(BOOL ) result withGroupId:(NSString*)groupId;
-(void) launchGroupChatPageByGroupId:(NSString*)groupId;
@end