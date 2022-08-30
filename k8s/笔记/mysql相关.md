# 安装

## mysql8  centos8 安装

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

配置远程登录：

update user set host = '%' where user = 'root';

如果连不上注意关闭防火墙：

systemctl stop firewalld
systemctl disable firewalld

确认时防火墙的问题 再去开放端口即可。



## 集群搭建



## SQL优化

## 分库分表

## 数据库数据同步方案



一种是mysql-binlog-connector，另一种是ali的canal。
mysql-binlog-connector：是通过引入依赖jar包实现，需要自行实现解析，但是相对轻量。
canal：是数据同步中间件，需要单独部署维护，功能强大，支持数据库及MQ的同步，维护成本高。
根据实际业务场景，按需索取，业务量小，业务简单，轻量可以通过mysql-binlog-connector，业务量大，逻辑复杂，有专门的运维团队，可以考虑canal，比较经过阿里高并发验证，相对稳定。

Canal监听mysql的binlog日志实现数据同步：https://blog.csdn.net/m0_37583655/article/details/119517336
Java监听mysql的binlog详解(mysql-binlog-connector)：https://blog.csdn.net/m0_37583655/article/details/119148470 



## java 安装配置

vi /etc/profile

JAVA_HOME=/usr/local/jdk1.8.0_231
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

source /etc/profile 使生效  Java -version 检测安装是否安装成功



## tomcat 配置





