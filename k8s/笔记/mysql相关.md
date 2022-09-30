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

## 索引
### 哈希
散列表（也称哈希表）是根据关键码值(Key value)而直接进行访问的数据结构，它让码值经过哈希函数的转换映射到散列表对应的位置上，查找效率非常高。哈希索引就是基于散列表实现的，假设我们对名字建立了哈希索引，则查找过程如下图所示：


对于每一行数据，存储引擎都会对所有的索引列（上图中的 name 列）计算一个哈希码（上图散列表的位置），散列表里的每个元素指向数据行的指针，由于索引自身只存储对应的哈希值，所以索引的结构十分紧凑，这让哈希索引查找速度非常快！但是哈希索引也有它的劣势，如下：

针对哈希索引，只有精确匹配索引所有列的查询才有效，比如我在列（A,B）上建立了哈希索引，如果只查询数据列 A，则无法使用该索引。

哈希索引并不是按照索引值顺序存存储的，所以也就无法用于排序，也就是说无法根据区间快速查找

哈希索引只包含哈希值和行指针，不存储字段值，所以不能使用索引中的值来避免读取行，不过，由于哈希索引多数是在内存中完成的，大部分情况下这一点不是问题

哈希索引只支持等值比较查询，包括 =,IN()，不支持任何范围的查找，如 age > 17

综上所述，哈希索引只适用于特定场合， 如果用得对，确实能再带来很大的性能提升，如在 InnoDB 引擎中，有一种特殊的功能叫「自适应哈希索引」，如果 InnoDB 注意到某些索引列值被频繁使用时，它会在内存基于 B+ 树索引之上再创建一个哈希索引，这样就能让 B+树也具有哈希索引的优点，比如快速的哈希查找。

关键点：
1. 哈希索引只包含哈希值和行指针，不存储字段值，所以不能使用索引中的值来避免读取行，
2. 适合单列查询，多列不适合

### 链表
双向链表支持顺序查找和逆序查找


### B+树



一种是mysql-binlog-connector，另一种是ali的canal。
mysql-binlog-connector：是通过i引入依赖jar包实现，需要自行实现解析，但是相对轻量。
canal：是数据同步中间件，需要单独部署维护，功能强大，支持数据库及MQ的同步，维护成本高。
根据实际业务场景，按需索取，业务量小，业务简单，轻量可以通过mysql-binlog-connector，业务量大，逻辑复杂，有专门的运维团队，可以考虑canal，比较经过阿里高并发验证，相对稳定。

Canal监听mysql的binlog日志实现数据同步：https://blog.csdn.net/m0_37583655/article/details/119517336
Java监听mysql的binlog详解(mysql-binlog-connector)：https://blog.csdn.net/m0_37583655/article/details/119148470 



数据库表导入导出：

导入：

登录linux,需要sql脚本中指定 use database

mysql -hlocalhost  -uroot -p'root'  -P3306  < /home/sql/0928.sql

导出：

格式：mysqldump -h链接ip -P(大写)端口 -u用户名 -p密码数据库名>d:XX.sql(路劲)

>  示例：mysqldump -h132.72.192.432 -P3307 -uroot -p8888 htgl > bak.sql;



## java 安装配置

vi /etc/profile

JAVA_HOME=/usr/local/jdk1.8.0_231
JRE_HOME=$JAVA_HOME/jre
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
export JAVA_HOME JRE_HOME CLASS_PATH PATH

source /etc/profile 使生效  Java -version 检测安装是否安装成功



## tomcat 配置





