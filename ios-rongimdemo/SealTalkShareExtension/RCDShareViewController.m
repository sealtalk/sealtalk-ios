//
//  RCDShareViewController.m
//  SealTalkShareExtension
//
//  Created by 张改红 on 16/8/4.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDShareViewController.h"
#import "RCDShareChatListController.h"
#import "TFHpple.h"

@interface RCDShareViewController ()
@property (nonatomic,copy)NSString *titleString;
@property (nonatomic,copy)NSString *contentString;
@property (nonatomic,copy)NSString *imageString;
@property (nonatomic,copy)NSString *url;
@end

@implementation RCDShareViewController
- (void)viewDidLoad{
  [super viewDidLoad];
  self.title = @"SealTalk";
}

- (BOOL)isContentValid {
//  NSExtensionItem *imageItem = [self.extensionContext.inputItems firstObject];
//  if(!imageItem) {
//    return NO;
//  }
//  
//  NSItemProvider *imageItemProvider = [[imageItem attachments] firstObject];
//  if(!imageItemProvider) {
//    return NO;
//  }
//  
//  if([imageItemProvider hasItemConformingToTypeIdentifier:@"public.url"] && self.contentText.length > 0) {
//    return YES;
//  }
  return NO;
}

- (void)didSelectPost {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
  SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
  item.title = @"分享给朋友";
  __weak typeof(self) weakSelf = self;
  item.tapHandler = ^{
    RCDShareChatListController *tableView =
        [[RCDShareChatListController alloc] init];
    NSExtensionItem *imageItem = self.extensionContext.inputItems.firstObject;
    for (NSItemProvider *imageItemProvider in imageItem.attachments) {
      
      if ([imageItemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [imageItemProvider
         loadItemForTypeIdentifier:@"public.url"
         options:nil
         completionHandler:^(NSURL *url, NSError *error) {
           __strong typeof(weakSelf) strongSelf = weakSelf;
           strongSelf.url = url.absoluteString;
           NSData *data = [NSData dataWithContentsOfURL:url];
           TFHpple *xpathParser =
           [[TFHpple alloc] initWithHTMLData:data];
           
           if (strongSelf.contentText.length > 0) {
             strongSelf.titleString = strongSelf.contentText;
           } else {
             NSArray *titleElements =
             [xpathParser searchWithXPathQuery:@"//title"];
             if (titleElements.count > 0) {
               TFHppleElement *element =
               [titleElements objectAtIndex:0];
               strongSelf.titleString = element.content;
             }
           }
           
           NSArray *contentElements =
           [xpathParser searchWithXPathQuery:@"//meta"];
           if (contentElements.count > 0) {
             for (TFHppleElement *element in contentElements) {
               if ([[element objectForKey:@"name"]
                    isEqualToString:@"description"]) {
                 strongSelf.contentString =
                 [element objectForKey:@"content"];
                 break;
               } else {
                 strongSelf.contentString = url.absoluteString;
               }
             }
           } else {
             strongSelf.contentString = url.absoluteString;
           }
           
           NSArray *imageElements =
           [xpathParser searchWithXPathQuery:@"//img"];
           if (imageElements && contentElements.count > 0) {
             for (TFHppleElement *element in imageElements) {
               NSString *string = [element objectForKey:@"src"];
               if ([string containsString:@"http"]) {
                 strongSelf.imageString = string;
                 break;
               }
             }
           }
           
           if (!strongSelf.imageString) {
             strongSelf.imageString = @"";
           }
           tableView.titleString = strongSelf.titleString;
           tableView.contentString = strongSelf.contentString;
           tableView.url = strongSelf.url;
           tableView.imageString = strongSelf.imageString;
           [tableView enableSendMessage:YES];
           
         }];
        break;
      }
    }
    [weakSelf pushConfigurationViewController:tableView];

  };
  return @[ item ];
}

@end
