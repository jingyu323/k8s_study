# Linux 常用操作命令

1.某些时候在拷贝文件时，可能希望跳过某些已经在目标文件夹中已存在的文件。此时可通过添加-n解决。

cp  -r -f 强制覆盖

cp -rn  cp -rn directory Destination Path

"xargs  使用"

```


查找tomcat 进程并杀死

ls *.txt | xargs -i cp {} /tmp/ 
ls *.tar |xargs -i docker load -i {}	*#逐个导入镜像*

 ps -ef | grep tomcat | grep v | awk -F " " '{print $2}' | xargs  kill -9
```



netstat -naop :grep 5672          #查看端口是否呗占用
more  xxx.log                     #查看日志信息
ps -ef :grep 5672                 #查看进程
systemctl stop  服务名             #停止指定的服务

文件转码

```
转名称
 convmv -f GBK -t UTF-8 -r --notest  文件名/目录
转内容

iconv -c -f utf8 -t GBK  "sourcefile" -o   "targetfile"
全局替换字符串
sed 's/司机室/SJS/g'

rar 压缩文件
 rar a  -r   -idq "${sub_dir}"  "${sub_dir}/*"
 

linux删除超过三天文件

find /path/to/directory -type f -mtime +3 -exec rm {} \;

find /path/to/directory -type f -mtime +3 -delete


find /HighCache/videoPlay/0401/司机室1摄像头1  -type f -mtime +90  -delete
 
```



获取镜像源

wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo

安装yum

yum -y clean all 

如果没有提示安装yum 重启电脑，在执行

虚拟机磁盘共享

1.打开虚拟机设置，-》选项-》共享文件夹-》选择添加，设置为总是启用

2.创建挂载目录  mkdir /mnt/code

sudo vmhgfs-fuse .host:/ /mnt/code  -o allow_other  -o nonempty



shell程序中，0表示真，非0表示假



##### 拼接命令执行：

```
`echo "touch 11" `

$(echo " touch 11222" )  
```

两种方式都可以直接执行字符串中的内容

强制安装

```
rpm -ivh *python* --nodeps --force
rpm -ivh *yum* --nodeps --force

```

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

## 文件操作

#### 查找不同类型的文件

文件夹

find . -type d -name "yang*"

符号或者连接

find . -type l -name "yang*"

文件

find . -type f -name "yang*"

#### 按指定的时间戳查找文件

搜索atime超过一年的文件，我们可以编写如下命令：

find . -type f -atime +365
如果我们需要查找 mtime 正好是 5 天前的文件，请不要包含 +，因为它的意思是“大于”。

find . -type f -mtime 5
显然，+ 表示“大于”，- 表示“小于”。所以我们可以搜索 ctime 在 5~10 天前的文件：

find . -type f -ctime +5 -ctime -10

#### 按大小查找文件

-size选项使我们能够按指定大小查找文件。我们可以将其计量单位指定为以下约定：

b：512 字节块（默认）

c：字节

w：双字节字

k：KB

M：MB

G：GB

类似于按时间戳查找文件，+表示“大于”，-表示“小于”。例如，要查找大小为 10 MB ~ 1 GB 的文件：

find . -type f -size +10M -size -1G



#### 按权限查找文件

合理控制文件的权限是 Linux 管理员的一项重要任务。find命令的-perm选项可以帮助我们按指定权限查找文件：

find . -type f -perm 777





查看文件句柄

 lsof /

查看系统进程文件限制

/proc/16112/limits



这将显示该进程的所有打开文件

ls -l /proc/4406/fd  | wc -l

ulimit -a

ulimit -n 102400

最大值为655350



删除指定大小的文件

```
du -h     | grep 6.0G | awk '{print $2}' |  while read   folder_path; do
echo "$folder_path"
rm -rf  "$folder_path"
done


```



## RAR

```
rar a  -r -ep1  -idq "${sub_dir}"  "${sub_dir}/*"

a 添加文件到压缩包
-r 递归子目录
-ep1 不包含跟路径
-idq  不显示压缩信息

-id[c,d,p,q]
禁用消息。

参数 -idc 禁用版权字符串。
参数 -idd 在操作结束禁止显示“完成”字符串。
参数 -idp 禁止百分比指示。
参数 -idq 打开安静模式, 仅错误消息和问题能被显示。
```

## 四种Linux系统版本号的查看方式

1、系统版本号的查看(cat /proc/version)
[root@qianfeng01 ~]# cat /proc/version
Linux version 3.10.0-1062.el7.x86_64 (mockbuild@kbuilder.bsys.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC) ) #1 SMP Wed Aug 7 18:08:02 UTC 2019
2、获取内核信息 (uname -a)
[root@qianfeng01 ~]# uname -a
Linux qianfeng01 3.10.0-1062.el7.x86_64 #1 SMP Wed Aug 7 18:08:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
3、获取系统信息 (cat /etc/os-release)

[root@qianfeng01 ~]# cat /etc/os-release
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"

4、获取系统信息 （cat /etc/redhat-release）
[root@qianfeng01 ~]# cat /etc/redhat-release
CentOS Linux release 7.7.1908 (Core)
hostnamectl

[root@qianfeng01 ~]# hostnamectl
   Static hostname: qianfeng01
         Icon name: computer-vm
           Chassis: vm
        Machine ID: dce68bacb80a4cf5bca2405780aa9591
           Boot ID: 27f089e32abf48a0a903bd5671d31586
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-1062.el7.x86_64 

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



示当前系统中正在运行的进程的树状结构

pstree -g



###### 添加sudoers 读写权限

chmod u+w /etc/sudoers 

##### 编辑sudoers文件

vi /etc/sudoers

找到这行 root ALL=(ALL) ALL,在他下面添加xxx ALL=(ALL) ALL (这里的xxx是你的用户名)

取消写权限

chmod u-w /etc/sudoers

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

磁盘读速率

hdparm -t /dev/sda

写速率

dd if=/dev/zero of=/tmp/output.img bs=8k count=256k 



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

查看网络进程使用端口

netstat -natp 



分析系统性能命令

安装

yum -y install sysstat



sar -u   
Cannot open /var/log/sa/sa14: No such file or directory
Please check if data collecting is enabled

解决方法：

启动sysstat服务

systemctl start sysstat



sar 命令很强大，是分析系统性能的重要工具之一，通过该命令可以全面地获取系统的 CPU、运行队列、磁盘读写（I/O）、分区（交换区）、内存、CPU 中断和网络等性能数据。

[root@localhost ~]# sar [options] [-o filename] interval [count]

此命令格式中，各个参数的含义如下：

- -o filename：其中，filename 为文件名，此选项表示将命令结果以二进制格式存放在文件中；
- interval：表示采样间隔时间，该参数必须手动设置；
- count：表示采样次数，是可选参数，其默认值为 1；
- options：为命令行选项，由于 sar 命令提供的选项很多，这里不再一一介绍，仅列举出常用的一些选项及对应的功能，如表 1 所示。

   使用sar -n DEV 1 2检测数据流向

命令后面1 2 意思是：每一秒钟取1次值，取2次。

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



```
加法
log_count=$(expr $log_count + 1)
乘法
capacity=$(( 5*1024*1024/100*80))
```



指定换行符，添加windows和linux换行转换

```
echo -e   "${tsubDstFile}\r" 
```

## 字符串操作	

### 日志：

```
logfile="/var/log/ht_fileclean.log"
ht_clean_task_flag="/tmp/ht_clean_task_flag"
function log_info() {
    local log_time=`date +%Y%m%d%H%M%S`
    local  level=$1
    local  msg=$2
    echo "${log_time} ${level} ${msg}" >> ${logfile}
}
```

### 获取时间

```
获取当前时间
cur_time=$(date +%Y%m%d%H%M%S)
```

### 字符串分割  

test_str=block#username#password#serverIP  

echo $test_str | awk -F "#" '{print $4}'

### awk命令

awk将一行分成数个字段来处理

```
print	: 打印
NF		: 统计总字段数
$		: 取值
结合作用:
	$配合NF使用 : NF内存储统计文件内每行的总字段，$存储NF内的值
	NF	：相当于 变量值	$	：相当于 变量名
	print相当于打印 $ 内的内容
```

分割字符串，取其中的一部分

```
 echo $subFile | awk -F "_" '{print $2}'
```

查找时间最远的文件删除

```
find $target_dir -type f | xargs ls -alt  | tail   -n -10 |  awk '{ print $9 }'  | xargs rm -rf
```

### sed命令

sed作用于一整行的处理

### while

```
while ((capacity <= cur_usaged))
do
  cur_usaged=$( du -sm  $target_dir | awk  -F " " '{print $1}')
  log_info "info " "find $(find $target_dir -type f | xargs ls -alt  | tail   -n -10  | wc -l ) file to clean"
  find $target_dir -type f | xargs ls -alt  | tail   -n -10 |  awk '{ print $9 }'  | xargs rm -rf
  echo "start delete file, $cur_usaged "
  sleep 10
done
```

### shell 以某个字符开头的判断

```
if [[$1 =~^v.* ]]; then
   commond
 else
   commond
 fi
```

```
判断包含 前边包含后边的
${srcDir} =~ ${blockCode}
```

```
检查连接状态ping
ping -c 3 -w 30 $ftp_host
result=$?
```

```
结果查找
$(cat  $conv_result | grep -a "Ready" | awk -F  " " '{ print $4 }')
```

```
查看进程
$(ps -aux | grep  tomcat | grep -v grep | awk '{print $2}')
```

### 截取

[root@localhost videoLink]# filename="test/2/4/HXD2B0259_成都运达_01_一端路况_20210322_074502.mp4"

切割左边的，只保留最后一个/右边的数据
[root@localhost videoLink]# name=`echo ${filename##*/}`

[root@localhost videoLink]# echo $name
HXD2B0259_成都运达_01_一端路况_20210322_074502.mp4
[root@localhost videoLink]# echo ${name# 
[root@localhost videoLink]# echo ${name%_*}
HXD2B0259_成都运达_01_一端路况_20210322
[root@localhost videoLink]# echo ${name%%_*}
HXD2B0259

总结下

\#、##表示从左边删除，一个#表示从左边删除到第一个指定的字符；两个#表示从左边删除到最后一个指定的字符。



% 、%%表示从右边删除，一个%表示从右边删除第一个指定的字符；两个%表示从右边删除到最后一个指定的字符。

删除包括指定的字符串本身。



获取不带后缀的文件名

basename /usr/include/stdio.h .h

输出 stdio

替换指定字符，下文时把av3替换成空

```
${video_subDir/"av3/"/}
```



```

## 去除最后一位"/"
function remove_last_slash() {
       local source_dir=$1
       local source_dir_laststr=`echo ${source_dir: -1}`

       if [ "${source_dir_laststr}" == "/" ]; then
         source_dir=${source_dir%?}
       fi
       echo "${source_dir}"
}
```



```
定义在脚本退出时执行指定的方法，无论是正常退出还是异常退出
trap del_flag EXIT
```

```
转换文件编码
iconv -c -f utf8 -t GBK  "${tmp_record_file}" -o   "${tmp_record_file}"
```

### 文件递归删除

删除空文件夹，并删除

find  . -type d -empty -delete 

批量删除文件

find . -name *.log -type f -delete

### 批量强制删除文件夹

```
find . -type d -name target -exec rm -fr "{}" \;

对于每个名为target的文件夹执行 rm -fr命令删除,
`{}`为文件名占位符,`'\;'`为rm命令的结尾

find . \( -name target -o -name bin \) -type d -exec rm -fr "{}" \;

批量删除 target,bin文件夹
这里用到了find的复合条件判断,意思就是要求文件夹名字为target或bin,
-o 代表逻辑运算OR
'\('和'\)'是用转义符将()传递给find,避免脚本解释器(shell)自作主张翻译
这样find才能正确收到完整有效的命令参数 ( -name target -o -name bin )
'\;' 也是同理
```

### Linux下find命令查询指定时间的大文件并删除

```
--时间单位为天
find 查询路径  -ctime/-mtime/-atime 时间范围 -name 文件名称 -type f -exec rm {} \;
--时间单位为分钟
find 查询路径  -cmin/-mmin/-amin 时间范围 -name 文件名称 -type f -exec rm {} \; 
Linux为我们提供了一个简便的查询方式，那就是 +n 和 -n。下面以 -mtime 举例说明：
　　-mtime n : n为数字，意思为在n天之前的“一天之内”被更改过内容的文件
　　-mtime +n : 列出在n天之前（不含n天本身）被更改过内容的文件名
　　-mtime -n : 列出在n天之内（含n天本身）被更改过内容的文件名


--删除/home/testfile目录下修改时间大于2天，后缀为.dat的文件
find /home/testfile  -mtime +2 -name "*.dat" -type f -exec rm {} \;
```

### Rsync

1. `rsync -a source_dir destination_dir`：以归档模式同步目录，保留文件属性和权限。
2. `rsync -v source_dir destination_dir`：输出详细的同步过程信息。



Poll epoll 

##### 三者对比

- select：调用开销大(需要拷贝集合)；集合大小有限制；需要遍历整个集合找到就绪的描述符(只支持LT模式)
- poll：poll采用数组(内核用链表)方式存储文件描述符集合，没有最大存储数量限制，且只需对数组初始化一次；其它与select无区别（LT）
- epoll：调用开销小(无需拷贝)；集合大小无限制；采用回调机制，不需要遍历整个集合（支持LT和ET模式）
- select和poll在用户态维护文件描述符集合，因此每次将完整集合拷贝给内核
- epoll由操作系统内核维护文件描述符集合(epoll_event结构体)，因此只需在创建时传入文件描述符

##### 适用场景

- select和poll：连接数较少且均十分活跃，由于epoll需要很多回调，这两者可能性能更佳
- epoll：连接数较多且有较多不活跃的连接，epoll效率比其它两者高很多



## 防火墙：

```
#查看状态
systemctl status firewalld.service
#停止
systemctl stop firewalld.service
禁止防火墙
systemctl disable firewalld.service
```



## 网络：

### 网卡bond：



## shell 脚本打印日志：

```
function info(){
    DATE_N=`date "+%Y-%m-%d %H:%M:%S.%N" | cut -b 1-23`
    echo -e "$DATE_N|INFO|$@ "
}
 
function warning(){
    DATE_N=`date "+%Y-%m-%d %H:%M:%S.%N" | cut -b 1-23`
    echo -e "\033[33m$DATE_N|WARINIG|$@ \033[0m"
}
 
 
function success(){
    DATE_N=`date "+%Y-%m-%d %H:%M:%S.%N" | cut -b 1-23`
    echo -e "\033[32m$DATE_N|SUCCESS|$@ \033[0m"
}
 
function error(){
    DATE_N=`date "+%Y-%m-%d %H:%M:%S.%N" | cut -b 1-23`
    echo -e "\033[31m$DATE_N|ERROR|$@ \033[0m"
}
```

超过指定天数删除文件

```
指定按照不同的日期创建文件名称
cur_day=`date "+%Y-%m-%d"`
logfile="${logpath}/pushfile_${cur_day}.log"

logfile_num=$(ls -lt  "${logpath}"  | wc -l )
max_num=30
info "   logfile_num is:${logfile_num}"
if  [   $logfile_num -gt  $max_num   ];then

    info " log file  neet to clear, maxnum is:${max_num}"
    exced_num=$(expr $logfile_num - $max_num)
    ## 默认降序排列，最新的在最上边，所以取最后的
    find $logpath -type f | xargs ls -alt  | tail -n -${exced_num} |  awk '{ print $9 }'  | xargs rm -rf
fi

```

```
按照使用率清理文件
capacity=$((9*1024*1024/100*80))
cur_usaged=$( du -sm  $location | awk  -F " " '{print $1}')
echo  $cur_usaged
while ((capacity <= cur_usaged))
do
  cur_usaged=$( du -sm  $location | awk  -F " " '{print $1}')
  find $location -type f | xargs ls -alt  | tail   -n -10 |  awk '{ print $9 }'  | xargs rm -rf
  echo "start delete file, $cur_usaged "
  sleep 10
done
```



### Ubntu 网络配置



/etc/netplan/目录下的01-***.[yaml](https://so.csdn.net/so/search?q=yaml&spm=1001.2101.3001.7020)类似命名的文件

sudo netplan apply 以启动新的网络配置文件



ssh 配置：

```
sudo apt update
sudo apt install openssh-server

sudo systemctl status ssh
sudo systemctl start ssh

路由
sudo route add default gw 192.168.1.1
sudo route del default gw 192.168.1.1

```







## 虚拟机：

1. ```bash
   开机
   vmrun start vmware/Test_Development_Environment/ttzo_CentOS_Stream_8_Test/ttzo_CentOS_Stream_8_Test.vmx nogui
   ```

2. ```bash
   关机
   vmrun stop vmware/Test_Development_Environment/ttzo_CentOS_Stream_8_Test/ttzo_CentOS_Stream_8_Test.vmx soft
   ```

3.  vmrun list  正在运行的服务器列表

```
 scp [option] /path/to/source/file user@server-ip:/path/to/destination/directory
-C - 这会在复制过程中压缩文件或目录。

-P - 如果默认 SSH 端口不是 22，则使用此选项指定 SSH 端口。

-r - 此选项递归复制目录及其内容。

-p - 保留文件的访问和修改时间。

```

```
强制mount



umount /data/disk16 -f
umount: /data/disk16: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1)) 
         
     这个时候我们要找出是哪个进程正在占用这个目录

fuser -mv /data/disk12
                     USER        PID ACCESS COMMAND
/data/disk12:        root     kernel mount /data/disk12
                     hdfs      44545 F.... java 
                     
 关闭并卸载kill -9 44545

fuser -m /data/disk12

umount /data/disk12
出现另外一种情况，我们也无法看到是什么程序正在占用磁盘
umount -l /data/disk20 加给-l参数强制卸载


```

#### mount: unknown filesystem type LVM2_member 解决方法

```
查看逻辑卷：lvdisplay
sudo lvdisplay

--- Logical volume ---
   LV Name             /dev/VolGroup00/LogVol03
   VG Name             VolGroup00
   LV UUID             YhG8Fu-ZGPk-qt8D-AxgC-DzOU-dg1F-z71feI
   LV Write Access        read/write
  LV Status              unenable # 状态非可用状态
   # open                 1
   LV Size             245.97 GB
   Current LE          7871
   Segments             1
   Allocation          inherit
   Read ahead sectors     auto
   - currently set to     256
   Block device           253:2

执行卷组激活

sudo vgchange -ay /dev/VolGroup00
sudo lvdisplay
重新查看
LV Status              available
重新挂载
sudo mount   /dev/VolGroup00/LogVol03   /home/lvm
 
```







## 材料：

1. Linux基础介绍 https://www.junmajinlong.com/linux/index/#systemd

```


[Unit]
Description=My Service
After=network.target

[Service]
ExecStart=bash /usr/local/bin/start_net_storage.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target


安装服务

cp ./*.service /usr/lib/systemd/system
添加开机启动
systemctl enable /usr/lib/systemd/system/test.service


systemctl start test.service

systemctl status test.service	

```

```
route -n

```

