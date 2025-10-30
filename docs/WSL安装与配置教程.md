# WSL 安装教程

## 安装WSL

科学上网状态下，在管理员模式下打开 PowerShell，输入以下命令，然后重新启动计算机。

```
wsl --install
```

## 移动WSL到其他盘

WSL默认安装在C盘，如果C盘空间不足，可以将其移动到其他盘。

**1.准备工作**

打开CMD，输入`wsl -l -v`查看wsl虚拟机的名称与状态，假如要移动Ubuntu-24.04

假如要移动到D盘，首先在D盘中新建一个文件夹，如WSL/Ubuntu，后续会将Ubuntu-24.04移动到该文件夹。

输入 `wsl --shutdown` 使其停止运行，再次使用`wsl -l -v`确保其处于stopped状态。

**2.导出/恢复备份**

在D盘创建一个目录用来存放新的WSL，比如我创建了一个 `D:\WSL\Ubuntu` 。

①导出它的备份（比如命名为Ubuntu.tar)

```text
wsl --export Ubuntu-24.04 D:\WSL\Ubuntu\Ubuntu.tar
```

②确定在此目录下可以看见备份Ubuntu.tar文件之后，注销原有的wsl

```text
wsl --unregister Ubuntu-24.04
```

③将备份文件恢复到`D:\WSL\Ubuntu`中去

```text
wsl --import Ubuntu-24.04 D:\WSL\Ubuntu D:\WSL\Ubuntu\Ubuntu.tar
```

这时候启动WSL，发现好像已经恢复正常了，但是用户变成了root，之前使用过的文件也看不见了。

之后可以删除`D:\WSL\Ubuntu\Ubuntu.tar`文件。

**3.恢复默认用户**

在CMD中，输入 `Linux发行版名称 config --default-user 原本用户名`

例如：

```bash
Ubuntu2204 config --default-user user
```

请注意，这里的发行版名称的版本号是纯数字，比如Ubuntu-22.04就是Ubuntu2204。

这时候再次打开WSL，你会发现一切都恢复正常了。

## WSL 运行 Linux GUI 应用

安装gedit之后，使用python绘图便可以显示GUI应用了，在wsl中安装gedit的命令：

```
sudo apt install gedit
```

如果打开gedit，发现中文是乱码，则按照下面的措施解决：

如果你的 WSL2 的字体文件目录下只有 `truetype` 一个文件夹

```bash
ls /usr/share/fonts/truetype/
```

并且进入 `truetype` 后只有 2 个文件夹 `dejavu ubuntu`，很可能图形界面使用的中文字体并不包含在内。

**解决方法：**

安装缺少字体，或者直接暴力复制 Windows11 的所有字体到 WSL2 的字体文件目录下。
 Windows11 的字体通常存放在 `C:\Windows\Fonts\` 下，在 WSL2的 `/usr/share/fonts/truetype/` 下新建一个目录直接全部复制过去即可。
 在 WSL2 中访问 Windows 目录需要在路径前加 `/mnt/`，例如 `/mnt/c/Windows/Fonts/`。

```bash
sudo mkdir -p /usr/share/fonts/windows11
sudo cp /mnt/c/Windows/Fonts/* /usr/share/fonts/windows11
```

一般来说，此时再打开图形界面，中文显示就是正常的。

> 到此已经解决了我的问题。如果没能解决你的问题，以下列出一些可供参考的方法

**设置 Ubuntu 中文语言环境**

1. 安装中文语言包

```bash
sudo apt install language-pack-zh-han*
```

2. 运行语言支持检查

```bash
sudo apt install $(check-language-support)
```

3. 修改相关配置文件

通过图形界面修改。

```bash
sudo dpkg-reconfigure locales
```

使用空格键选择 `en_US.UTF-8` 以及 `zh_CN.UTF-8`，使用 TAB 键切换至 OK，再将 `en_US.UTF-8` 选为默认（此处选择 `zh_CN.UTF-8` 及修改上述文件中的 `LANG` 字段）。 然后重启 WSL2。

4. 修改环境变量 添加 `LANG=zh_CN.UTF-8` 到配置文件末尾。有两种做法，仅供参考。

```bash
echo "LANG=zh_CN.UTF-8" >> ~/.profile
```

```bash
echo "LANG=zh_CN.UTF-8" >> /etc/profile
```

**WSL2 无内容显示无法操作**

折腾的途中遇到 WSL2 只有光标闪烁，无内容显示也无法操作，`wsl --shutdown` `wsl -l -v` 等等指令都没有效果。

解决方法：

在启动或关闭Windows功能中，关掉适用于Linux的Windows子系统，再重新打开。重启后一切恢复正常

