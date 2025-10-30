# WSL2安装GAMMA教程

版本要求：

**Windows**：Windows 11 23H2或者更高版本，这是WSL2镜像网络的版本要求。

查询windows版本的方法：右键“我的电脑”→“属性”

**WSL2**：WSL2.0.0或者更高版本，这是镜像网络的要求，WSL21的网络听说适合安装GAMMA，但是我没有搞过。

查询WSL2版本的命令：打开 Windows 命令提示符或 PowerShell 终端，并运行命令：`WSL2 --version`

升级WSL2的命令：`WSL2 --update`

## 第一步：安装GAMMA

按照GAMMA软件安装说明进行安装即可。

如果是新安装的WSL2，需要把apt源换成国内的，这样安装时可以加快速度。

安装GAMMA可能会遇到的问题：

1、Ubuntu-20.04安装libgdal20库和libhdf5-100失败

换成libgdal26和libhdf5-103即可。

2、安装完GAMMA后，运行GAMMA命令提示找不到命令

如果你安装了zsh或者其他shell，那么环境配置应该写在`~/.zshrc`文件中，因为zsh打开时会自动执行`~/.zshrc`文件，而不会自动执行`~/.bashrc`文件，所以在安装GAMMA时，你需要将环境配置写到`~/.zshrc`文件中。

3、运行`data2geotiff`命令时，提示缺少libgdal.so.20库文件

所有libgdal.so.软链接库都软链接的libgdal.so.20.3.2（对于Ubuntu 18.0.4系统）或者libgdal.so.26.0.4（对于Ubuntu 20.0.4系统），所以只要出现libgdal.so.库缺失，如libgdal.so.20，那么只需要将缺失的库软链接到libgdal.so.20.3.2或者libgdal.so.26.0.4即可。如：
Ubuntu 18.0.4： `ln -s libgdal.so.20.3.2 libgdal.so.20`
Ubuntu 20.0.4:   `ln -s libgdal.so.26.0.4 libgdal.so.20`

## 第二步：配置WSL2镜像网络以使用联网版本的GAMMA加密狗

如果课题组使用的是联网版本的GAMMA加密狗（一般是红色的），而且如果局域网内正好有一台Linux设备插着联网版本的GAMMA加密狗的话，那么我们就可以想办法让我们windows中的WSL2也访问到局域网中的那台Linux设备，以使用其上面的GAMMA加密狗，而通过配置WSL2的镜像网络就可以实现这一目的。因为配置镜像网络就是使得WSL2共用windows的局域网，这样WSL2就可以访问windows所在局域网内的插着GAMMA加密狗的Linux设备了，关于WSL2各种网络的具体介绍参考[微软官方文档](https://learn.microsoft.com/zh-cn/windows/WSL2/networking)。如果局域网内没有插着联网版本的GAMMA加密狗的Linux设备，或者只有单机版本的GAMMA加密狗（一般是黑色的），那么请按照下面的第三步进行配置。

配置WSL2镜像网络的方法：

windows搜索`WSL2 Settings`应用，将其中的网络模式改为`Mirrored`。如下图所示，之后关闭WSL2重启即可。

<img src="D:\OneDrive\知识总结\笔记\Linux学习\WSL相关笔记\WSL2安装GAMMA的教程.assets\image-20251030204134476-1761828098649-3.png" alt="image-20251030204134476" style="zoom:50%;" />

如果WSL2还是没有识别到加密狗，还是无法正常使用GAMMA命令，即运行`SLC_adf`命令报错`Sentinel LDK Protection System: Sentinel key not found (H0007)`，则需要通过下面的步骤排查解决问题。以下会介绍每个步骤执行的原因，理解其原理后才便于我们解决出现的问题。

首先应确保局域网内联网版GAMMA加密狗所在的另一台Linux设备能够正常使用GAMMA命令，如果不能正常使用的话，可能是没安装加密狗的驱动，或者使用的是单机版的GAMMA加密狗，或者加密狗损坏或过期了。

在WSL2中安装的GAMMA加密狗驱动一般叫做`aksusbd`驱动，我们首先我们通过`systemctl status aksusbd`命令检查WSL2中的`aksusbd`驱动是否正常工作，如果显示`Active`，便说明加密狗驱动运行正常。

国内GAMMA加密狗的品牌一般是Sentinel LDK，即胜天诺，而Sentinel LDK加密狗是通过 TCP/UDP协议 与 `aksusbd` 驱动服务进行通信的，两者之间能够正常通信后，WSL2才能正常访问到GAMMA加密狗，GAMMA才能正常使用。而两者之间默认使用的通信端口是 1947 (TCP/UDP协议)，所以我们通过以下命令先检查下WSL2是否可以访问加密狗所在Linux设备的1947端口：

```bash
ping 加密狗所在Linux设备的局域网ip
nc -vz 加密狗所在Linux设备的局域网ip 1947
```

如果nc命令没有返回connected信息，那么说明WSL2没办法访问加密狗所在设备的1947端口，这就导致我们的WSL2访问不到加密狗了。而这个问题往往是加密狗所在Linux设备的防火墙出现了问题，所以我们在加密狗所在Linux设备上使用以下命令更其改防火墙设置，让其防火墙能够允许外面的设备通过tcp或者udp协议访问本地的1947端口：

```bash
# 如果用 ufw
sudo ufw allow 1947/tcp
sudo ufw allow 1947/udp
sudo ufw reload
```

之后，再次运行`nc -vz 加密狗所在Linux设备的局域网ip 1947`命令检查是否能正常访问，直至能够正常访问。

然后我们检查下WSL2能否访问到GAMMA加密狗，在WSL2终端打开的情况下，在windows浏览器中输入http://localhost:1947/_int_/devices.html，如下图所示，正常情况下，会有一个名为`Local`的设备，这个不用管，如果有第二个名为`ubuntu-z`（可能叫这个名字，也可能不是，但是一般会有一个U盘的图标），其便是GAMMA软件的加密狗。这时，我们就可以在WSL2中正常使用GAMMA了。

![image-20251030204235839](D:\OneDrive\知识总结\笔记\Linux学习\WSL相关笔记\WSL2安装GAMMA的教程.assets\image-20251030204235839-1761828157127-5.png)

但是如果浏览器中没有显示第二个设备，有可能是`aksusbd`驱动没有自动识别到GAMMA加密狗设备，我们可以尝试为驱动手动指定加密狗所在设备的ip，因此我们编辑`/etc/hasplm/hasplm.ini`文件，

```bash
sudo vim /etc/hasplm/hasplm.ini
```

在其中添加：

```text
[HASP_SERVERS]
SERVERADDR = 加密狗所在Linux设备的局域网ip
```

然后重启`aksusbd`服务即可：`sudo systemctl restart aksusbd`。**需要注意的是，如果加密狗所在设备的ip改变，则需要重新编辑`/etc/hasplm/hasplm.ini`文件。**

之后就应该可以正常识别到GAMMA加密狗并正常使用GAMMA命令了。

## 第三步：使用usbipd-win工具以在windows电脑上使用加密狗

请注意，这一步骤不是必需的。如果同一局域网内存在一个Linux设备上插着联网版的GAMMA加密狗（一般为红色），那么经过前面的第二步配置WSL2的镜像网络后，就可以正常使用GAMMA软件了。但是如果局域网中没有Linux设备，或者自己只有单机版的GAMMA加密狗（一般为黑色），那么就可以按照下面的步骤进行配置，以在windows电脑上使用加密狗。

具体原理是：我们想让WSL2直接访问插在windows电脑上的GAMMA加密狗USB设备，但是由于WSL2不支持访问windows系统下的USB设备，因此我们需要通过usbipd-win工具将GAMMA加密狗对应的USB设备共享给WSL2，这样WSL2就能访问GAMMA加密狗了。具体步骤如下：

首先安装软件[usbipd-win](https://github.com/dorssel/usbipd-win)，先在windows中打开powershell使用以下命令来安装usbipd-win工具：

```powershell
winget install usbipd
```

下载完后点击安装就好，安装完后可能还会要求你重启电脑。

接下来使用usbipd-win来连接，usbipd-win的使用方法参考也是参考的[微软官方文档](https://learn.microsoft.com/zh-cn/windows/WSL2/connect-usb)。首先打开powershell，使用下面的第一个命令列出所有连接到 Windows 的 USB 设备，找到GAMMA加密狗USB设备（一般名称带有Sentinel）对应的BUSID，如下图所示，我的加密狗对应的BUSID为2-1，然后使用这个BUSID替换下面第二个命令来共享USB设备。

```powershell
usbipd list
usbipd bind --busid <BUSID>
```

![image-20251030210259084](D:\OneDrive\知识总结\笔记\Linux学习\WSL相关笔记\WSL2安装GAMMA的教程.assets\image-20251030210259084.png)

接着使用下面的命令中来使GAMMA加密狗的USB设备连接到WSL2，其中的BUSID同上。**注意，如果WSL2终端中期或者当加密狗USB设备重置/物理拔下/重新插入时，可能需要重新运行下面的这条命令**。

```powershell
usbipd attach --WSL2 --busid <BUSID>
```

接着我们打开 WSL2，并使用下面的命令列出连接的 USB 设备：

```bash
lsusb
```

如下图所示，会看到刚刚连接的GAMMA加密狗USB设备（可以通过对比VID:PID来确定USB设备，我的加密狗设备的ID为0529:0001)。

![image-20251030210400138](D:\OneDrive\知识总结\笔记\Linux学习\WSL相关笔记\WSL2安装GAMMA的教程.assets\image-20251030210400138.png)

如果WSL2中已经安装了GAMMA加密狗的驱动，那么插入windows电脑的GAMMA加密狗应该就会亮灯，亮灯说明加密狗成功运行了，这时就可以愉快地使用GAMMA了。

## 相关问题

1、WSL2访问windows文件的方法：

WSL2不能直接访问windows文件路径，如`C:\Users\user`，你需要将路径改成：`/mnt/c/Users/user`。因此在用WSL2的GAMMA处理文件时，需要将文件路径改一下。可以在windows右键菜单中定义一个菜单，以使得windows文件路径自动转换为WSL2中的对应路径。

2、WSL2访问windows目录下的文件的IO效率较低，尽量把GAMMA处理的数据放在WSL2所在目录。