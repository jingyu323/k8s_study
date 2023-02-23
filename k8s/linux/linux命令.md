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

1.打开虚拟机设置，-》选项-》共享文件夹-》选择添加，设置为总是启用

2.创建挂载目录  mkdir /mnt/code

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

## 用户组

1.添加用户

useradd [选项] 用户名

passwd [选项] 用户名 



usermod [选项] 用户名  用于修改用户信息

选项：

- -c 用户说明：修改用户的说明信息，即修改 /etc/passwd 文件目标用户信息的第 5 个字段；
- -d 主目录：修改用户的主目录，即修改 /etc/passwd 文件中目标用户信息的第 6 个字段，需要注意的是，主目录必须写绝对路径；
- -e 日期：修改用户的失效曰期，格式为 "YYYY-MM-DD"，即修改 /etc/shadow 文件目标用户密码信息的第 8 个字段；
- -g 组名：修改用户的初始组，即修改 /etc/passwd 文件目标用户信息的第 4 个字段（GID）；
- -u UID：修改用户的UID，即修改 /etc/passwd 文件目标用户信息的第 3 个字段（UID）；
- -G 组名：修改用户的附加组，其实就是把用户加入其他用户组，即修改 /etc/group 文件；
- -l 用户名：修改用户名称；
- -L：临时锁定用户（Lock）；
- -U：解锁用户（Unlock），和 -L 对应；
- -s shell：修改用户的登录 Shell，默认是 /bin/bash。

### /etc/passwd

Linux 系统中的 /etc/passwd 文件，是系统用户配置文件，存储了系统中所有用户的基本信息，并且所有用户都可以对此文件执行读操作。

### /etc/shadow 

/etc/shadow 文件，用于存储 Linux 系统中用户的密码信息，又称为“影子文件”。

### 性能

#### CPU



如果想要查看系统 CPU 的整理负载状况，每 3 秒统计一次，统计 5 次，可以执行如下命令：

```
[root@localhost ~]# sar -u 3 5
Linux 2.6.32-431.el6.x86_64 (localhost)     10/25/2019     _x86_64_    (1 CPU)

06:18:23 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
06:18:26 AM     all     12.11      0.00      2.77      3.11      0.00     82.01
06:18:29 AM     all      6.55      0.00      2.07      0.00      0.00     91.38
06:18:32 AM     all      6.60      0.00      2.08      0.00      0.00     91.32
06:18:35 AM     all     10.21      0.00      1.76      0.00      0.00     88.03
06:18:38 AM     all      8.71      0.00      1.74      0.00      0.00     89.55
Average:        all      8.83      0.00      2.09      0.63      0.00     88.46
```

此输出结果中，各个列表项的含义分别如下：

- %user：用于表示用户模式下消耗的 CPU 时间的比例；
- %nice：通过 nice 改变了进程调度优先级的进程，在用户模式下消耗的 CPU 时间的比例；
- %system：系统模式下消耗的 CPU 时间的比例；
- %iowait：CPU 等待磁盘 I/O 导致空闲状态消耗的时间比例；
- %steal：利用 Xen 等操作系统虚拟化技术，等待其它虚拟 CPU 计算占用的时间比例；
- %idle：CPU 空闲时间比例。

#### 内存



#### 磁盘读写（I/O）能力

如果想要查看系统磁盘的读写性能，可执行如下命令：

```
[root@localhost ~]# sar -d 3 5
Linux 2.6.32-431.el6.x86_64 (localhost)     10/25/2019     _x86_64_    (1 CPU)

06:36:52 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:36:55 AM    dev8-0      3.38      0.00    502.26    148.44      0.08     24.11      4.56      1.54

06:36:55 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:36:58 AM    dev8-0      1.49      0.00     29.85     20.00      0.00      1.75      0.75      0.11

06:36:58 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:37:01 AM    dev8-0     68.26      6.96  53982.61    790.93      3.22     47.23      3.54     24.17

06:37:01 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:37:04 AM    dev8-0    111.69   3961.29    154.84     36.85      1.05      9.42      3.44     38.43

06:37:04 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
06:37:07 AM    dev8-0      1.67    136.00      2.67     83.20      0.01      6.20      6.00      1.00

Average:          DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
Average:       dev8-0     34.45    781.10   9601.22    301.36      0.78     22.74      3.50     12.07
```

此输出结果中，各个列表头的含义如下：

- tps：每秒从物理磁盘 I/O 的次数。注意，多个逻辑请求会被合并为一个 I/O 磁盘请求，一次传输的大小是不确定的；
- rd_sec/s：每秒读扇区的次数；
- wr_sec/s：每秒写扇区的次数；
- avgrq-sz：平均每次设备 I/O 操作的数据大小（扇区）；
- avgqu-sz：磁盘请求队列的平均长度；
- await：从请求磁盘操作到系统完成处理，每次请求的平均消耗时间，包括请求队列等待时间，单位是毫秒（1 秒=1000 毫秒）；
- svctm：系统处理每次请求的平均时间，不包括在请求队列中消耗的时间；
- %util：I/O 请求占 CPU 的百分比，比率越大，说明越饱和。


除此之外，如果想要查看系统内存使用情况，可以执行`sar -r 5 3`命令；如果要想查看网络运行状态，可执行`sar -n DEV 5 3`命令，等等。有关其它参数的用法，这里不再给出具体实例，有兴趣的读者可自行测试，观察运行结果。

#### 网络带宽



分析系统性能命令

sar 命令很强大，是分析系统性能的重要工具之一，通过该命令可以全面地获取系统的 CPU、运行队列、磁盘读写（I/O）、分区（交换区）、内存、CPU 中断和网络等性能数据。

[root@localhost ~]# sar [options] [-o filename] interval [count]

此命令格式中，各个参数的含义如下：

- -o filename：其中，filename 为文件名，此选项表示将命令结果以二进制格式存放在文件中；
- interval：表示采样间隔时间，该参数必须手动设置；
- count：表示采样次数，是可选参数，其默认值为 1；
- options：为命令行选项，由于 sar 命令提供的选项很多，这里不再一一介绍，仅列举出常用的一些选项及对应的功能，如表 1 所示。



| sar命令选项 | 功能                                                         |
| ----------- | ------------------------------------------------------------ |
| -A          | 显示系统所有资源设备（CPU、内存、磁盘）的运行状况。          |
| -u          | 显示系统所有 CPU 在采样时间内的负载状态。                    |
| -P          | 显示当前系统中指定 CPU 的使用情况。                          |
| -d          | 显示系统所有硬盘设备在采样时间内的使用状态。                 |
| -r          | 显示系统内存在采样时间内的使用情况。                         |
| -b          | 显示缓冲区在采样时间内的使用情况。                           |
| -v          | 显示 inode 节点、文件和其他内核表的统计信息。                |
| -n          | 显示网络运行状态，此选项后可跟 DEV（显示网络接口信息）、EDEV（显示网络错误的统计数据）、SOCK（显示套接字信息）和 FULL（等同于使用 DEV、EDEV和SOCK）等，有关更多的选项，可通过执行 man sar 命令查看。 |
| -q          | 显示运行列表中的进程数、进程大小、系统平均负载等。           |
| -R          | 显示进程在采样时的活动情况。                                 |
| -y          | 显示终端设备在采样时间的活动情况。                           |
| -w          | 显示系统交换活动在采样时间内的状态。                         |

## 数学计算

除法并保留一位小数

 du -sm * |  awk '{printf "%.1f\n",$1/1024}'

## 字符串操作

### 字符串分割  

test_str=block#username#password#serverIP  



echo $test_str | awk -F "#" '{print $4}'





## 材料：

1. Linux基础介绍 https://www.junmajinlong.com/linux/index/#systemd

