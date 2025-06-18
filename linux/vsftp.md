# VSFTP

1、环境：ftp为vsftp。被限制用户名为test。被限制路径为/home/test
2、建用户：在root用户下：
useradd test //增加用户test，并制定test用户的主目录为/home/test
passwd test //为test设置密码
3、更改用户相应的权限设置：
usermod -s /sbin/nologin test //限定用户test不能telnet，只能ftp
usermod -s /sbin/bash test //用户test恢复正常
usermod -d /test test //更改用户test的主目录为/test
4、限制用户只能访问/home/test，不能访问其他路径
修改/etc/vsftpd/vsftpd.conf如下：
chroot_list_enable=YES //限制访问自身目录
\# (default follows)
chroot_list_file=/etc/vsftpd/vsftpd.chroot_list
编辑 vsftpd.chroot_list文件，将受限制的用户添加进去，每个用户名一行
改完配置文件，不要忘记重启vsFTPd服务器
[root@linuxsir001 root]# /etc/init.d/vsftpd restart 或 service vsftpd status
5、如果需要允许用户修改密码，但是又没有telnet登录系统的权限：
usermod -s /usr/bin/passwd test //用户telnet后将直接进入改密界面

6.别忘记更改文件夹的权限，否则会服务器上传下载文件额。

例如：chmod 777 filename 最高权限，当然你也可以改755 等

修改 ftp 用户的家目录 在/etc/passwd 中修改指定的目录就行 需要重启服务

添加用户：useradd -d /home/video -s /sbin/nologin ftpuser

usermod -aG ftp ftpuser

修改ftp上传文件数组  chown ftpuser /home/video

设置密码

 passwd ftpuser



530 Login incorrect.
Login failed.



Centos8  VSFTP 3.0.3 登录失败需要修改

vi /etc/pam.d/vsftpd



注释掉 #auth       required	pam_shells.so



#%PAM-1.0
session    optional     pam_keyinit.so    force revoke
auth       required	pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
#auth       required	pam_shells.so
auth       include	password-auth
account    include	password-auth
session    required     pam_loginuid.so
session    include	password-auth



systemctl restart vsftpd 重启ftp服务

查看vsftp状态

systemctl status vsftpd

chkconfig vsftpd on



ftp 刚开始传输的时候没有速率：解决方法：

了解到服务器上也有本机的DNS解析，删除了/ETC/RESOLVE.CONF文件之后访问正常，此文件为服务器DNS解析文件。或者增加一条反向解析：/etc/vsftp/vsftp.conf 下增加一条reverse_lookup_enable=NO也可解决此故障。

问题由于本地服务器DNS解析表中没有网段信息，逐条匹配DNS信息后，直到DNS解析超时后，才进行FTP连接，导致的FTP登陆超时问题。

## 主动模式VS被动模式

主动模式和被动模式的不同简单概述为： 主动模式传送数据时是“服务器”连接到“客户端”的端口（客户端开启数据端口）；

被动模式传送数据是“客户端”连接到“服务器”的端口（服务端开启数据端口）。

主动模式需要客户端必须开放端口给FTP服务端，很多客户端都是在防火墙内，开放端口给FTP服务器访问比较困难。

被动模式只需要服务器端开放端口给客户端连接就行了，如果服务端在防火墙内，也需要做端口映射才行。

主动模式和被动模式区别
a. 主动模式传送数据时是“服务器”连接到“客户端”的端口；被动模式传送数据是“客户端”连接到“服务器”的端口。

b. 主动模式需要客户端必须开放端口给服务器，很多客户端都是在防火墙内，开放端口给FTP服务器访问比较困难；被动模式只需要服务器端开放端口给客户端连接就行了。

需要注意的是，被动模式和主动模式的登录过程，都是FTP客户端去连接FTP服务器。 



关于存储磁盘满了的问题：

存储满了之后 xferlog,中的传输记录会 状态为i

Mon Nov 20 12:50:07 2023 1 ::ffff:192.168.99.127 92602368 /xab a _ i r ftpuser ftp 0 * i

删除文件腾出来空间之后，再次上传状态变为c，表明为正常状态。



# Ubuntu vsftpd自动重启设置方法

1. **检查 `vsftpd` 服务状态**：

   ```
   sudo systemctl status vsftpd
   ```

   复制代码

   如果服务未运行，可以使用以下命令启动它：

   ```
   sudo systemctl start vsftpd
   ```

   复制代码

2. **设置 `vsftpd` 服务开机自启动**：

   ```
   sudo systemctl enable vsftpd
   ```

   复制代码

3. **重启 `vsftpd` 服务**：

   ```
   sudo systemctl restart vsftpd
   ```



当 vsftpd 返回 `Connection refused: too many sessions for this address` 时，表示‌**同一 IP 地址发起的 FTP 会话数超过服务端限制**‌，具体原因可能包括：

1. ‌**配置限制**‌
   vsftpd 默认未限制单 IP 的连接数，但若手动配置了 `max_per_ip` 或 `max_clients` 参数且数值过低，会触发此错误14。
2. ‌**资源耗尽**‌
   服务器 TCP 连接数或系统资源（如文件描述符）达到上限，导致新连接被拒绝34。
3. ‌**客户端行为异常**‌
   客户端工具（如 FileZilla）并发上传/下载过多文件，导致连接数激增36



### 二、解决方案步骤

#### 1. 调整 vsftpd 配置

编辑配置文件 `/etc/vsftpd.conf`，修改以下参数：

```
iniCopy Code# 限制每个 IP 的最大并发连接数（示例值为 5）
max_per_ip=5
# 全局最大并发连接数（示例值为 100）
max_clients=100
```

保存后重启服务生效：

```
bashCopy Code



systemctl restart vsftpd  # 或 service vsftpd restart
```

#### 2. 优化系统资源

- ‌**增加 TCP 连接数限制**‌
  修改 `/etc/sysctl.conf`，添加：

  ```
  iniCopy Codenet.core.somaxconn = 1024
  net.ipv4.tcp_max_syn_backlog = 2048
  ```

  执行 `sysctl -p` 生效46。

- ‌**扩大文件描述符限制**‌
  修改 `/etc/security/limits.conf`：

  ```
  iniCopy Code* soft nofile 65535
  * hard nofile 65535
  ```

#### 3. 客户端行为调整

- 减少并发传输线程数（如 FileZilla 中设置「传输 > 最大同时传输数」）3。
- 分批处理大文件，避免一次性提交过多任务36。

#### 4. 排查防火墙与日志

- ‌**检查防火墙规则**‌
  确保未通过 iptables 或云服务商安全组限制 FTP 端口（默认 21）的连接数4。

- ‌**分析日志定位问题**‌
  查看 vsftpd 日志 `/var/log/vsftpd.log`，确认具体拒绝连接的 IP 及频率：

  ```
  bashCopy Code
  
  
  
  grep "too many sessions" /var/log/vsftpd.log
  ```



### 三、配置验证示例

1. ‌**测试单 IP 连接限制**‌
   使用 `ftp` 命令多次连接服务器，观察是否在第 6 次连接时被拒绝（若 `max_per_ip=5`）：

   ```
   bashCopy Code
   
   
   
   ftp your-server-ip
   ```

2. ‌**监控实时连接数**‌
   通过 `netstat` 统计当前 FTP 连接：

   ```
   bashCopy Code
   
   
   
   netstat -an | grep :21 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c
   ```



## 参数



## idle_session_timeout

## data_connection_timeout

当FTP服务端每接收/或发送一次数据包(trans_chunk_size大小，默认值是8KB)，就会复位一次这个定时器。相当于使用FTP客户端命令行工具时，出现传输速率为0的持续时间

