代码格式化原理

# 1.工具介绍

[ClangFormat](http://clang.llvm.org/docs/ClangFormat.html) 可用于格式化（排版）多种不同语言(C/C++/Java/JavaScript/Objective-C/Protobuf/C#)的代码，其内置的排版格式主要有：LLVM, Google, Chromium, Mozilla, WebKit, File(自定义排版)

使用内置排版格式：

```
clang-format -style=llvm AppDelegate.m
```

导出内置的排版格式

```
clang-format -style=llvm -dump-config > .clang-format
```

使用自定义排版格式

```
clang-format -style=file AppDelegate.m
```

使用自定义之后 `clang-format` 会在父目录或当前目录寻找 `.clang-format` 文件，按照文件中的参数对代码进行格式化

iOS-Workspace 使用了自定义排版，`.clang-format` 文件在目录 `ios` 下

详细可以参考 `clang-format -help` 命令的描述


# 2.给发生变更的代码进行排版

大多数的情况是改了部分代码，只需要给这部分代码进行排版就行，所以只更改 git 上发生变更的文件即可

通过下面的 git diff 命令就可以获取`受 git 管理的发生变更的文件`

```
git diff --name-only
```

详细可以参见 [format_ios_code.sh](format_ios_code.sh)，会对发生更改的受 git 管理的 .h .m .mm 文件格式化代码

# 3.Xcode 自动排版

有了格式化代码的脚本，为了方便大家能够方便快捷的格式化代码，需要将该功能集成到 Xcode ，保证编译代码的时候，可以自动进行代码的格式化

Xcode 本身支持编译时运行脚本，可以让 Xcode 编译的时候自动运行格式化代码的脚本即可

点击 项目->"Build Phases"->"+"->"New Run Script Phase" ，Xcode 会自动生成一项 "Run Script"

然后就可以在 Run Script 中写脚本了，写好的脚本会在 Xcode 运行时自动触发

详细可以参见 `SealTalk` 的 Run Script

# 4.如何调试脚本

shell 脚本比较麻烦，必须在正确的目录执行才能得到正常的结果

所以将第 2 步的脚本融合到第 3 步时，需要进行脚本的调试

Xcode 脚本所处的根目录是 `.xcodeproj` 文件所在目录，可以先行进入该目录，使用终端手动执行脚本进行调试，一切正常，再将脚本运行写入 Xcode 配置即可