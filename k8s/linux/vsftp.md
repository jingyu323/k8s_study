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

