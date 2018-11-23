#!/bin/bash
#!/usr/bin/php

# 流程
# 1. 修改 Frameworks 文件夹路径
# 2. 修改 SortForTime 路径问题
# 3. 处理 MBProgressHUD FMDatabase KxMenu SDWebImage 文件及引用
# 4. 处理 所有本地库
# 5. 创建 Podfile
# 6. 修改头文件

# 获取 project.pbxproj 路径，并修改权限
Project="RCloudMessage.xcodeproj/project.pbxproj"
chmod 777 ${Project}

# 删除脚本 sh xcodebuild.sh
sed -i '' -e "/\/\* ShellScript \*\/ = {/,/};/d" ${Project}

# 修改 Frameworks 文件夹路径
sed -i '' -e '/path = RongCloudTests;/d' ${Project}

# 修改 SortForTime 路径问题
sed -i '' -e "s:SDWebImage/SortForTime:SortForTime:" ${Project}
 
# 删除引用
sed -i '' -e "/\/\* MBProgressHUD \*\/ = {/,/};/d" ${Project}
sed -i '' -e "/MBProgressHUD*/d" ${Project}


sed -i '' -e "/\/\* DB \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/FMDB.h*/d; /FMDatabase*/d; /FMResultSet*/d" ${Project}
sed -i '' -e "/\/\* DB \*\//d"  ${Project}

sed -i '' -e "/\/\* KxMenu \*\/ = {/,/};/d" ${Project}
sed -i '' -e "/KxMenu*/d" ${Project}

sed -i '' -e "/\/\* SDWebImage \*\/ = {/,/};/d" ${Project}
sed -i '' -e "/MKAnnotationView+WebCache*/d; /NSData+ImageContentType*/d; /SDWebImage*/d; /UIButton+WebCache*/d; /UIImage+GIF*/d; /UIImage+MultiFormat*/d; /UIImage+WebP*/d; /UIImageView+HighlightedWebCache*/d; /UIImageView+WebCache*/d; /UIView+WebCacheOperation*/d; /SDImageCache*/d" ${Project}


# 删除 DB 文件夹
DBFiles="RCloudMessage/Utilities/DB"
if [ -d ${DBFiles} ]; then
    #statements
    rm -rf ${DBFiles}
fi

# 删除 KxMenu 文件夹
KxMenuFiles="RCloudMessage/Utilities/KxMenu"
if [ -d ${KxMenuFiles} ]; then
    #statements
    rm -rf ${KxMenuFiles}
fi

# 删除 MBProgressHUD 文件夹
MBProgressHUDFiles="RCloudMessage/Utilities/MBProgressHUD"
if [ -d ${MBProgressHUDFiles} ]; then
    rm -rf ${MBProgressHUDFiles}
fi

# 从 SDWebImage 文件夹中移出 SortForTime.h 和 SortForTime.m
SortForTimeHeader="RCloudMessage/Utilities/SDWebImage/SortForTime.h"
if [ -f ${SortForTimeHeader} ]; then
     #statements
     mv ${SortForTimeHeader} RCloudMessage/Utilities/
 fi 

 SortForTimeM="RCloudMessage/Utilities/SDWebImage/SortForTime.m"
if [ -f ${SortForTimeM} ]; then
     #statements
     mv ${SortForTimeM} RCloudMessage/Utilities/
 fi 


# 删除 SDWebImage 文件夹
SDWebImageFiles="RCloudMessage/Utilities/SDWebImage"
if [ -d ${SDWebImageFiles} ]; then
    rm -rf ${SDWebImageFiles}
fi


# 4. 处理所有本地库
sed -i '' -e "/\/\* AlipaySDK \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/AlipaySDK.bundle/d"  ${Project}
sed -i '' -e "/AlipaySDK.framework/d"  ${Project}

sed -i '' -e "/Bailingquic.framework/d"  ${Project}

sed -i '' -e "/\/\* BQMM \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/BQMMRongCloudExt.framework/d"  ${Project}
sed -i '' -e "/BQMM.bundle/d"  ${Project}


sed -i '' -e "/Emoji.plist/d"  ${Project}

sed -i '' -e "/GPUImage.framework/d"  ${Project}

sed -i '' -e "/\/\* ifly \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongiFlyKit.framework/d"  ${Project}
sed -i '' -e "/iflyMSC.framework/d"  ${Project}
sed -i '' -e "/RongCloudiFly.bundle/d"  ${Project}

sed -i '' -e "/\/\* JrmfIMLib \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/JrmfInfo.strings in Resources/d"  ${Project}
sed -i '' -e "/JResource.bundle/d"  ${Project}
sed -i '' -e "/jrmf.cer/d"  ${Project}
sed -i '' -e "/JrmfWalletKit.framework/d"  ${Project}
sed -i '' -e "/JrmfPacketKit.framework/d"  ${Project}
sed -i '' -e "/JYangToolKit.framework/d"  ${Project}
sed -i '' -e "/WalletResource.bundle/d"  ${Project}

sed -i '' -e "/Blink.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.framework/d"  ${Project}
sed -i '' -e "/RongCallLib.framework/d"  ${Project}
sed -i '' -e "/RongIMLib.framework/d"  ${Project}
sed -i '' -e "/RongIMKit.framework/d"  ${Project}

sed -i '' -e "/RCColor.plist/d"  ${Project}
sed -i '' -e "/RCConfig.plist/d"  ${Project}

sed -i '' -e "/RongCloud.bundle/d"  ${Project}
sed -i '' -e "/RongCloudKit.strings in Resources/d"  ${Project}

sed -i '' -e "/libopencore-amrnb.a/d"  ${Project}


# 移除本地使用的库
rm -rf ./framework/AgoraRtcEngineKit.framework
rm -rf ./framework/AlipaySDK
rm -rf ./framework/Bailingquic.framework
rm -rf ./framework/Blink.framework
rm -rf ./framework/bqmm
rm -rf ./framework/Emoji.plist
rm -rf ./framework/en.lproj
rm -rf ./framework/ifly
rm -rf ./framework/iflyMSC.framework
rm -rf ./framework/JrmfIMLib
rm -rf ./framework/libopencore-amrnb.a
# rm -rf ./framework/PTT
rm -rf ./framework/RCColor.plist
rm -rf ./framework/RCConfig.plist
rm -rf ./framework/RongCallKit.framework
rm -rf ./framework/RongCallLib.framework
rm -rf ./framework/RongCloud.bundle
rm -rf ./framework/RongCloudiFly.bundle
rm -rf ./framework/RongiFlyKit.framework
rm -rf ./framework/RongIMKit.framework
rm -rf ./framework/RongIMLib.framework
# rm -rf ./framework/RongPTTLib.framework
rm -rf ./framework/zh-Hans.lproj
rm -rf ./framework/GPUImage.framework

# 变量和=间不能有空格
Podfile="Podfile" 

# 判断这个变量代表的内容是否存在 -f 表示 file
# 使用一个定义过的变量，只要在变量名前面加美元符号即可
# 最好在使用变量时加大括号，帮助解释器识别变量边界
if [ ! -f "$Podfile" ]; then 
	# 创建文件
	touch "$Podfile" 
eles
	# 清空文件内容
	cat /dev/null > ${Podfile}
	echo "${Podfile} cleaned up."
fi


# 写Podfile入文件
echo -e "workspace 'SealTalk'

platform :ios, '8.0'

target 'SealTalk' do

    project '../ios-rongimdemo/RCloudMessage.xcodeproj'

    pod 'FMDB', '~> 2.7.2'

    pod 'KxMenu', '~> 1'

    pod 'MBProgressHUD', '~> 1.1.0'

    pod 'SDWebImage', '~> 5.0.0-beta'

    pod 'RongCloudIM', '~> 2.9.3'

    pod 'RongCloudRTC', '2.9.3'

    post_install do |installer_representation|
        installer_representation.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            end
        end
    end

end" > $Podfile


# 修改头文件 RCDForwardAlertView.m 
RCDForwardAlertViewM="./RCloudMessage/Utilities/RCDForwardAlertView.m"
chmod 777 ${RCDForwardAlertViewM}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ./RCloudMessage/Utilities/RCDForwardAlertView.m

File="./RCloudMessage/RCDFindPswViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDAddressBookTableViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDAddressBookViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDChatListViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"KxMenu.h\":#import <KxMenu/KxMenu.h>:" ${File}

File="./RCloudMessage/RCDConversationSettingTableViewHeader.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDConversationSettingTableViewHeaderItem.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDEditUserNameViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDFindPswViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDGroupTableViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDGroupViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDLoginViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDMeInfoTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDMessageNotifySettingTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDMeTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCloudMessage/RCDRegisterViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/RCDSearchFriendViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RealTimeLocation/RCAnnotation/RCAnnotationView.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RealTimeLocation/HeadCollectionView.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RealTimeLocation/RealTimeLocationViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDAddFriendViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDataBaseManager.m"
chmod 777 ${File}
sed -i "" "s:#import \"FMDatabase.h\":#import <FMDB/FMDatabase.h>:" ${File}
sed -i "" "s:#import \"FMDatabaseQueue.h\":#import <FMDB/FMDatabaseQueue.h>:" ${File}

File="./RCDBaseSettingTableViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDBlackListCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDContactSelectedCollectionViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDContactSelectedTableViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDContactSelectedTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDContactViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDCreateGroupViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDFrienfRemarksViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDGroupAnnouncementViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDGroupMembersTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDGroupSettingsTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDPersonDetailViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCDPrivateSettingsTableViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDSearchResultViewCell.m"
chmod 777 ${File}
sed -i "" "s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}

File="./RCDSettingServerUrlViewController.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:" ${File}

File="./RCloudMessage/AppDelegate.m"
chmod 777 ${File}
sed -i "" "s:#import \"MBProgressHUD.h\":#import <MBProgressHUD/MBProgressHUD.h>:;s:#import \"UIImageView+WebCache.h\":#import \<SDWebImage/SDWebImage.h\>:" ${File}


