#!/bin/bash
#!/usr/bin/php

# 流程
# 1. 修改 Frameworks 文件夹路径
# 2. 删除敏感信息
# 2. 处理 所有本地库
# 3. 处理 Podfile

# 获取 project.pbxproj 路径，并修改权限
Project="RCloudMessage.xcodeproj/project.pbxproj"
chmod 777 ${Project}

# 1.修改 Frameworks 文件夹路径
sed -i '' -e '/path = RongCloudTests;/d' ${Project}

# 删除脚本 sh xcodebuild.sh
sed -i '' -e "/\/\* ShellScript \*\/ = {/,/};/d" ${Project}

# 2. 删除敏感信息
sed -i "" -e 's?^#define BUGLY_APPID.*$?#define BUGLY_APPID @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define RONGCLOUD_STATUS_SERVER.*$?#define RONGCLOUD_STATUS_SERVER @\"\"?' RCloudMessage/AppDelegate.m

# 3. 处理所有本地库
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
sed -i '' -e "/jrmf_n.cer/d"  ${Project}
sed -i '' -e "/jrmf_o.cer/d"  ${Project}
sed -i '' -e "/jrmf_p.cer/d"  ${Project}
sed -i '' -e "/JrmfWalletKit.framework/d"  ${Project}
sed -i '' -e "/JrmfPacketKit.framework/d"  ${Project}
sed -i '' -e "/JYangToolKit.framework/d"  ${Project}
sed -i '' -e "/WalletResource.bundle/d"  ${Project}


sed -i '' -e "/Blink.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.framework/d"  ${Project}
sed -i '' -e "/RongCallLib.framework/d"  ${Project}
sed -i '' -e "/RongIMLib.framework/d"  ${Project}
sed -i '' -e "/RongIMKit.framework/d"  ${Project}
sed -i '' -e "/RongRTCLib.framework/d"  ${Project}

sed -i '' -e "/RCColor.plist/d"  ${Project}
sed -i '' -e "/RCConfig.plist/d"  ${Project}

sed -i '' -e "/RongCloud.bundle/d"  ${Project}
sed -i '' -e "/RongCloudKit.strings in Resources/d"  ${Project}

sed -i '' -e "/libopencore-amrnb.a/d"  ${Project}
sed -i '' -e "/libopencore-amrwb.a/d"  ${Project}
sed -i '' -e "/libvo-amrwbenc.a/d"  ${Project}

sed -i '' -e "/\/\* RCSticker \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongSticker.framework in Frameworks/d"  ${Project}
sed -i '' -e "/RongSticker.bundle in Resources/d"  ${Project}
sed -i '' -e "/RongSticker.strings in Resources/d"  ${Project}

sed -i '' -e "/\/\* PTT \*\/ = {/,/};/d"  ${Project}

sed -i '' -e "/RongSight.framework/d"  ${Project}



# 移除本地使用的库
rm -rf ./framework/AlipaySDK
rm -rf ./framework/JrmfIMLib

rm -rf ./framework/AgoraRtcEngineKit.framework
rm -rf ./framework/Bailingquic.framework
rm -rf ./framework/Blink.framework
rm -rf ./framework/bqmm
rm -rf ./framework/Emoji.plist
rm -rf ./framework/en.lproj
rm -rf ./framework/ifly
rm -rf ./framework/iflyMSC.framework
rm -rf ./framework/libopencore-amrnb.a
rm -rf ./framework/RCColor.plist
rm -rf ./framework/RCConfig.plist
rm -rf ./framework/RongCallKit.framework
rm -rf ./framework/RongCallLib.framework
rm -rf ./framework/RongCloud.bundle
rm -rf ./framework/RongCloudiFly.bundle
rm -rf ./framework/RongiFlyKit.framework
rm -rf ./framework/RongIMKit.framework
rm -rf ./framework/RongIMLib.framework
rm -rf ./framework/zh-Hans.lproj
rm -rf ./framework/GPUImage.framework
rm -rf ./framework/libopencore-amrwb.a
rm -rf ./framework/libvo-amrwbenc.a
rm -rf ./framework/RCSticker
rm -rf ./framework/RongRTCLib.framework
rm -rf ./framework/RongSight.framework
rm -rf ./framework/RongRTCEngine.framework
rm -rf ./framework/PTT
rm -rf ./framework/RongPTTLib.framework


# 变量和=间不能有空格
pwd
sed -i '' -e 's/#/''/g'  Podfile
sed -i '' -e '/RongCloud/s/2.10.1/'${Version}'/g' Podfile
pod update

