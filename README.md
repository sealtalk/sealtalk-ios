# SealTalk-iOS

iOS App of SealTalk powered by RongCloud. 

基于融云 IM SDK 应用程序 - 嗨豹。

## 运行 SealTalk-iOS

SealTalk 从 2.0.0 版本开始改用 cocoaPods 管理融云 SDK 库和其他第三方库，下载完源码后，按照下面步骤操作

1.终端进入 Podfile 目录

2.更新本地 CocoaPods 的本地仓库，终端执行下面命令

```
$ pod repo update
```
3.下载 Podfile 中的依赖库，终端执行下面命令

```
$ pod install
```
**注意：**

如果你使用的 SealTalk 是 2.2.3 及之前版本，请参考如下 SealTalk 版本与 SDK 版本对照表，修改 SealTalk 的 Podfile ：

版本对照表：

| SealTalk 版本 | SDK 版本 |
| :------: | :------------- |
|  2.2.3  |  2.10.2   |
|  2.2.2  |  2.10.1   |
|  2.2.1  |  2.10.0  |
|  2.2.0  |  2.9.25  |
|  2.1.2  |  2.9.24  |
|  2.1.1 |  2.9.23   |
|  2.1.0  |  2.9.22   |
|  2.0.0  |  2.9.20   |

Podfile 文件：

```
source 'https://github.com/CocoaPods/Specs.git'
target 'SealTalk' do
  use_frameworks!
  pod 'Masonry', '1.1.0'
  pod 'AFNetworking', '3.2.1'
  pod 'FMDB','2.7.5'
  pod 'GCDWebServer/Core','3.5.2'
  pod 'GCDWebServer/WebDAV','3.5.2'
  pod 'GCDWebServer/WebUploader','3.5.2'
  pod 'ZXingObjC', '3.6.5'
  pod 'MBProgressHUD', '1.1.0'
  pod 'SSZipArchive', '2.2.2'
  pod 'SDWebImage', '5.0.6'
  pod 'Bugly', '2.5.0'
  pod 'WechatOpenSDK', '1.8.4'
  pod 'RongCloudIM/IMLib', '2.10.4' #参考上面对照表修改成 SDK 指定版本
  pod 'RongCloudIM/IMKit', '2.10.4' #参考上面对照表修改成 SDK 指定版本
  pod 'RongCloudIM/RongSticker', '2.10.4' #参考上面对照表修改成 SDK 指定版本
  pod 'RongCloudIM/Sight', '2.10.4' #参考上面对照表修改成 SDK 指定版本
  pod 'RongCloudRTC/RongCallLib', '2.10.4' #参考上面对照表修改成 SDK 指定版本
  pod 'RongCloudRTC/RongCallKit', '2.10.4' #参考上面对照表修改成 SDK 指定版本
end
```
## 代码结构
- Section: 主要是包含会话、通讯录、发现、我、登录、搜索等 UI 模块相关的代码
- Services: 主要包含用户，好友，群组等功能的 Server 请求与本地存储相关交互
- Categories: 一些类目
- Utils: 内部封装的一些工具类，如基于 AFNetWoking 封装的网络请求工具类，基于 FMDB 封装的数据库操作的工具类，等
- Supporting Files: 语言包，资源图片



## 安装 ipa 包

[下载 ipa 包](http://rongcloud.cn/sealtalk)


## 支持
 - [集成文档](https://www.rongcloud.cn/docs/index.html)
 - [知识库](http://support.rongcloud.cn/)
 - [工单](https://developer.rongcloud.cn/signin?returnUrl=%2Fticket),需要登录融云开发者账号


### 比你想象的更强大, 敬请期待更多精彩! 
[融云官网](http://rongcloud.cn/downloads)

