## Lua create snake

[love2d 2D游戏引擎 文档](http://love2d.org/)

## install
[安装love2d引擎](http://love2d.org/wiki/Getting_Started)，需要安装love2d之后才可以运行main.lua.

运行的代码：
```cmd
$ love .
```

## 打包exe文件

### 第一步：创建.love文件
进入你的游戏文件夹（包含main.lua的根目录）

全选所有游戏文件（不要包含文件夹本身）

压缩成zip文件

将后缀从.zip改为.love，例如SnakeGame.love

### 第二步：准备LÖVE运行环境

1. 从LÖVE官网下载Windows版本（建议选择32-bit zipped版本，兼容性更好）

2. 解压到一个文件夹，比如C:\love2d

### 第三步：合并生成exe
打开命令提示符（cmd），进入LÖVE文件夹：

```bash
cd C:\love2d
```

```bash
copy /b love.exe+SnakeGame.love SnakeGame.exe
```
### 第四步：收集所有DLL文件
将以下所有文件放在同一个文件夹中，这就是你的最终游戏包：
```bash
SnakeGame.exe      # 你的游戏主程序
SDL2.dll           # 必需
OpenAL32.dll       # 音频支持（64位版仍叫OpenAL32.dll）
love.dll           # LÖVE核心
lua51.dll          # Lua解释器
mpg123.dll         # MP3支持
msvcp120.dll       # VC++运行时
msvcr120.dll       # VC++运行时
license.txt        # 许可证文件（必须包含）
```