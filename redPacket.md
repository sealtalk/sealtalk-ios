DK 接入文档
=================

使用融云 demo app
------------------


1. clone demo:[https://github.com/YunzhanghuOpen/sealtalk-ios.git](https://github.com/YunzhanghuOpen/sealtalk-ios/tree/redpacket) 切换到redpacket分支

2. 下载最新的红包 SDK 库文件 ( master 或者是 release )

  因为`红包 SDK` 在一直更新维护，所以为了不与 demo 产生依赖，所以采取了单独下载 zip 包的策略

  [https://www.yunzhanghu.com/download.html](https://www.yunzhanghu.com/download.html)

  解压后将 RedpacketLib 复制至 sealtalk-ios 目录下。
  
3. 下载支付宝相关SDK并导入.如缺少必须静态库.请参考支付宝添加.
[https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.CeDJVo&treeId=54&articleId=104509&docType=1](https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7629140.0.0.CeDJVo&treeId=54&articleId=104509&docType=1)
在Appdelegate中写入以下方法

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
    
4. 开启 sealtalk-ios/RCloudMessage.xcodeproj 工程文件

5. 设置红包信息
在用户获取到IMtoken时
```objc
#pragma mark - 配置红包信息
[RedpacketConfig configRedpacket];
```
执行`红包 SDK` 的信息注册

如对注册信息有其他要求,请自行参考`RedpacketConfig`实现和`YZHRedpacketBridge`所提供API

    注册红包消息体
```objc
[[RCIM sharedRCIM] registerMessageType:[RedpacketMessage class]];
[[RCIM sharedRCIM] registerMessageType:[RedpacketTakenMessage class]];
[[RCIM sharedRCIM] registerMessageType:[RedpacketTakenOutgoingMessage class]];
```
6. 在聊天对话中添加红包支持

  1) 添加类支持

  在 融云 demo app 中已经实现 `RCDChatViewController` ，为了尽量不改动原来的代码，我们重新定义 `RCDChatViewController` 的子类 `RedpacketDemoViewController`。
  将demo中`RCDChatViewController`实例修改为`RedpacketDemoViewController`实例

  2) 添加红包功能

  查看 `RedpacketDemoViewController.m` 的 源代码注释了解红包功能的。

    添加的部分包括：

       (1) 注册消息显示 Cell
       (2) 设置红包插件界面
       (3) 设置红包功能相关的参数
       (4) 设置红包接收用户信息
       (5) 设置红包 SDK 功能回调

7. 显示零钱功能

  通过执行

```objc
  - [RedpacketViewControl presentChangeMoneyViewController]
```

  在 融云 SDK demo app 中使用 Storyboard 定义个人设置界面，这里为了执行显示功能，采用 Custom Segue 的方法，在 Demo 中的 `RedpacketChangeMoneySegue` 类实现

