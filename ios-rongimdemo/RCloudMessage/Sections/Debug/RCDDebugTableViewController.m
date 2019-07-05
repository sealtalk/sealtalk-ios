//
//  RCDDebugTableViewController.m
//  SealTalk
//
//  Created by Jue on 2018/5/11.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RCDDebugTableViewController.h"
#import "RCDDebugViewController.h"
#import "RCDDebugNoDisturbViewController.h"
#import <RongIMKit/RongIMKit.h>
#import <SSZipArchive/SSZipArchive.h>
#import "RCDCommonString.h"
#import <GCDWebServer/GCDWebUploader.h>

#define DISPLAY_ID_TAG 100
#define DISPLAY_ONLINE_STATUS_TAG 101
#define JOIN_CHATROOM_TAG 102

#define FILEMANAGER [NSFileManager defaultManager]

@interface RCDDebugTableViewController ()

@property (nonatomic, strong) NSDictionary *functions;

@property (nonatomic,strong) NSString *documentPath;

@property (nonatomic,strong) NSString *libraryPath;

@property (nonatomic,strong) NSString *currentDateStr;

@property (nonatomic,strong) NSString *createPath;

@property (nonatomic,strong) GCDWebUploader *webUploader;
@end

@implementation RCDDebugTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initdata];
    [self tableViewSetting];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.webUploader.running) {
        [self.webUploader stop];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.functions.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * allkeys = [self.functions allKeys];
    NSArray *titles = self.functions[allkeys[section]];
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc] init];
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor grayColor];
    title.text = self.functions.allKeys[section];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    根据indexPath准确地取出一行，而不是从cell重用队列中取出
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    }
    NSArray * allkeys = [self.functions allKeys];
    NSArray *titles = self.functions[allkeys[indexPath.section]];
    NSString *title = titles[indexPath.row];
    cell.textLabel.text = title;
    cell.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.text = @"";
    if ([title isEqualToString:RCDLocalizedString(@"show_ID")
]) {
        [self setSwitchButtonCell:cell tag:DISPLAY_ID_TAG];
    }
    if ([title isEqualToString:RCDLocalizedString(@"show_online_status")
]) {
        [self setSwitchButtonCell:cell tag:DISPLAY_ONLINE_STATUS_TAG];
    }
    if ([title isEqualToString:RCDLocalizedString(@"Joining_the_chat_room_failed_to_stay_in_the_session_interface")
]) {
        [self setSwitchButtonCell:cell tag:JOIN_CHATROOM_TAG];
    }
    if ([title isEqualToString:RCDLocalizedString(@"Set_offline_message_compensation_time")
] || [title isEqualToString:RCDLocalizedString(@"Set_global_DND_time")
]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        //section1
        case 1:
            switch (indexPath.row) {
                case 0:{
                    [self doCrash];
                }
                    break;
                    
                case 1:{
                    [self copyAndSendFiles];
                }
                    break;
                case 2:{
                    [self startHttpServer];
                }
                default:
                    break;
            }
            break;
        
        //section 2
        case 2: {
            switch (indexPath.row) {
                case 0:
                    [self pushToDebugVC];
                    break;
                    
                case 1:
                    [self pushToNoDisturbVC];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark init data for tabelview
- (void)initdata {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:@[RCDLocalizedString(@"show_ID"),
                     RCDLocalizedString(@"show_online_status")]
            forKey:RCDLocalizedString(@"show_setting")];
    
    [dic setObject:@[RCDLocalizedString(@"force_crash"),
                     RCDLocalizedString(@"send_log"),
                     @"显示沙盒内容",
                     RCDLocalizedString(@"Joining_the_chat_room_failed_to_stay_in_the_session_interface")]
            forKey:RCDLocalizedString(@"custom_setting")];
    
    [dic setObject:@[RCDLocalizedString(@"Set_offline_message_compensation_time"),
                     RCDLocalizedString(@"Set_global_DND_time")]
            forKey:RCDLocalizedString(@"time_setting")];
    
    self.functions = [dic copy];
}

#pragma mark UI setting
- (void)tableViewSetting {
    self.tableView.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:243 / 255.0 alpha:1.f];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark private methord

/**
 为cell添加swtich button

 @param cell cell对象
 */
- (void)addSwitchToCell:(UITableViewCell *)cell{
    BOOL isNeedAdd = YES;
    for (UIView *subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UISwitch class]]) {
            isNeedAdd = NO;
            break;
        }
    }
    if (isNeedAdd == NO) return;
    UISwitch *switchView = [[UISwitch alloc] init];
    switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    switchView.tag = cell.tag;
    BOOL isButtonOn = NO;
    switch (cell.tag) {
        case DISPLAY_ID_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDisplayIDKey];
        } break;
            
        case DISPLAY_ONLINE_STATUS_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDDisplayOnlineStatusKey];
        } break;
            
        case JOIN_CHATROOM_TAG: {
            isButtonOn = [DEFAULTS boolForKey:RCDStayAfterJoinChatRoomFailedKey];
        } break;
            
        default:
            break;
    }
    switchView.on = isButtonOn;
    [cell.contentView addSubview:switchView];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:switchView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1
                                                                  constant:-20]];
}


- (void)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;
    BOOL isButtonOn = [switchButton isOn];
    switch (switchButton.tag) {
        case DISPLAY_ID_TAG: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDisplayIDKey];
            [DEFAULTS synchronize];
        } break;
            
        case DISPLAY_ONLINE_STATUS_TAG: {
            [DEFAULTS setBool:isButtonOn forKey:RCDDisplayOnlineStatusKey];
            [DEFAULTS synchronize];
        } break;
         
        case JOIN_CHATROOM_TAG: {
            [DEFAULTS setBool:isButtonOn forKey:RCDStayAfterJoinChatRoomFailedKey];
            [DEFAULTS synchronize];
        } break;
            
        default:
            break;
    }
}

- (void)setSwitchButtonCell:(UITableViewCell *)cell tag:(int)tag {
    cell.tag = tag;
    [self addSwitchToCell:cell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

/**
 强制Crash
 */
- (void)doCrash {
    [@[] objectAtIndex:1];
}


/**
 跳转到设置离线消息补偿时间的页面
 */
- (void)pushToDebugVC {
    RCDDebugViewController *vc = [[RCDDebugViewController alloc] init];
    vc.title = RCDLocalizedString(@"Set_offline_message_compensation_time")
;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 跳转到设置全局免打扰的页面
 */
- (void)pushToNoDisturbVC {
    RCDDebugNoDisturbViewController *vc = [[RCDDebugNoDisturbViewController alloc] init];
    vc.title = @"设置全局免打扰";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)startHttpServer {
    NSString *homePath = NSHomeDirectory();
    self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:homePath];
    if([self.webUploader start]) {
        NSString *host = self.webUploader.serverURL.absoluteString;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:host message:@"请在电脑浏览器打开上面的地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"web uploader host:%@ port:%@",host,@(self.webUploader.port));
    }
}

/**
 打包沙盒文件并发送
 */
- (void)copyAndSendFiles {
    //获取系统当前的时间戳
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970];
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:now];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.currentDateStr = [dateFormatter stringFromDate: detailDate];
    
    // Document目录
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentPath = [paths1 objectAtIndex:0];
    // Libaray目录
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    self.libraryPath = [paths2 objectAtIndex:0];
    
    self.createPath = [NSString stringWithFormat:@"%@/SealTalk%@", self.documentPath, self.currentDateStr];
    
    if (![FILEMANAGER
          fileExistsAtPath:
          self.createPath]) //判断createPath路径文件夹是否已存在，此处createPath为需要新建的文件夹的绝对路径
    {
        
        [FILEMANAGER createDirectoryAtPath:self.createPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil]; //创建文件夹
    }
    
    [self copySealTalkDataBase];
    [self copyLogFile];
    [self copySDKFileAndDB];
    [self copyPlistFile];
    [self zipAndSend];
    [self sendBlinkLog];
}

- (void)copySealTalkDataBase {
    // SealTalk数据库导出
    NSString *dataBasePath = [self.libraryPath
                              stringByAppendingString:[NSString stringWithFormat:@"/Application Support/RongCloud/RongIMDemoDB%@",
                                                       [RCIM sharedRCIM].currentUserInfo.userId]];
    if ([FILEMANAGER fileExistsAtPath:dataBasePath]) {
        [FILEMANAGER copyItemAtPath:dataBasePath
                             toPath:[NSString stringWithFormat:@"%@/SealTalkDatabase", self.createPath]
                              error:nil];
    }
}

- (void)copyLogFile {
    // log导出
    NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:self.documentPath error:nil];
    for (NSString *file in files) {
        if ([file hasPrefix:@"rc"]) {
            NSString *logPath = [NSString stringWithFormat:@"%@/%@",self.documentPath,file];
            if ([FILEMANAGER fileExistsAtPath:logPath]) {
                [FILEMANAGER copyItemAtPath:logPath
                                     toPath:[NSString stringWithFormat:@"%@/%@", self.createPath,file]
                                      error:nil];
            }
        }
    }
}

- (void)copySDKFileAndDB {
    // SDK的文件和数据库导出
    NSString *filesPath = [self.libraryPath
                              stringByAppendingString:[NSString stringWithFormat:@"/Application Support/RongCloud/%@/%@",[DEFAULTS valueForKey:RCDAppKeyKey],
                                                       [RCIM sharedRCIM].currentUserInfo.userId]];
    if ([FILEMANAGER fileExistsAtPath:filesPath]) {
        NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:filesPath error:nil];
        for (NSString *file in files) {
            if (![file hasSuffix:@"bak"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@",filesPath,file];
                if ([FILEMANAGER fileExistsAtPath:filePath]) {
                    [FILEMANAGER copyItemAtPath:filePath
                                         toPath:[NSString stringWithFormat:@"%@/%@", self.createPath,file]
                                          error:nil];
                }
            }
        }
    }
}

- (void)copyPlistFile {
    // plist文件导出
    NSString *plistFilePath = [self.libraryPath stringByAppendingString:@"/Preferences"];
    plistFilePath = [NSString stringWithFormat:@"%@/%@.plist", plistFilePath, [[NSBundle mainBundle] bundleIdentifier]];
    if ([FILEMANAGER fileExistsAtPath:plistFilePath]) {
        [FILEMANAGER copyItemAtPath:plistFilePath
                             toPath:[NSString stringWithFormat:@"%@/%@.plist", self.createPath,
                                     [[NSBundle mainBundle] bundleIdentifier]]
                              error:nil];
    }
}

- (void)zipAndSend {
    NSString *zipFilePath = [NSString stringWithFormat:@"%@/SealTalk%@.zip",self.documentPath,self.currentDateStr];
    [SSZipArchive createZipFileAtPath:zipFilePath
              withContentsOfDirectory:self.createPath
                  keepParentDirectory:NO
                     compressionLevel:-1
                             password:nil
                                  AES:YES
                      progressHandler:nil];
    if ([FILEMANAGER fileExistsAtPath:zipFilePath]) {
        RCFileMessage *zipFileMessage = [RCFileMessage messageWithFile:zipFilePath];
        [[RCIMClient sharedRCIMClient]
         sendMediaMessage:ConversationType_PRIVATE
         targetId:[RCIM sharedRCIM].currentUserInfo.userId
         content:zipFileMessage
         pushContent:nil
         pushData:nil
         progress:^(int progress, long messageId) {
         }
         success:^(long messageId) {
             [FILEMANAGER removeItemAtPath:zipFilePath error:nil];
         }
         error:^(RCErrorCode errorCode, long messageId) {
         }
         cancel:^(long messageId){
         }];
        
    }
}

- (void)sendBlinkLog {
    //blink log
    NSString *blinkLogPath = [NSString stringWithFormat:@"%@/Blink",self.documentPath];
    BOOL isDir = YES;
    if ([FILEMANAGER fileExistsAtPath:blinkLogPath isDirectory:&isDir]) {
        NSArray *files = [FILEMANAGER contentsOfDirectoryAtPath:blinkLogPath error:nil];
        if (files.count >= 1) {
            NSString *zipFilePath = [NSString stringWithFormat:@"%@/BlinkLog_%@.zip",self.documentPath,self.currentDateStr];
            [SSZipArchive createZipFileAtPath:zipFilePath
                      withContentsOfDirectory:blinkLogPath
                          keepParentDirectory:NO
                             compressionLevel:-1
                                     password:nil
                                          AES:YES
                              progressHandler:nil];
            RCFileMessage *zipFileMessage = [RCFileMessage messageWithFile:zipFilePath];
            [[RCIMClient sharedRCIMClient]
             sendMediaMessage:ConversationType_PRIVATE
             targetId:[RCIM sharedRCIM].currentUserInfo.userId
             content:zipFileMessage
             pushContent:nil
             pushData:nil
             progress:^(int progress, long messageId) {
             }
             success:^(long messageId) {
                 [FILEMANAGER removeItemAtPath:zipFilePath error:nil];
             }
             error:^(RCErrorCode errorCode, long messageId) {
             }
             cancel:^(long messageId){
             }];
        }
    }
}
@end
