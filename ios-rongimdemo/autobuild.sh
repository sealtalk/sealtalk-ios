#!/bin/sh

#  build-imdemo.sh
#  RCloudMessage
#
#  Created by xugang on 4/8/15.
#  Copyright (c) 2015 RongCloud. All rights reserved.

configuration="Release"
DEV_FLAG=""
VER_FLAG=""
RELEASE_FLAG="Stable"
ENV_FLAG="pro"
PROFILE_FLAG="distribution"
BIN_DIR="bin"
BUILD_DIR="build"
CUR_PATH=$(pwd)

for i in "$@"
do
PFLAG=`echo $i|cut -b1-2`
PPARAM=`echo $i|cut -b3-`
if [ $PFLAG == "-b" ]
then
DEV_FLAG=$PPARAM
elif [ $PFLAG == "-v" ]
then
VER_FLAG=$PPARAM
elif [ $PFLAG == "-s" ]
then
SEALTALK_VER_FLAG=$PPARAM
elif [ $PFLAG == "-r" ]
then
if [ $PPARAM = "dev" ]; then
    RELEASE_FLAG="Dev"
else
    RELEASE_FLAG="Stable"
fi
elif [ $PFLAG == "-t" ]
then
CUR_TIME=$PPARAM
elif [ $PFLAG == "-d" ]
then
ENV_FLAG=$PPARAM
elif [ $PFLAG == "-p" ]
then
PROFILE_FLAG=$PPARAM
elif [ $PFLAG == "-k" ]
then
MANUAL_DEMO_APPKEY=$PPARAM
elif [ $PFLAG == "-u" ]
then
MANUAL_DEMO_SERVER_URL=$PPARAM
elif [ $PFLAG == "-n" ]
then
MANUAL_NAVI_SERVER_URL=$PPARAM
elif [ $PFLAG == "-f" ]
then
MANUAL_FILE_SERVER_URL=$PPARAM
elif [ $PFLAG == "-a" ]
then
MANUAL_STATS_SERVER_URL=$PPARAM
elif [ $PFLAG == "-o" ]
then
VOIP_FLAG=$PPARAM
fi
done

if [ -n "${MANUAL_DEMO_APPKEY}" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"'$MANUAL_DEMO_APPKEY'"/g' ./RCloudMessage/AppDelegate.m
elif [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"e0x9wycfx7flq"/g' ./RCloudMessage/AppDelegate.m
elif [ ${ENV_FLAG} == "dev_backup" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"e0x9wycfx7flq"/g' ./RCloudMessage/AppDelegate.m
elif [ ${ENV_FLAG} == "pre" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"c9kqb3rdkbb8j"/g' ./RCloudMessage/AppDelegate.m
fi

if [ -n "${MANUAL_DEMO_SERVER_URL}" ]; then
    if [[ $MANUAL_DEMO_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's?http://api.sealtalk.im?'$MANUAL_DEMO_SERVER_URL'?g' ./RCloudMessage/AFHttpTool.m
        sed -i '' -e 's?http://api.sealtalk.im?'$MANUAL_DEMO_SERVER_URL'?g' ./SealTalkShareExtension/RCDShareChatListController.m
    else
        sed -i '' -e 's?http://api.sealtalk.im?http://'$MANUAL_DEMO_SERVER_URL'?g' ./RCloudMessage/AFHttpTool.m
        sed -i '' -e 's?http://api.sealtalk.im?http://'$MANUAL_DEMO_SERVER_URL'?g' ./SealTalkShareExtension/RCDShareChatListController.m
    fi

    if [[ $MANUAL_DEMO_SERVER_URL =~ ^https ]]; then
        sed -i '' -e 's/api.sealtalk.im/'${MANUAL_DEMO_SERVER_URL/https\:\/\//""}'/g' ./RCloudMessage/Info.plist
    elif [[ $MANUAL_DEMO_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's/api.sealtalk.im/'${MANUAL_DEMO_SERVER_URL/http\:\/\//""}'/g' ./RCloudMessage/Info.plist
    else
        sed -i '' -e 's/api.sealtalk.im/'$MANUAL_DEMO_SERVER_URL'/g' ./RCloudMessage/Info.plist
    fi
elif [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e 's?http://api.sealtalk.im?http://api.hitalk.im?g' ./RCloudMessage/AFHttpTool.m
    sed -i '' -e 's?http://api.sealtalk.im?http://api.hitalk.im?g' ./SealTalkShareExtension/RCDShareChatListController.m
    sed -i '' -e 's/api.sealtalk.im/api.hitalk.im/g' ./RCloudMessage/Info.plist
elif [ ${ENV_FLAG} == "dev_backup" ]; then
    sed -i '' -e 's?http://api.sealtalk.im?http://api.hitalk.im?g' ./RCloudMessage/AFHttpTool.m
    sed -i '' -e 's?http://api.sealtalk.im?http://api.hitalk.im?g' ./SealTalkShareExtension/RCDShareChatListController.m

    sed -i '' -e 's/api.sealtalk.im/api.hitalk.im/g' ./RCloudMessage/Info.plist
elif [ ${ENV_FLAG} == "pre" ]; then
    sed -i '' -e 's?http://api.sealtalk.im?http://apiqa.rongcloud.net?g' ./RCloudMessage/AFHttpTool.m
    sed -i '' -e 's?http://api.sealtalk.im?http://apiqa.rongcloud.net?g' ./SealTalkShareExtension/RCDShareChatListController.m
    sed -i '' -e 's/api.sealtalk.im/apiqa.rongcloud.net/g' ./RCloudMessage/Info.plist
fi

if [ -n "${MANUAL_NAVI_SERVER_URL}" ]; then
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_IM_NAVI/NSString \*RONGCLOUD_IM_NAVI/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e '/RONGCLOUD_IM_NAVI/s?nav.cn.ronghub.com?'$MANUAL_NAVI_SERVER_URL'?g' ./RCloudMessage/AppDelegate.m
    if [[ $MANUAL_NAVI_SERVER_URL =~ ^https ]]; then
        sed -i '' -e 's/nav.cn.ronghub.com/'${MANUAL_NAVI_SERVER_URL/https\:\/\//""}'/g' ./RCloudMessage/Info.plist
    elif [[ $MANUAL_NAVI_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's/nav.cn.ronghub.com/'${MANUAL_NAVI_SERVER_URL/http\:\/\//""}'/g' ./RCloudMessage/Info.plist
    else
        sed -i '' -e 's/nav.cn.ronghub.com/'$MANUAL_NAVI_SERVER_URL'/g' ./RCloudMessage/Info.plist
    fi
fi

if [ -n "${MANUAL_FILE_SERVER_URL}" ]; then
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_FILE_SERVER/NSString \*RONGCLOUD_FILE_SERVER/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/\[\[RCIMClient sharedRCIMClient\] setServerInfo/\[\[RCIMClient sharedRCIMClient\] setServerInfo/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_STATS_SERVER/NSString \*RONGCLOUD_STATS_SERVER/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/\[\[RCIMClient sharedRCIMClient\] setStatisticServer/\[\[RCIMClient sharedRCIMClient\] setStatisticServer/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e '/RONGCLOUD_FILE_SERVER/s?@"img.cn.ronghub.com"?@"'$MANUAL_FILE_SERVER_URL'"?g' ./RCloudMessage/AppDelegate.m
    if [[ $MANUAL_FILE_SERVER_URL =~ ^https ]]; then
        sed -i '' -e 's/rongcloud-image.ronghub.com/'${MANUAL_FILE_SERVER_URL/https\:\/\//""}'/g' ./RCloudMessage/Info.plist
        sed -i '' -e 's/rongcloud-file.cn.ronghub.com/'${MANUAL_FILE_SERVER_URL/https\:\/\//""}'/g' ./RCloudMessage/Info.plist
    elif [[ $MANUAL_FILE_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's/rongcloud-image.ronghub.com/'${MANUAL_FILE_SERVER_URL/http\:\/\//""}'/g' ./RCloudMessage/Info.plist
        sed -i '' -e 's/rongcloud-file.ronghub.com/'${MANUAL_FILE_SERVER_URL/http\:\/\//""}'/g' ./RCloudMessage/Info.plist
    else
        sed -i '' -e 's/rongcloud-image.ronghub.com/'$MANUAL_FILE_SERVER_URL'/g' ./RCloudMessage/Info.plist
        sed -i '' -e 's/rongcloud-file.ronghub.com/'$MANUAL_FILE_SERVER_URL'/g' ./RCloudMessage/Info.plist
    fi
fi

if [ -n "${MANUAL_STATS_SERVER_URL}" ]; then
    sed -i '' -e '/RONGCLOUD_STATS_SERVER/s?stats.cn.ronghub.com?'$MANUAL_STATS_SERVER_URL'?g' ./RCloudMessage/AppDelegate.m
    if [[ $MANUAL_STATS_SERVER_URL =~ ^https ]]; then
        sed -i '' -e 's/stats.cn.ronghub.com/'${MANUAL_STATS_SERVER_URL/https\:\/\//""}'/g' ./RCloudMessage/Info.plist
    elif [[ $MANUAL_STATS_SERVER_URL =~ ^http ]]; then
        sed -i '' -e 's/stats.cn.ronghub.com/'${MANUAL_STATS_SERVER_URL/http\:\/\//""}'/g' ./RCloudMessage/Info.plist
    else
        sed -i '' -e 's/nstats.cn.ronghub.com/'$MANUAL_STATS_SERVER_URL'/g' ./RCloudMessage/Info.plist
    fi
fi

if [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e '/SERVICE_ID/s/@"KEFU146001495753714"/@"KEFU145760441681012"/g' ./RCloudMessage/RCDMeTableViewController.m
    sed -i '' -e 's/nav.cn.ronghub.com/navxq.rongcloud.net/g' ./RCloudMessage/Info.plist
elif [ ${ENV_FLAG} == "dev_backup" ]; then
    sed -i '' -e '/SERVICE_ID/s/@"KEFU146001495753714"/@"KEFU145760441681012"/g' ./RCloudMessage/RCDMeTableViewController.m
    sed -i '' -e 's/nav.cn.ronghub.com/navzhouyu.cn.rongcloud.net/g' ./RCloudMessage/Info.plist
elif [ ${ENV_FLAG} == "pre" ]; then
    sed -i '' -e '/SERVICE_ID/s/@"KEFU146001495753714"/@"KEFU147980517733135"/g' ./RCloudMessage/RCDMeTableViewController.m
    sed -i '' -e 's/nav.cn.ronghub.com/navqa.cn.ronghub.com/g' ./RCloudMessage/Info.plist
elif [ ${ENV_FLAG} == "pri" ]; then
    sed -i '' -e '/SERVICE_ID_XIAONENG1/s/@"kf_4029_1483495902343"/@"zf_1000_1481459114694"/g' ./RCloudMessage/RCDMeTableViewController.m
    sed -i '' -e '/SERVICE_ID_XIAONENG2/s/@"op_1000_1483495280515"/@"zf_1000_1480591492399"/g' ./RCloudMessage/RCDMeTableViewController.m
fi

if [ ${ENV_FLAG} == "pri" ]; then
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_IM_NAVI/NSString \*RONGCLOUD_IM_NAVI/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_FILE_SERVER/NSString \*RONGCLOUD_FILE_SERVER/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/\[\[RCIMClient sharedRCIMClient\] setServerInfo/\[\[RCIMClient sharedRCIMClient\] setServerInfo/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/ NSString \*RONGCLOUD_STATS_SERVER/NSString \*RONGCLOUD_STATS_SERVER/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/\[\[RCIMClient sharedRCIMClient\] setStatisticServer/\[\[RCIMClient sharedRCIMClient\] setStatisticServer/g' ./RCloudMessage/AppDelegate.m
    if [ -z "${MANUAL_DEMO_APPKEY}" ] && [ -z "${MANUAL_DEMO_SERVER_URL}" ] &&  [ -z "${MANUAL_NAVI_SERVER_URL}" ] && [ -z "${MANUAL_FILE_SERVER_URL}" ]; then
        sed -i '' -e 's/RCDPrivateCloudManualMode 0/\RCDPrivateCloudManualMode 1/g' ./RCloudMessage/Utilities/RCDCommonDefine.h
    fi
    cp -af RCloudMessage/private_test.plist RCloudMessage/info.plist
else
    sed -i '' -e '/for private cloud test/,/RONGCLOUD_STATS_SERVER\];/d' ./RCloudMessage/AppDelegate.m
fi

if [ ${DEV_FLAG} == "debug" ]
then
sed -i '' -e '/DEMO_VERSION_BOARD/s/@""/@"http:\/\/bj.rongcloud.net\/list.php"/g' ./RCloudMessage/RCDMeTableViewController.m
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Info.plist
else
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Info.plist
sed -i '' -e 's/RCDDebugTestFunction 1/\RCDDebugTestFunction 0/g' ./RCloudMessage/Utilities/RCDCommonDefine.h
# 去除demo中PTT相关依赖
sed -i '' -e '/RongCloudPTT/d' ./RCloudMessage.xcodeproj/project.pbxproj
sed -i '' -e '/RongPTTKit/d' ./RCloudMessage.xcodeproj/project.pbxproj
sed -i '' -e '/RongPTTLib/d' ./RCloudMessage.xcodeproj/project.pbxproj
fi

# 替换友盟 Key
sed -i '' -e '/UMENG_APPKEY/s/@"563755cbe0f55a5cb300139c"/@"5637263b67e58e772200248f"/g' ./RCloudMessage/AppDelegate.m

BUILD_APP_PROFILE=""
BUILD_SHARE_PROFILE=""

BUILD_CODE_SIGN_IDENTITY="iPhone Distribution: Beijing Rong Cloud Network Technology CO., LTD"

echo $VER_FLAG

sed -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./RCloudMessage/Info.plist

sed -i "" -e '/SealTalk Version/{n;s/[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}/'"$SEALTALK_VER_FLAG"'/; }' ./RCloudMessage/Info.plist

sed -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist

sed -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist

echo "Copy 3rd framework start."
if [ -d "../ios-3rd-vendor/jrmf/AlipaySDK" ]; then
rm -rf ./framework/AlipaySDK
cp -rf ../ios-3rd-vendor/jrmf/AlipaySDK ./framework/
fi
if [ -d "../ios-3rd-vendor/jrmf/JrmfIMLib" ]; then
rm -rf ./framework/JrmfIMLib
cp -rf ../ios-3rd-vendor/jrmf/JrmfIMLib ./framework/
fi
if [ -d "../ios-3rd-vendor/ifly" ]; then
rm -rf ./framework/ifly
cp -rf ../ios-3rd-vendor/ifly ./framework/
fi
if [ -d "../ios-3rd-vendor/bqmm" ]; then
rm -rf ./framework/bqmm
cp -rf ../ios-3rd-vendor/bqmm ./framework/
fi
echo "Copy 3rd framework end."

PROJECT_NAME="RCloudMessage.xcodeproj"
targetName="SealTalk"
TARGET_DECIVE="iphoneos"

rm -rf DerivedData
rm -rf "$BIN_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$BUILD_DIR"
xcodebuild clean -alltargets

echo "Copy 3rd framework start."
if [ -d "../ios-3rd-vendor/jrmf/AlipaySDK" ]; then
rm -rf ./framework/AlipaySDK
cp -rf ../ios-3rd-vendor/jrmf/AlipaySDK ./framework/
fi
if [ -d "../ios-3rd-vendor/jrmf/JrmfIMLib" ]; then
rm -rf ./framework/JrmfIMLib
cp -rf ../ios-3rd-vendor/jrmf/JrmfIMLib ./framework/
fi
if [ -d "../ios-3rd-vendor/ifly" ]; then
rm -rf ./framework/ifly
cp -rf ../ios-3rd-vendor/ifly ./framework/
fi
if [ -d "../ios-3rd-vendor/bqmm" ]; then
rm -rf ./framework/bqmm
cp -rf ../ios-3rd-vendor/bqmm ./framework/
fi
echo "Copy 3rd framework end."

echo "***开始build iphoneos文件***"
  xcodebuild -scheme "${targetName}" archive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -configuration "${configuration}" APP_PROFILE="${BUILD_APP_PROFILE}" SHARE_PROFILE="${BUILD_SHARE_PROFILE}"
  xcodebuild -exportArchive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -exportOptionsPlist "archive.plist" -exportPath "./${BIN_DIR}"
  mv ./${BIN_DIR}/${targetName}.ipa ${CUR_PATH}/${BIN_DIR}/${targetName}_v${VER_FLAG}_${DEV_FLAG}_${CUR_TIME}.ipa
  cp -af ./${BUILD_DIR}/${targetName}.xcarchive/dSYMs/${targetName}.app.dSYM ${CUR_PATH}/${BIN_DIR}/${targetName}_v${VER_FLAG}_${DEV_FLAG}_${CUR_TIME}.app.dSYM

echo "***编译结束***"

# 替换友盟 Key
sed -i '' -e '/UMENG_APPKEY/s/@"5637263b67e58e772200248f"/@"563755cbe0f55a5cb300139c"/g' ./RCloudMessage/AppDelegate.m
