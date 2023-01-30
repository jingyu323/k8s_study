# Linux 常用操作命令

1.某些时候在拷贝文件时，可能希望跳过某些已经在目标文件夹中已存在的文件。此时可通过添加-n解决。

cp  -r -f 强制覆盖

cp -rn  cp -rn directory Destination Path



netstat -naop :grep 5672          #查看端口是否呗占用
more  xxx.log                     #查看日志信息
ps -ef :grep 5672                 #查看进程
systemctl stop  服务名             #停止指定的服务



获取镜像源

wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo

安装yum

yum -y clean all 

如果没有提示安装yum 重启电脑，在执行

虚拟机磁盘共享

sudo vmhgfs-fuse .host:/ /mnt/code  -o allow_other  -o nonempty



## 查看磁盘空间

```
du -sh  查看磁盘使用情况
 
df -hl：查看磁盘剩余空间
df -h：查看每个根路径的分区大小
du -sh [目录名]：返回该目录的大小
du -sm [文件夹]：返回该文件夹总M数
du -h [目录名]：查看指定文件夹下的所有文件大小（包含子文件夹）
```

## 文件夹操作

```
basename 
根据根据指定字符串或路径名进行截取文件名, 比如: 根据路径"/root/shells/aa.txt", 可以截取出aa.txt；
suffix: 用于截取的时候去掉指定的后缀名；

dirname  
从指定文件的绝对路径, 去除文件名，返回剩下的前缀目录路径
dirname 文件绝对路径
```



