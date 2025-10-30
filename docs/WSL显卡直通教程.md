# [wsl 启用gpu](https://www.cnblogs.com/gongzb/p/18651684)

在WSL（Windows Subsystem for Linux）中启用GPU加速需要一系列步骤，以确保硬件和软件之间的兼容性。以下是详细步骤：

### 1. 确认WSL版本和GPU硬件兼容性

首先，确保你的Windows版本支持WSL2，并且你的GPU与WSL2兼容。WSL2需要Windows 10版本2004（内部版本19041）或更高版本，以及支持虚拟化的处理器。对于GPU，NVIDIA和AMD的某些型号与WSL2兼容，但你需要确保你的GPU驱动是最新的。

### 2. 安装WSL的GPU驱动

在Windows上安装支持WSL的NVIDIA GPU驱动。这通常可以通过NVIDIA官方网站下载并安装最新的GeForce Game Ready驱动来实现。确保不要在WSL中安装任何Linux显示驱动程序，因为Windows显示驱动程序将同时支持Windows和WSL。

### 3. 配置WSL以启用GPU加速

在WSL中配置CUDA Toolkit以启用GPU加速。以下是具体步骤：

- ‌安装CUDA Toolkit‌：
  在NVIDIA官网下载与你的GPU和CUDA版本兼容的CUDA Toolkit安装包。然后，在Ubuntu终端中运行以下命令来安装CUDA：

[https://developer.nvidia.com/cuda-downloads](https://developer.nvidia.com/cuda-downloads)

注意：在安装过程中，确保不要安装任何Linux显示驱动程序。

- ‌设置环境变量‌：
  安装完成后，你可能需要更新你的环境变量以确保CUDA工具链（如`nvcc`）可以在终端中直接使用。编辑你的`~/.bashrc`文件，添加以下行：

```bash
export PATH=/usr/local/cuda/bin:$PATH

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
```

然后，运行`source ~/.bashrc`来应用更改。
