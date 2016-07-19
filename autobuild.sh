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
BIN_DIR="bin"
ENV_FLAG="pro"
PROFILE_FLAG="distribution"
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
elif [ $PFLAG == "-o" ]
then
VOIP_FLAG=$PPARAM
fi
done

if [ -n "${MANUAL_DEMO_APPKEY}" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"'$MANUAL_DEMO_APPKEY'"/g' ./RCloudMessage/AppDelegate.m
elif [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e '/RONGCLOUD_IM_APPKEY/s/@"n19jmcy59f1q9"/@"e0x9wycfx7flq"/g' ./RCloudMessage/AppDelegate.m
fi

if [ -n "${MANUAL_DEMO_SERVER_URL}" ]; then
    sed -i '' -e 's/@"http:\/\/api.sealtalk.im\/"/@"http:\/\/'$MANUAL_DEMO_SERVER_URL'\/"/g' ./RCloudMessage/AFHttpTool.m
elif [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e 's/@"http:\/\/api.sealtalk.im\/"/@"http:\/\/api.hitalk.im\/"/g' ./RCloudMessage/AFHttpTool.m
fi

if [ -n "${MANUAL_NAVI_SERVER_URL}" ]; then
    sed -i '' -e '/RONGCLOUD_IM_NAVI/s/@"nav.cn.ronghub.com"/@"'$MANUAL_NAVI_SERVER_URL'"/g' ./RCloudMessage/AppDelegate.m
fi

if [ -n "${MANUAL_FILE_SERVER_URL}" ]; then
    sed -i '' -e '/RONGCLOUD_FILE_SERVER/s/@"img.cn.ronghub.com"/@"'$MANUAL_FILE_SERVER_URL'"/g' ./RCloudMessage/AppDelegate.m
fi

if [ ${ENV_FLAG} == "dev" ]; then
    sed -i '' -e '/SERVICE_ID/s/@"KEFU146001495753714"/@"KEFU145760441681012"/g' ./RCloudMessage/RCDMeTableViewController.m
fi

if [ ${ENV_FLAG} == "pri" ]; then
    sed -i '' -e 's/\/\/NSString \*RONGCLOUD_IM_NAVI/NSString \*RONGCLOUD_IM_NAVI/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/NSString \*RONGCLOUD_FILE_SERVER/NSString \*RONGCLOUD_FILE_SERVER/g' ./RCloudMessage/AppDelegate.m
    sed -i '' -e 's/\/\/\[\[RCIMClient sharedRCIMClient\] setServerInfo/\[\[RCIMClient sharedRCIMClient\] setServerInfo/g' ./RCloudMessage/AppDelegate.m
else
    sed -i '' -e '/for private cloud test/,/RONGCLOUD_FILE_SERVER\];/d' ./RCloudMessage/AppDelegate.m
fi

if [ ${DEV_FLAG} == "debug" ]
then
configuration="AutoDebug"
sed -i '' -e '/DEMO_VERSION_BOARD/s/@""/@"http:\/\/bj.rongcloud.net\/list.php"/g' ./RCloudMessage/RCDMeTableViewController.m
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed  -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Info.plist
else
configuration="AutoRelease"
sed -i '' -e '/redirectNSlogToDocumentFolder/s/\/\///g' ./RCloudMessage/AppDelegate.m
sed  -i "" -e '/UIFileSharingEnabled/{n;s/false/true/; }' ./RCloudMessage/Info.plist
fi

# 替换友盟 Key
sed -i '' -e '/UMENG_APPKEY/s/@"563755cbe0f55a5cb300139c"/@"5637263b67e58e772200248f"/g' ./RCloudMessage/AppDelegate.m

if [ ${PROFILE_FLAG} == "dev" ]
then
BUILD_APP_PROFILE="f50d094a-a8b5-42ca-b00f-0e96f9d84a42"
BUILD_WATCHKIT_EXTENSION_PROFILE="376d0433-3017-40db-9d1f-6c812110674e"
BUILD_WATCHKIT_APP_PROFILE="82080891-c055-4a61-a536-cbf2b76903bb"
else
# Release可以使用Automatic
BUILD_APP_PROFILE=""
BUILD_WATCHKIT_EXTENSION_PROFILE=""
BUILD_WATCHKIT_APP_PROFILE=""
fi

BUILD_CODE_SIGN_IDENTITY="iPhone Distribution: Beijing Rong Cloud Network Technology CO., LTD"

echo $VER_FLAG

sed -i ""  -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i ""  -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i ""  -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./RCloudMessage/Info.plist
sed -i ""  -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./RCloudMessage/Info.plist

sed -i ""  -e '/SealTalk Version/{n;s/[0-9]\.[0-9]\.[0-9]\{1,2\}/'"$SEALTALK_VER_FLAG"'/; }' ./RCloudMessage/Info.plist

sed  -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed  -i "" -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed  -i "" -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist
sed -i ""  -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ App/Info.plist

sed -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Stable/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i "" -e '/CFBundleShortVersionString/{n;s/Dev/'"$RELEASE_FLAG"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist
sed -i ""  -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./融云\ Demo\ WatchKit\ Extension/Info.plist

PROJECT_NAME="RCloudMessage.xcodeproj"
targetName="SealTalk"
TARGET_DECIVE="iphoneos"
#TARGET_I386="iphonesimulator"

if [ ! -d "$BIN_DIR" ]; then
mkdir -p "$BIN_DIR"
fi

xcodebuild clean -configuration $configuration -sdk $TARGET_DECIVE APP_PROFILE="${BUILD_APP_PROFILE}" WATCHKIT_EXTENSION_PROFILE="${BUILD_WATCHKIT_EXTENSION_PROFILE}" WATCHKIT_APP_PROFILE="${BUILD_WATCHKIT_APP_PROFILE}" CODE_SIGN_IDENTITY="${BUILD_CODE_SIGN_IDENTITY}"
#xcodebuild clean -configuration $configuration -sdk $TARGET_I386

echo "***开始build iphoneos文件***"
xcodebuild -project ${PROJECT_NAME} -target $targetName -configuration "${configuration}" APP_PROFILE="${BUILD_APP_PROFILE}" WATCHKIT_EXTENSION_PROFILE="${BUILD_WATCHKIT_EXTENSION_PROFILE}" WATCHKIT_APP_PROFILE="${BUILD_WATCHKIT_APP_PROFILE}" CODE_SIGN_IDENTITY="${BUILD_CODE_SIGN_IDENTITY}"
xcrun -sdk $TARGET_DECIVE PackageApplication -v ./build/${configuration}-${TARGET_DECIVE}/${targetName}.app -o ${CUR_PATH}/${BIN_DIR}/${targetName}_v${VER_FLAG}_${CUR_TIME}_${DEV_FLAG}.ipa
cp -af ./build/${configuration}-${TARGET_DECIVE}/${targetName}.app.dSYM ${CUR_PATH}/${BIN_DIR}/${targetName}_v${VER_FLAG}_${CUR_TIME}_${DEV_FLAG}.app.dSYM

echo "***编译结束***"

# 替换友盟 Key
sed -i '' -e '/UMENG_APPKEY/s/@"5637263b67e58e772200248f"/@"563755cbe0f55a5cb300139c"/g' ./RCloudMessage/AppDelegate.m
