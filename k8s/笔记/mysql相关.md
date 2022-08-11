# 安装

mysql8  centos8 安装

安装顺序：

rpm -ivh mysql-community-common-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-libs-8.0.28-1.el7.x86_64.rpm

pm -ivh mysql-community-libs-compat-8.0.28-1.el7.x86_64.rpm 

rpm -ivh mysql-community-client-plugins-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-libs-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-client-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-icu-data-files-8.0.28-1.el7.x86_64.rpm

 rpm -ivh mysql-community-server-8.0.28-1.el7.x86_64.rpm



1.failed dependencies:
	libcrypto.so.10()(64bit) is needed by mysql-community-libs-8.0.28-1.el7.x86_64
	libcrypto.so.10(libcrypto.so.10)(64bit) is needed by mysql-community-libs-8.0.28-1.el7.x86_64
	libssl.so.10()(64bit) is needed by mysql-community-libs-8.0.28-1.el7.x86_64
	libssl.so.10(libssl.so.10)(64bit) is needed by mysql-community-libs-8.0.28-1.el7.x86_6

解决方法：

 yum install compat-openssl10



2. rpm -ivh mysql-community-client-8.0.28-1.el7.x86_64.rpm 
   warning: mysql-community-client-8.0.28-1.el7.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 3a79bd29: NOKEY
   error: Failed dependencies:
   	libncurses.so.5()(64bit) is needed by mysql-community-client-8.0.28-1.el7.x86_64
   	libtinfo.so.5()(64bit) is needed by mysql-community-client-8.0.28-1.el7.x86_64

解决方法：

yum install libncurses*

d. 启动mysql

systemctl start mysqld

e. 查看初始密码

cat /var/log/mysqld.log

alter user 'root'@'localhost' identified with mysql_native_password by 'root';

vi /etc/my.cnf 去除only_full_group_by模式，文本最后一行添加sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION

