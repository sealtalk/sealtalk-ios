//
//  RCDUtilities.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUtilities.h"
#import "DefaultPortraitView.h"

@implementation RCDUtilities
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
  UIImage *image = nil;
  NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *bundlePath =
      [resourcePath stringByAppendingPathComponent:bundleName];
  NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];

  // NSString* path = [[[[NSBundle mainBundle] resourcePath]
  // stringByAppendingPathComponent:bundleName]stringByAppendingPathComponent:[NSString
  // stringWithFormat:@"%@.png",name]];

  // image = [UIImage imageWithContentsOfFile:image_path];
  image = [[UIImage alloc] initWithContentsOfFile:image_path];
  return image;
}

+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo {
  NSString *filePath = [[self class]
      getIconCachePath:[NSString
                           stringWithFormat:@"group%@.png", groupInfo.groupId]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
    return [portraitPath absoluteString];
  } else {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:groupInfo.groupId
                             Nickname:groupInfo.groupName];
    UIImage *portrait = [defaultPortrait imageFromView];

    BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                       atomically:YES];
    if (result) {
      NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
      return [portraitPath absoluteString];
    } else {
      return nil;
    }
  }
}

+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo {
  NSString *filePath = [[self class]
      getIconCachePath:[NSString
                           stringWithFormat:@"user%@.png", userInfo.userId]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
    return [portraitPath absoluteString];
  } else {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
    UIImage *portrait = [defaultPortrait imageFromView];

    BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                       atomically:YES];
    if (result) {
      NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
      return [portraitPath absoluteString];
    } else {
      return nil;
    }
  }
}

+ (NSString *)getIconCachePath:(NSString *)fileName {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0]
      stringByAppendingPathComponent:
          [NSString
              stringWithFormat:@"CachedIcons/%@", fileName]]; // 保存文件的名称

  NSString *dirPath = [[paths objectAtIndex:0]
      stringByAppendingPathComponent:[NSString
                                         stringWithFormat:@"CachedIcons"]];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:dirPath]) {
    [fileManager createDirectoryAtPath:dirPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
  }
  return filePath;
}

@end
