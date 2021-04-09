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
sed -i "" -e 's?^#define DORAEMON_APPID.*$?#define DORAEMON_APPID @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define BUGLY_APPID.*$?#define BUGLY_APPID @\"\"?' RCloudMessage/AppDelegate.m
sed -i "" -e 's?^#define RONGCLOUD_STATUS_SERVER.*$?#define RONGCLOUD_STATUS_SERVER @\"\"?' RCloudMessage/AppDelegate.m

# 3. 处理所有本地库


sed -i '' -e "/Emoji.plist/d"  ${Project}
sed -i '' -e "/GPUImage.framework/d"  ${Project}

sed -i '' -e "/\/\* ifly \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongiFlyKit.framework/d"  ${Project}
sed -i '' -e "/iflyMSC.framework/d"  ${Project}
sed -i '' -e "/RongCloudiFly.bundle/d"  ${Project}


# im start

sed -i '' -e "/RongIMLibCore.framework/d"  ${Project}
sed -i '' -e "/RongChatRoom.framework/d"  ${Project}
sed -i '' -e "/RongCustomerService.framework/d"  ${Project}
sed -i '' -e "/RongPublicService.framework/d"  ${Project}
sed -i '' -e "/RongLocation.framework/d"  ${Project}
sed -i '' -e "/RongDiscussion.framework/d"  ${Project}

sed -i '' -e "/RongIMLib.framework/d"  ${Project}

sed -i '' -e "/RongIMKit.framework/d"  ${Project}

sed -i '' -e "/RCConfig.plist/d"  ${Project}

sed -i '' -e "/RongCloud.bundle/d"  ${Project}
sed -i '' -e "/RongCloudKit.strings in Resources/d"  ${Project}
sed -i '' -e "/RCColor.plist/d"  ${Project}

sed -i '' -e "/libopencore-amrnb.a/d"  ${Project}
sed -i '' -e "/libopencore-amrwb.a/d"  ${Project}
sed -i '' -e "/libvo-amrwbenc.a/d"  ${Project}
# im end

# rtc start
sed -i '' -e "/Blink.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.framework/d"  ${Project}
sed -i '' -e "/RongCallLib.framework/d"  ${Project}
sed -i '' -e "/RongRTCLib.framework/d"  ${Project}
sed -i '' -e "/RongCallKit.strings in Resources/d"  ${Project}
sed -i '' -e "/RongCallKit.bundle in Resources/d"  ${Project}
# rtc end


sed -i '' -e "/\/\* RCSticker \*\/ = {/,/};/d"  ${Project}
sed -i '' -e "/RongSticker.framework/d"  ${Project}
sed -i '' -e "/RongSticker.framework in Frameworks/d"  ${Project}
sed -i '' -e "/RongSticker.bundle in Resources/d"  ${Project}
sed -i '' -e "/RongSticker.strings in Resources/d"  ${Project}

sed -i '' -e "/RongSight.framework/d"  ${Project}



# 移除本地使用的库
rm -rf ./framework/RongIMLib
rm -rf ./framework/RongIMKit
rm -rf ./framework/RongSticker
rm -rf ./framework/RongSight
rm -rf ./framework/RongCallLib
rm -rf ./framework/RongCallKit
rm -rf ./framework/RongRTCLib
rm -rf ./framework/RongiFlyKit

# 变量和=间不能有空格
pwd
sed -i '' -e 's/#/''/g'  Podfile
sed -i '' -e '/RongCloud/s/2.10.1/'${Version}'/g' Podfile
#pod update

