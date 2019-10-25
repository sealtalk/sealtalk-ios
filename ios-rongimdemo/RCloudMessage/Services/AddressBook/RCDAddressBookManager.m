//
//  RCDAddressBookManager.m
//  SealTalk
//
//  Created by 孙浩 on 2019/7/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDAddressBookManager.h"
#import <Contacts/Contacts.h>
#import "RCDUserInfoAPI.h"
#import "RCDCommonString.h"

@interface RCDAddressBookManager ()

@property (nonatomic, strong) NSMutableDictionary *dict;

@end

@implementation RCDAddressBookManager

+ (instancetype)sharedManager {
    static RCDAddressBookManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedManager == nil) {
            sharedManager = [[RCDAddressBookManager alloc] init];
            sharedManager.state = RCDContactsAuthStateNotDetermine;
        }
    });
    return sharedManager;
}

- (void)getContactsAuthState {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusAuthorized) {
        self.state = RCDContactsAuthStateApprove;
    } else if (status == CNAuthorizationStatusNotDetermined) {
        self.state = RCDContactsAuthStateNotDetermine;
    } else {
        self.state = RCDContactsAuthStateRefuse;
    }
}

- (void)requestAuth {
    CNContactStore *contact = [[CNContactStore alloc] init];
    [contact requestAccessForEntityType:CNEntityTypeContacts
                      completionHandler:^(BOOL granted, NSError *_Nullable error) {
                          if (granted) {
                              self.state = RCDContactsAuthStateApprove;
                          } else {
                              self.state = RCDContactsAuthStateRefuse;
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [[NSNotificationCenter defaultCenter] postNotificationName:RCDContactsAuthStateChangeKey
                                                                                  object:nil
                                                                                userInfo:nil];
                          });
                      }];
}

- (NSArray *)getAllContactPhoneNumber {

    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized) {
        return nil;
    }

    self.dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *phoneNumberArray = [NSMutableArray array];

    CNContactStore *contactStore = [CNContactStore new];
    NSArray *keys = @[ CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactGivenNameKey ];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    [contactStore
        enumerateContactsWithFetchRequest:request
                                    error:nil
                               usingBlock:^(CNContact *_Nonnull contact, BOOL *_Nonnull stop) {

                                   NSString *lastName = contact.familyName;
                                   NSString *firstName = contact.givenName;
                                   NSString *name = [NSString stringWithFormat:@"%@ %@", lastName, firstName];

                                   for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
                                       CNPhoneNumber *phoneValue = labeledValue.value;
                                       NSString *tempPhone = phoneValue.stringValue;
                                       NSString *phoneNumber =
                                           [tempPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
                                       [phoneNumberArray addObject:phoneNumber];
                                       if (phoneNumber.length > 0) {
                                           [self.dict setValue:name forKey:phoneNumber];
                                       }
                                   }
                               }];
    return [phoneNumberArray copy];
}

- (NSArray *)getAllContacts {
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized) {
        return nil;
    }

    NSMutableArray *contactsArray = [NSMutableArray array];
    CNContactStore *contactStore = [CNContactStore new];
    NSArray *keys = @[ CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactGivenNameKey ];
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    [contactStore enumerateContactsWithFetchRequest:request
                                              error:nil
                                         usingBlock:^(CNContact *_Nonnull contact, BOOL *_Nonnull stop) {

                                             NSString *lastName = contact.familyName;
                                             NSString *firstName = contact.givenName;
                                             NSString *name = [NSString stringWithFormat:@"%@ %@", lastName, firstName];

                                             for (CNLabeledValue *labeledValue in contact.phoneNumbers) {
                                                 RCDContactsInfo *contacts = [[RCDContactsInfo alloc] init];
                                                 CNPhoneNumber *phoneValue = labeledValue.value;
                                                 NSString *phoneNumber = phoneValue.stringValue;
                                                 contacts.name = name;
                                                 contacts.phoneNumber = phoneNumber;
                                                 [contactsArray addObject:contacts];
                                             }
                                         }];
    return [contactsArray copy];
}

+ (void)getContactsInfo:(NSArray *)phoneNumberList complete:(void (^)(NSArray *))completeBlock {

    [RCDUserInfoAPI
        getContactsInfo:phoneNumberList
               complete:^(NSArray *contactsList) {
                   NSMutableArray *contacstList = [NSMutableArray array];
                   NSString *currentPhone = [DEFAULTS stringForKey:RCDUserNameKey];
                   for (NSDictionary *userJson in contactsList) {
                       if ([userJson[@"registered"] boolValue] && ![userJson[@"phone"] isEqualToString:currentPhone]) {
                           RCDContactsInfo *contactsInfo = [[RCDContactsInfo alloc] init];
                           contactsInfo.isRegister = [userJson[@"registered"] boolValue];
                           contactsInfo.isRelationship = [userJson[@"relationship"] boolValue];
                           contactsInfo.userId = userJson[@"id"];
                           contactsInfo.stAccount = userJson[@"stAccount"];
                           contactsInfo.phoneNumber = userJson[@"phone"];
                           contactsInfo.nickname = userJson[@"nickname"];
                           contactsInfo.portraitUri = userJson[@"portraitUri"];
                           contactsInfo.name =
                               [[RCDAddressBookManager sharedManager].dict objectForKey:contactsInfo.phoneNumber];
                           [contacstList addObject:contactsInfo];
                       }
                   }
                   if (completeBlock) {
                       completeBlock(contacstList);
                   }
               }];
}

@end
