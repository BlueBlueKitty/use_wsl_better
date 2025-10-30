# windows添加右键菜单自动转换WSL路径的教程

此教程用于在windows右键菜单中添加“复制为 WSL 路径”的菜单项，点击后会将选中的文件夹或者文件的路径自动转为WSL中的路径并复制到剪贴板中。

例如，将`D:\Desktop`的windows路径，自动转为WSL中的路径`/mnt/d/Desktop`。

## 使用方法：

选中指定的文件或者文件夹，或者在指定目录空白处，右键点击选择"复制为 WSL 路径"菜单项。

## 配置方法：

下载[copy_as_wsl_path.vbs脚本](../resource/copy_as_wsl_path.vbs)和[复制为WSL路径.reg脚本](../resource/复制为WSL路径.reg)。

将copy_as_wsl_path.vbs脚本放在"C:\Windows\"路径下，然后双击"复制为WSL路径.reg"脚本即可

如果你不想把vbs脚本放在  "C:\Windows\"  路径下，则需要修改reg文件中的路径为你指定的vbs脚本所在文件夹路径。

假设你放在：

```
D:\Tools\copy_as_wsl_path.vbs
```

那么你需要在注册表中把命令改成：

```
reg复制编辑[HKEY_CLASSES_ROOT\*\shell\CopyAsWSLPath\command]
@="wscript.exe \"D:\\Tools\\copy_as_wsl_path.vbs\" \"%1\""

[HKEY_CLASSES_ROOT\Directory\shell\CopyAsWSLPath\command]
@="wscript.exe \"D:\\Tools\\copy_as_wsl_path.vbs\" \"%1\""
```



