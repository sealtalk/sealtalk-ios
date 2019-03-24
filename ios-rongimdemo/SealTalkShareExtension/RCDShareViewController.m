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
#define RCDLocalizedString(key) NSLocalizedStringFromTable(key, @"SealTalk", nil)


@interface RCDShareViewController ()
@property(nonatomic, copy) NSString *titleString;
@property(nonatomic, copy) NSString *contentString;
@property(nonatomic, copy) NSString *imageString;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, assign) BOOL isLogin;
@property(nonatomic, assign) BOOL canShare;
@end

@implementation RCDShareViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SealTalk";
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.im.share"];
    NSString *cookie = [userDefaults valueForKey:@"Cookie"];
    if (cookie.length == 0) {
        self.isLogin = NO;
    } else {
        self.isLogin = YES;
    }
    
    NSExtensionItem *extensionItem = self.extensionContext.inputItems.firstObject;
    for (NSItemProvider *itemProvider in extensionItem.attachments) {
        if (![itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
            self.canShare = NO;
        } else {
            [itemProvider
             loadItemForTypeIdentifier:@"public.url"
             options:nil
             completionHandler:^(NSURL *url, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([url.absoluteString.lowercaseString hasPrefix:@"http"] ) {
                         self.canShare = YES;
                     }else{
                         self.canShare = NO;
                     }
                     
                 });
             }];
        }
    }
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
    
    if (self.isLogin) {
        //不支持此类型的分享
        if (!self.canShare) {
            item.title = RCDLocalizedString(@"i_know_it")
;
            __weak typeof(self) weakSelf = self;
            self.textView.text = RCDLocalizedString(@"support_share")
;
            self.textView.textAlignment = NSTextAlignmentCenter;
            item.tapHandler = ^{
                [weakSelf.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            };
            return @[ item ];
        }
        
        item.title = RCDLocalizedString(@"share_to_friend")
;
        __weak typeof(self) weakSelf = self;
        item.tapHandler = ^{
            RCDShareChatListController *tableView = [[RCDShareChatListController alloc] init];
            NSExtensionItem *imageItem = weakSelf.extensionContext.inputItems.firstObject;
            for (NSItemProvider *imageItemProvider in imageItem.attachments) {
                
                if ([imageItemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
                    [imageItemProvider
                     loadItemForTypeIdentifier:@"public.url"
                     options:nil
                     completionHandler:^(NSURL *url, NSError *error) {
                         //           __strong typeof(weakSelf) weakSelf = weakSelf;
                         weakSelf.url = url.absoluteString;
                         NSData *data = [NSData dataWithContentsOfURL:url];
                         TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                         
                         if (weakSelf.contentText.length > 0) {
                             weakSelf.titleString = weakSelf.contentText;
                         } else {
                             NSArray *titleElements = [xpathParser searchWithXPathQuery:@"//title"];
                             if (titleElements.count > 0) {
                                 TFHppleElement *element = [titleElements objectAtIndex:0];
                                 weakSelf.titleString = element.content;
                             }
                         }
                         
                         NSArray *contentElements = [xpathParser searchWithXPathQuery:@"//meta"];
                         if (contentElements.count > 0) {
                             for (TFHppleElement *element in contentElements) {
                                 if ([[element objectForKey:@"name"] isEqualToString:@"description"]) {
                                     weakSelf.contentString = [element objectForKey:@"content"];
                                     break;
                                 } else {
                                     weakSelf.contentString = url.absoluteString;
                                 }
                             }
                         } else {
                             weakSelf.contentString = url.absoluteString;
                         }
                         
                         NSArray *imageElements = [xpathParser searchWithXPathQuery:@"//img"];
                         if (imageElements && contentElements.count > 0) {
                             for (TFHppleElement *element in imageElements) {
                                 NSString *string = [element objectForKey:@"src"];
                                 if ([string hasPrefix:@"http"]) {
                                     weakSelf.imageString = string;
                                     break;
                                 }
                             }
                         }
                         
                         if (!weakSelf.imageString) {
                             weakSelf.imageString = @"";
                         }
                         tableView.titleString = weakSelf.titleString;
                         tableView.contentString = weakSelf.contentString;
                         tableView.url = weakSelf.url;
                         tableView.imageString = weakSelf.imageString;
                         [tableView enableSendMessage:YES];
                         
                     }];
                    break;
                }
            }
            [weakSelf pushConfigurationViewController:tableView];
            
        };
        
    }else{
        item.title = RCDLocalizedString(@"i_know_it")
;
        __weak typeof(self) weakSelf = self;
        
        self.textView.text = RCDLocalizedString(@"use_share_must_open_sealtalk")
;
        self.textView.textAlignment = NSTextAlignmentCenter;
        item.tapHandler = ^{
            [weakSelf.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        };
    }
    return @[ item ];
}

- (UIView *)loadPreviewView {
    if (self.isLogin && self.canShare) {
        return [super loadPreviewView];
    }
    return nil;
}

- (void)didSelectCancel {
    [super didSelectCancel];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (!(self.isLogin && self.canShare)) {
        [textView resignFirstResponder];
        textView.userInteractionEnabled = NO;
    }
}
@end
