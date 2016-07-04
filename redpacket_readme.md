融云红包 SDK 接入文档
=================

使用融云 demo app
------------------

  `红包 SDK` 的 demo 直接嵌入进 融云 demo 2.0 中，对于原 demo 仅做了少量的修改。如果你的 app 采用 融云的 demo app 作为原型的话，这里的方法是简单快捷的。

  在融云 demo app 里做的修改添加了相关的 `#pragma mark` 标记，可以在 Xcode 快速跳转到相应的标记

###准备工作

1. clone demo:[ https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun](https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun)

  `git clone --recursive https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun`

  (这里使用了 git submodule 来管理 SDK demo 与 融云 demo app 的版本关系。原本[库](https://github.com/YunzhanghuOpen/rongcloud-demo-app-ios-v2)使用的是 master 分支，我们这里未作改动，而是新建了 RedpacketLib 分支。 submodule 会关联其中的某一个提交版本。)

  如果已有代码，需要执行

  `git pull --rebase`

  来进行更新。

  如果没能更新 submodule， 则执行

  `git submodule update --recursive`

  来更新所有的 submodule

2. 下载最新的红包 SDK 库文件 ( master 或者是 release )

  因为`红包 SDK` 在一直更新维护，所以为了不与 demo 产生依赖，所以采取了单独下载 zip 包的策略

  [https://github.com/YunzhanghuOpen/iOSRedpacketLib](https://github.com/YunzhanghuOpen/iOSRedpacketLib)

  解压后将 RedpacketLib 复制至 iOS-SDK-for-RongYun 目录下。
  
3. 下载支付宝相关SDK

    [https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.CeDJVo&treeId=54&articleId=104509&docType=1](https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.CeDJVo&treeId=54&articleId=104509&docType=1)
    
4. 开启 rongcloud-demo-app-ios-v2/ios-rongimdemo/RCloudMessage.xcodeproj 工程文件

=========================================
####开始集成红包
1. 导入RedpacketLib和支付宝.在info.plist文件中添加支付宝回调的URL Schemes `alipayredpacket`

    支付宝具体参考[https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1](https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1)
2. 设置红包信息

  在 `AppDelegate.m` 中导入头文件
  ```objc
    #pragma mark - 红包相关头文件
    #import "RedpacketConfig.h"
    #import "RedpacketMessage.h"
    #import "RedpacketTakenMessage.h"
    #import "RedpacketTakenOutgoingMessage.h"
    #import "AlipaySDK.h"
  ```
  在Appdelegate
  ```objc
  - (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  ```

  最后添加了

    ```objc
    #pragma mark - 配置红包信息
    [RedpacketConfig config];
    #pragma mark - 注册自定义消息体
    [[RCIM sharedRCIM] registerMessageType:[RedpacketMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RedpacketTakenMessage class]];
    [[RCIM sharedRCIM] registerMessageType:[RedpacketTakenOutgoingMessage class]];
    ```

    同时需添加
    ```objc
    // NOTE: 9.0之前使用的API接口
    - (BOOL)application:(UIApplication *)application
                openURL:(NSURL *)url
      sourceApplication:(NSString *)sourceApplication
             annotation:(id)annotation {
        
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
            }];
        }
        return YES;
    }
    
    // NOTE: 9.0以后使用新API接口
    - (BOOL)application:(UIApplication *)app
                openURL:(NSURL *)url
                options:(NSDictionary<NSString*, id> *)options
    {
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:resultDic];
            }];
        }
        return YES;
    }
    - (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RedpacketAlipayNotifaction object:nil];
    }
```

  `RedpacketConfig` 类有两个作用。

    1) 它实现了 `YZHRedpacketBridgeDataSource` protocol，并在 Singleton 创建对象的时候设置了
    ```objc
    [[YZHRedpacketBridge sharedBridge] setDataSource:config];`
    ```
    `YZHRedpacketBridgeDataSource` protocol 用以为红包 SDK 提供用户信息

    2) 它用于执行`YZHRedpacketBridge` 的

    ```objc
    - (void)configWithSign:(NSString *)sign
               partner:(NSString *)partner
             appUserId:(NSString *)appUserid
             timeStamp:(long)timeStamp;
    ```

    以执行`红包 SDK` 的信息注册
    所以在登录、退出登录、刷新用户信息是要分别调用RedpacketConfig的三个API
    ```objc
    [RedpacketConfig config]//登录
    [RedpacketConfig logout]//退出登录
    [RedpacketConfig reconfig]//刷新身份
    ```
    开发者赢后续替换自己服务器URL来获取注册身份信息

3. 在聊天对话中添加红包支持

  1) 添加类支持

  在 融云 demo app 中已经实现 `RCDChatViewController` ，为了尽量不改动原来的代码，我们重新定义 `RCDChatViewController` 的子类 `RedpacketDemoViewController`。

  在 `RCDChatListViewController` 中RCDChatViewController全部替换为RedpacketDemoViewController
      
  2) 添加红包功能

  查看 `RedpacketDemoViewController.m` 的 源代码注释了解红包功能的。

    添加的部分包括：

       (1) 注册消息显示 Cell
       (2) 设置红包插件界面
       (3) 设置红包功能相关的参数
       (4) 设置红包接收用户信息
       (5) 设置红包 SDK 功能回调

4. 显示零钱功能

  通过执行

    ```objc
    - [RedpacketViewControl presentChangeMoneyViewController]
    
    ```

  在 融云 SDK demo app 中使用 Storyboard 定义个人设置界面，这里为了执行显示功能，采用 Custom Segue 的方法，在 Demo 中的 `RedpacketChangeMoneySegue` 类实现
