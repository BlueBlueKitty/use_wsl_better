Dim rawPath, wslPath, command

rawPath = WScript.Arguments(0)

' 处理 WSL 路径（\\wsl.localhost\Ubuntu-xx.xx\...）
If InStr(rawPath, "wsl.localhost") > 0 Then
    ' 是 \\wsl.localhost\发行版名\path 的格式
    Dim parts, pathInDistro, i
    parts = Split(rawPath, "\")
    
    ' 拼接 pathInDistro，从第4段开始（跳过: 空, wsl.localhost, 发行版名）
    pathInDistro = ""
    For i = 4 To UBound(parts)
        pathInDistro = pathInDistro & "/" & parts(i)
    Next
    
    ' WSL 原生路径，去掉发行版名（Ubuntu-xx.xx）
    wslPath = pathInDistro  ' 现在是 /home/user/...
Else
    ' 正常 Windows 路径转 WSL 路径
    rawPath = Replace(rawPath, "\", "/")
    ' 替换 \ 为 /，然后拼接成 /mnt/x 路径
    driveLetter = LCase(Left(rawPath, 1))
    pathRest = Mid(rawPath, 3) ' 去掉盘符冒号后的部分
    wslPath = "/mnt/" & driveLetter & pathRest
End If

' 拼接 powershell 命令，双引号内再包引号避免出错
command = "powershell.exe -NoProfile -WindowStyle Hidden -Command ""Set-Clipboard -Value '" & wslPath & "'"""
CreateObject("WScript.Shell").Run command, 0, False
