//
//  SMTheme.h
//  BQMM SDK
//
//  Created by ceo on 8/27/15.
//  Copyright (c) 2015 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTheme : NSObject

/**
 *  the background color of emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *groupViewBgColor;

/**
 *  the background color of emoji keyboard toolbar
 */
@property (nonatomic, strong, nullable) UIColor  *inputToolViewBgColor;

/**
 *  the background color of package icon in the emoji keyboard toolbar
 */
@property (nonatomic, strong, nullable) UIColor  *packageBgColor;

/**
 *  the background color of the selected package icon in the emoji keyboard toolbar
 */
@property (nonatomic, strong, nullable) UIColor  *packageSelectedBgColor;


/**
 *  the background color of the `send` button in the emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *sendBtnBgColor;

/**
 *  the title color of the `send` button in the emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *sendBtnTitleColor;

/**
 *   the color of the navigation bar in the shop viewController
 */
@property (nonatomic, strong, nullable) UIColor  *navigationBarColor;

/**
 *  the tint color of the navigation bar in the shop viewController
 */
@property (nonatomic, strong, nullable) UIColor  *navigationBarTintColor;

/**
 *  the title font of the navigation bar in the shop viewController
 */
@property (nonatomic, strong, nullable) UIFont   *navigationTitleFont;

/**
 *  the color of the seperate line
 */
@property (nonatomic, strong, nullable) UIColor  *separateColor;

/**
 *  the font of category name in shop viewController
 */
@property (nonatomic, strong, nullable) UIFont   *shopCategoryFont;

/**
 *  the title color of category name in shop viewController
 */
@property (nonatomic, strong, nullable) UIColor  *shopCategoryColor;

/**
 *  the font of package name in shop viewController
 */
@property (nonatomic, strong, nullable) UIFont   *shopPackageTitleFont;

/**
 *  the title color of package name in shop viewController
 */
@property (nonatomic, strong, nullable) UIColor  *shopPackageTitleColor;

/**
 *  the font of package subtitle in shop viewController
 */
@property (nonatomic, strong, nullable) UIFont   *shopPackageSubTitleFont;

/**
 *  the title color of package subtitle in shop viewController
 */
@property (nonatomic, strong, nullable) UIColor  *shopPackageSubTitleColor;

/**
 *  the background color of the remove button in my stickers viewController
 */
@property (nonatomic, strong, nullable) UIColor  *removeBtnBgColor;

/**
 *  the font of the remove button title in my stickers viewController
 */
@property (nonatomic, strong, nullable) UIFont  *removeBtnTitleFont;

/**
 *  the title color of the remove button in my stickers viewController
 */
@property (nonatomic, strong, nullable) UIColor  *removeBtnTitleColor;

/**
 *  the border color of the remove button in my stickers viewController
 */
@property (nonatomic, strong, nullable) UIColor  *removeBtnBorderColor;
/**
 *  the background color of the `banned` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIColor  *detailPackageBannedBgColor;
/**
 *  the font of the `banned` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIFont   *detailPackageBannedFont;

/**
 *  the title color of the `banned` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIColor  *detailPackageBannedColor;

/**
 *  the title font of the package detail viewController
 */
@property (nonatomic, strong, nullable) UIFont   *detailPackageTitleFont;

/**
 *  the title color of the package detail viewController
 */
@property (nonatomic, strong, nullable) UIColor  *detailPackageTitleColor;

/**
 *  the font of the `describe` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIFont   *detailPackageDescFont;

/**
 *  the title color of the `describe` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIColor  *detailPackageDescColor;

/**
 *  the font of the `preview` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIFont   *detailPackagePreviewFont;

/**
 *  the title color of the `preview` label in package detail viewController
 */
@property (nonatomic, strong, nullable) UIColor  *detailPackagePreviewColor;

/**
 *  the title font of `download` button
 */
@property (nonatomic, strong, nullable) UIFont   *downloadTitleFont;

/**
 *  the title color of `download` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadTitleColor;

/**
 *  the title color of `downloaded` button

 */
@property (nonatomic, strong, nullable) UIColor  *downloadedTitleColor;

/**
 *  the background color of `downloaded` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadedBgColor;

/**
 *  the border color of `downloaded` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadedBorderColor;

/**
 *  the border color of `download` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadBorderColor;

/**
 *  the background color of `download` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadBgColor;

/**
 *  the color of `download` progress bar
 */
@property (nonatomic, strong, nullable) UIColor  *downloadingColor;

/**
 *  the title color of `downloading` button
 */
@property (nonatomic, strong, nullable) UIColor  *downloadingTextColor;

/**
 *  the border color of `download` button in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadDownloadBorderColor;

/**
 *  the background color of `download` button in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadDownloadBgColor;

/**
 *  the color of `download` progress bar in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadDownloadingColor;

/**
 *  the title color of `downloading` button in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadDownloadingTextColor;

/**
 *  the title color of download button in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadDownloadTitleColor;
/**
 *  the font of download button in preload package cell
 */
@property (nonatomic, strong, nullable) UIFont   *preloadDownloadTitleFont;
/**
 *  the title color of introduce label in preload package cell
 */
@property (nonatomic, strong, nullable) UIColor  *preloadIntroduceTitleColor;
/**
 *  the font of introduce label in preload package cell
 */
@property (nonatomic, strong, nullable) UIFont   *preloadIntroduceTitleFont;
/**
 *  the color of mask view in preload package cell
 */
@property (nonatomic,strong, nullable) UIColor *preloadMaskViewColor;
/**
 * the font of copyright label in package detail viewcontroller
 */
@property (nonatomic, strong, nullable) UIFont   *copyrightFont;

/**
 * the color of copyright label in package detail viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor  *copyrightColor;

/**
 *  the font of prompt label
 */
@property (nonatomic, strong, nullable) UIFont   *promptLabelFont;

/**
 *  the color of prompt label
 */
@property (nonatomic, strong, nullable) UIColor  *promptLabelColor;

/**
 *  the font of `retry` button in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIFont   *retryBtnFont;

/**
 *  the title color of `retry` button in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *retryBtnColor;

/**
 *  the background color of `retry` button in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *retryBtnBgColor;

/**
 *  the border color of `retry` button in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *retryBtnBorderColor;


/**
 *  the background color of `shop` button in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *shopBtnBgColor;

/**
*  the color of `shop` button icon in emoji keyboard
 */
@property (nonatomic, strong, nullable) UIColor  *shopBtnIconColor;


/**
 * the font of remind error label in emoji detail viewcontroller
 */
@property (nonatomic, strong, nullable) UIFont   *remindLabelFont;

/**
 * the color of remind error label in emoji detail viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor  *remindLabelColor;

/**
 * the font of remind error label in shop viewcontroller
 */
@property (nonatomic, strong, nullable) UIFont   *loadFailedLabelFont;

/**
 * the color of remind error label in shop viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor  *loadFailedLabelColor;

/**
 * the title font of reload button in shop viewcontroller
 */
@property (nonatomic, strong, nullable) UIFont   *reloadBtnFont;

/**
 * the title color of reload button in shop viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor  *reloadBtnColor;

/**
 *  the color of `sort` button in my stickers viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor *orderBtnColor;

/**
 *  the color of `done` button in my stickers viewcontroller
 */
@property (nonatomic, strong, nullable) UIColor *finishBtnColor;

/**
 *  the background color of remind banned view
 */
@property (nonatomic, strong, nullable) UIColor *packageBannedBgColor;
/**
 *  the title color of remind banned label
 */
@property (nonatomic, strong, nullable) UIColor *packageBannedTextColor;
/**
 *  the font of remind banned label
 */
@property (nonatomic, strong, nullable) UIFont   *packageBannedTextFont;
/**
 *  the height of emoji keyboard
 *  if (keyboardHeight > 0) {
        the height of emoji keyboard = keyboardHeight
    }else{
        the height of emoji keyboard = the height of system keyboard
    }
 */
@property (nonatomic, assign) CGFloat  keyboardHeight;
@end
