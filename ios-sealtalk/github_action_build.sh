#!/bin/sh
#@author qixinbing

#github 配置 Actions 自动执行该脚本
#用来检测项目源码 x86_64 架构是否可以编译成功；真机架构的编译需要证书，无法把打包证书配置到 github 上
#如果无法编译成功则需要检查一下 PodShell.sh 是否有缺漏的地方

pod repo update

pod update --no-repo-update

xcodebuild -workspace RCloudMessage.xcworkspace -scheme SealTalk -configuration Debug  -sdk iphonesimulator -arch x86_64
