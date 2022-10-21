# Linux 常用操作命令

1.某些时候在拷贝文件时，可能希望跳过某些已经在目标文件夹中已存在的文件。此时可通过添加-n解决。

cp  -r -f 强制覆盖

cp -rn  cp -rn directory Destination Path



netstat -naop :grep 5672          #查看端口是否呗占用
more  xxx.log                     #查看日志信息
ps -ef :grep 5672                 #查看进程
systemctl stop  服务名             #停止指定的服务