//
//  SMEmotionCentre.h
//  BQMM SDK
//
//  Created by ceo on 8/22/15.
//  Copyright (c) 2015 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTheme.h"
#import "MMEmoji.h"
#import "MMGif.h"
/**
 sdk region
 */
typedef enum
{
    MMRegionChina   = 0,
    MMRegionOther   = 1,
} MMRegion;

/**
 sdk language
 */
typedef enum
{
    MMLanguageChinese,
    MMLanguageEnglish,
} MMLanguage;

/**
 the type of emoji that to be fetched
 */
typedef enum
{
    MMFetchTypeSmall    = 1 << 0,
    MMFetchTypeBig      = 1 << 1,
    MMFetchTypeAll      = 1 << 2
} MMFetchType;

/**
 SDK mode
 */
typedef enum
{
    MMSDKModeIM         = 1 << 0,
    MMSDKModeComment    = 1 << 1,
} MMSDKMode;

@protocol MMEmotionCentreDelegate <NSObject>

@required
/**
 *  the delegate method handles the tap of gif
 */
- (void)didClickGifTab;

@optional

/**
 *  the delegate method handles the selection of big emoji in the keyboard
 *
 *  @param emoji      big emoji model
 */
- (void)didSelectEmoji:(nonnull MMEmoji *)emoji;


/**
 *  the delegate method handles the selection of prompts
 *
 *  @param emoji      prompts model
 */
- (void)didSelectTipEmoji:(nonnull MMEmoji *)emoji;

/**
 *  the delegate method handles the click of `send` button in the small emoji keyboard
 *
 *  @param input   the input control e.g. UITextView, UITextField...
 */
- (void)didSendWithInput:(nonnull UIResponder<UITextInput> *)input;

/**
 *  the delegate method called when user click the input control, at that point the keyboard has been
    switched to default, you can set the status of the control that controls the status of keyboard if necessary
 */
- (void)tapOverlay;

@end

@interface MMEmotionCentre : NSObject

/**
 *  Weather to use http or not
 *  Default is NO (use https)
 *  Can only be set once on startup
 */
@property (nonatomic) BOOL useHttp;

/**
 *  SDK region  default:MMRegionChina
 */
@property (nonatomic) MMRegion sdkRegion;

/**
 *  SDK language  default:MMLanguageChinese
 */
@property (nonatomic) MMLanguage sdkLanguage;

/**
 *  the delegate is the main data source of SDK
 */
@property (nonatomic, weak, nullable) id<MMEmotionCentreDelegate> delegate;

/**
 *  SDK mode   default:MMSDKModeIM
 */
@property (nonatomic) MMSDKMode sdkMode;

/**
 *  the switch for setting the support of Photo-text default YES
 */
@property (nonatomic) BOOL supportedMixedTextImage;

/**
 *  Emotion Center Singleton
 *
 *  @return Emotion Center Singleton
 */
+ (nonnull instancetype)defaultCentre;

/**
 *  get the current version of SDK
 *
 *  @return the current version of SDK
 */
- (nonnull NSString *)version;

/**
 *  initialize SDK with the third party key & id that assigned to your app
 *
 *  @param appkey     third party appKey
 *  @param platformId third party platform id
 */
- (void)setAppkey:(nonnull NSString *)appkey
       platformId:(nonnull NSString *)platformId;

/**
 *  initialize SDK
 *  Apply for appId and secret： http://open.biaoqingmm.com/open/register/index.html
 *  @param appId  the unique app id that assigned to your app
 *  @param secret the unique app secret that assigned to your app
 */
- (void)setAppId:(nonnull NSString *)appId
          secret:(nonnull NSString *)secret;

/**
 *  set userId to track the status of unique user
 *
 *  @param userId  unique id for user
 */
- (void)setUserId:(nullable NSString *)userId;

/**
 *  set the skin of SDK
 *
 *  @param theme  the MMTheme Object for SDK, please check out MMTheme.h for detail
 */
- (void)setTheme:(nonnull MMTheme *)theme;

/**
 *  set the default emoji group
 *
 *  @param emojiArray the unicode emoji array
 */
- (void)setDefaultEmojiArray:(nonnull NSArray<NSString *> *)emojiArray;


/**
 *  switch to default keyboard
 */
- (void)switchToDefaultKeyboard;

/**
 *  switch to emoji keyboard 
 *
 *  @param input the input control
 */
- (void)attachEmotionKeyboardToInput:(nonnull UIResponder<UITextInput> *)input;

/**
 *  trigger the function of `prompts` (as user typing SDK try to find the emojis that matching the content that user inputs)
 
 *  @param attchedView a view that the prompts show right above
 *  @param input       input control
 */
- (void)shouldShowShotcutPopoverAboveView:(nonnull UIView *)attchedView
                                withInput:(nonnull UIResponder<UITextInput> *)input
                                __attribute__((deprecated("no longer support")));


/**
 dismiss `prompts`
 */
- (void)dismissShotcutPopover;

/**
 * Enabled means Keyboard will show Unicode Emoji Tap; Default is Enabled
 *  @param enable       enable
 */
- (void)setUnicodeEmojiTabEnabled: (BOOL)enable;

/**
 *  fetch emojis according to emoji type and emoji code
 *
 *  @param fetchType         emoji type
 *  @param emojiCodes        a collection of emoji code
 *  @param completionHandler complition handler  emojis: a collection of MMEmoji or error object
 */
- (void)fetchEmojisByType:(MMFetchType)fetchType
                    codes:(nonnull NSArray *)emojiCodes
        completionHandler:(void (^ __nullable )(NSArray * __nullable emojis))completionHandler;

/**
 *  Display shop view controller
 */
- (void)presentShopViewController;
/**
 *  clear session
 */
- (void)clearSession;

/**
 *  clear cache
 */
- (void)clearCache;


//trending gif data
- (void)trendingGifsAt:(int)page
          withPageSize:(int)pageSize
     completionHandler:(void (^ __nonnull)(NSArray<MMGif *> * __nullable gifs, NSError * __nullable error))completionHandler;

//search gif data
- (void)searchGifsWithKey:(NSString * _Nullable)key
                       At:(int)page
             withPageSize:(int)pageSize
        completionHandler:(void (^ __nonnull)(NSString * __nonnull searchKey, NSArray<MMGif *> * __nullable gifs, NSError * __nullable error))completionHandler;

@end
