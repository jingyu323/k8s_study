# 安装



解决虚拟机桥接之后没有网络

cd /etc/sysconfig/network-scripts
修改 ONBOOT=yes
重启网卡
nmcli c reload



## mysql8  centos8 安装

### 1、修改hosts

清除残留数据库

```mysql
#卸载mariadb和mysql
rpm -qa | grep mariadb | xargs rpm -e --nodeps
rpm -qa | grep mysql | xargs rpm -e --nodeps

```

执行之后，centos8 默认是没有 mysql和mariadb

修改hostname

hostnamectl set-hostname node1

hostnamectl set-hostname node2

hostnamectl set-hostname node3

```
cat  >  /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.99.137  node1
192.168.99.125  node2
192.168.99.188  node3
EOF

```





安装顺序：

rpm -ivh mysql-community-common-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-client-plugins-8.0.28-1.el7.x86_64.rpm

rpm -ivh mysql-community-libs-compat-8.0.28-1.el7.x86_64.rpm 

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

 yum install compat-openssl10  -y



2. rpm -ivh mysql-community-client-8.0.28-1.el7.x86_64.rpm 
   warning: mysql-community-client-8.0.28-1.el7.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 3a79bd29: NOKEY
   error: Failed dependencies:
   	libncurses.so.5()(64bit) is needed by mysql-community-client-8.0.28-1.el7.x86_64
   	libtinfo.so.5()(64bit) is needed by mysql-community-client-8.0.28-1.el7.x86_64

解决方法：

yum install libncurses* -y

d. 启动mysql

systemctl start mysqld

e. 查看初始密码

cat /var/log/mysqld.log

```sql
 --修改密码策略 ,生产环境不用修改，测试专用
set global validate_password.policy=LOW;
set global validate_password.mixed_case_count=0;
set global validate_password.number_count=0; 
set global validate_password.special_char_count=0; 
set global validate_password.length=1;
set global validate_password.check_user_name='OFF';
```

alter user 'root'@'localhost' identified with mysql_native_password by 'root';
mysql -uroot -p'U!heWdF29ARl'



alter user 'root'@'localhost' identified with mysql_native_password by 'Root@123';

mysql -uroot -p'Root@123'





alter user 'root'@'localhost' identified with mysql_native_password by 'root';

mysql -uroot -p'root'


```
配置远程登录：

update user set host = '%' where user = 'root';

grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;
```


vi /etc/my.cnf 去除only_full_group_by模式，文本最后一行添加sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION




如果连不上注意关闭防火墙：

systemctl stop firewalld
systemctl disable firewalld



systemctl status firewalld

确认时防火墙的问题 再去开放端口即可。

关闭防火墙之后还是连不上可以重启

systemctl restart mysqld

```
grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;
```


vi /etc/my.cnf 去除only_full_group_by模式，文本最后一行添加sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION

sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION



##### 数据库导出命令：

mysqldump -u dbuser -p dbname > dbname.sql 

## MySQL 架构

Connectors连接器：负责跟客户端建立连接 

Management Serveices & Utilities系统管理和控制工具

 Connection Pool连接池：管理用户连接，监听并接收连接的请求，转发所有连接的请求到线程管 理模块 

SQL Interface SQL接口：接受用户的SQL命令，并且返回SQL执行结果

 Parser解析器：SQL传递到解析器的时候会被解析器验证和解析

 Optimizer查询优化器：SQL语句在查询之前会使用查询优化器对查询进行优化 explain语句查看的SQL语句执行计划，就是由此优化器生成 

Cache和Buffer查询缓存：在MySQL5.7中包含缓存组件。在MySQL8中移除了 

Pluggable Storage Engines存储引擎：存储引擎就是存取数据、建立与更新索引、查询数据等技 术的实现方法



### 查询缓存

不建议开启，命中率不高



## 集群搭建

### 集群架构：

mysql安装包下载地址：https://dev.mysql.com/downloads/

### mysql主从复制主要有三种方式：

1. 基于[SQL语句](https://so.csdn.net/so/search?q=SQL语句&spm=1001.2101.3001.7020)的复制(statement-based replication, SBR)
2. 基于行的复制(row-based replication, RBR)
3. 混合模式复制

### 二进制日志(bin log)

```text
#默认是关闭的，需要通过以下配置进行开启。
log-bin=mysql-bin
```

 其中mysql-bin是binlog日志文件的basename，binlog日志文件的完整名称：mysql-bin-000001.log

binlog记录了数据库所有的ddl语句和dml语句，但不包括select语句内容，语句以事件的形式保存，描述了数据的变更顺序，binlog还包括了每个更新语句的执行时间信息。如果是DDL语句，则直接记录到binlog日志，而DML语句，必须通过事务提交才能记录到binlog日志中。 binlog主要用于实现mysql主从复制、数据备份、数据恢复。

### Router搭建集群

安装 mysqlsh

```
[root@localhost soft]# rpm -ivh mysql-shell-8.0.30-1.el8.x86_64.rpm
warning: mysql-shell-8.0.30-1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 3a79bd29: NOKEY
error: Failed dependencies:
	libpython3.9.so.1.0()(64bit) is needed by mysql-shell-8.0.30-1.el8.x86_64

解决方法：
http://rpmfind.net/linux/rpm2html/search.php  搜一下安装包

实在安装不了试试 yum命令
yum install mysql-shell-8.0.30-1.el8.x86_64.rpm
Last metadata expiration check: 0:12:30 ago on Mon 10 Oct 2022 09:34:05 AM EDT.
Dependencies resolved.
============================================================================================================
 Package                       Arch       Version                                    Repository        Size
============================================================================================================
Installing:
 mysql-shell                   x86_64     8.0.30-1.el8                               @commandline      19 M
Installing dependencies:
 python39-libs                 x86_64     3.9.13-1.module_el8.7.0+1178+0ba51308      appstream        8.2 M
 python39-pip-wheel            noarch     20.2.4-7.module_el8.7.0+1213+291b6551      appstream        1.1 M
 python39-setuptools-wheel     noarch     50.3.2-4.module_el8.6.0+930+10acc06f       appstream        497 k
Installing weak dependencies:
 python39                      x86_64     3.9.13-1.module_el8.7.0+1178+0ba51308      appstream         33 k
 python39-pip                  noarch     20.2.4-7.module_el8.7.0+1213+291b6551      appstream        1.9 M
 python39-setuptools           noarch     50.3.2-4.module_el8.6.0+930+10acc06f       appstream        871 k
Enabling module streams:
 python39                                 3.9                                                              

Transaction Summary
============================================================================================================
Install  7 Packages
```

```
# 使用如下命令 开启mysqlshell 终端
mysqlsh

# 配置各服务器为集群模式
shell.connect('root@node1:3306')
dba.configureLocalInstance()
shell.connect('root@node2:3306')
dba.configureLocalInstance()
shell.connect('root@node2:3306')
dba.configureLocalInstance()
 
###创建集群组，并将添加示例进集群组
shell.connect('root@node1:3306')
var cluster=dba.createCluster("MySQL_Cluster")
#将另外两台实例添加至集群中
cluster.addInstance('root@node2:3306');
cluster.addInstance('rootr@node3:3306');
cluster.status();         #查看集群状态
## 查询结果如下
{
    "clusterName": "MySQL_Cluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "node1:3306", 
        "ssl": "REQUIRED", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "node1:3306": {
                "address": "node1:3306", 
                "memberRole": "PRIMARY", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.30"
            }, 
            "node2:3306": {
                "address": "node2:3306", 
                "memberRole": "SECONDARY", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.30"
            }, 
            "node3:3306": {
                "address": "node3:3306", 
                "memberRole": "SECONDARY", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "replicationLag": "applier_queue_applied", 
                "role": "HA", 
                "status": "ONLINE", 
                "version": "8.0.30"
            }
        }, 
        "topologyMode": "Single-Primary"
    }, 
    "groupInformationSourceMember": "node1:3306"
}


SELECT clusters.cluster_id,clusters.cluster_name from mysql_innodb_cluster_metadata.clusters;

```



```
Cluster.addInstance: Cannot add an instance with the same server UUID (200951b7-4895-11ed-a25e-000c29b1aeff) of an active member of the cluster 'node1:3306'. Please change the server UUID of the instance to add, all members must have a unique server UUID. (RuntimeError)

解决方案：
1、利用uuid函数生成新的uuid

mysql> select uuid();
+--------------------------------------+
| uuid()                               |
+--------------------------------------+
| b33057ff-bec6-11eb-ad94-000c29af6856 |
+--------------------------------------+
1 row in set (0.00 sec)
2、查看配置文件目录

mysql> show variables like 'datadir';
+---------------+-----------------+
| Variable_name | Value           |
+---------------+-----------------+
| datadir       | /var/lib/mysql/ |
+---------------+-----------------+
1 row in set (0.03 sec)
3、编辑配置文件目录

vi /var/lib/mysql/auto.cnf
4、uuid修改新生成的uuid

server-uuid=b33057ff-bec6-11eb-ad94-000c29af6856
5、重启服务

service mysqld restart
```



安装router

rpm  -ivh mysql-router-community-8.0.30-1.el8.x86_64.rpm

编辑/etc/mysqlrouter/mysqlrouter.conf

vi /etc/mysqlrouter/mysqlrouter.conf

添加如下内容：

```
#配置读写规则
[routing:read_write]
bind_address = 0.0.0.0
bind_port = 7001
mode = read-write
destinations = node1:3306,node2:3306
protocol=classic
max_connections=2024
 
 #配置负载均衡
[routing:read_only]
bind_address = 0.0.0.0
bind_port = 7002
mode = read-only
destinations = node2:3306,node3:3306
protocol=classic
max_connections=1024


## 
systemctl restart mysqlrouter
## 添加开机启动
systemctl enable mysqlrouter
```

netstat -tnlp 
tcp        0      0 0.0.0.0:7001            0.0.0.0:*               LISTEN      1023/mysqlrouter 
tcp        0      0 0.0.0.0:7002            0.0.0.0:*               LISTEN      1023/mysqlrouter  

即可通过router所在的服务器IP：7001登陆数据库
即可通过router所在的服务器IP：7002登陆数据库


登陆成功表明数据库router 配置成功


### 主从配置：

alter user 'root'@'localhost' identified  with mysql_native_password  by 'root';


 mysql -uroot -p'root' 


 update user set host = "%" where  user = 'root';

 hostnamectl set-hostname node1
 hostnamectl set-hostname node2
 hostnamectl set-hostname node3


 修之后如果登录不上，需要重启服务器，检查防火墙，我这边是测试直接停掉防火墙，如果是正式环境需要根据规则放通端口
 systemctl restart mysqld

 

 添加之后重启报错：
 Job for mysqld.service failed because the control process exited with error code. See "systemctl status mysqld.service" and "journalctl -xe" for details.
由于server_id包含了字母导致的不能正常启动

 


 #### 1.主备复制
CREATE USER 'copy'@'%' IDENTIFIED BY 'Copy@123456';
alter user 'copy'@'%' identified with mysql_native_password by 'Copy@123456';
grant all privileges on *.* to 'copy'@'%' with grant option;

flush privileges;


select host,user from mysql.user;


--查看copy用户权限情况，由于上面命令给的ALL权限所以这里显示结果比较多
show grants for 'copy'@'%';


##### 开启二进制日志文件和添加server-id
主节点/etc/my.cnf添加内容：

##### 开启二进制日志功能
log-bin=mysql-bin
binlog_format=mixed
binlog-ignore-db=mysql

##### 设置二进制日志使用内存大小（事务）
binlog_cache_size=1M
##### 设置使用的二进制日志格式(mixed,statement,row)
binlog_format=mixed
##### 二进制日志过期清理时间。默认值为0，表示不自动清理。
##### 新版8的配置
binlog_expire_logs_seconds=604800
##### 跳过主从复制中遇到的所有错误或指定类型的错误，避免slave端复制中断。
##### 如：1062错误是指一些主键重复，1032错误是因为主从数据库数据不一致,
slave-skip-errors=all
server-id=13306

从节点/etc/my.cnf添加内容:
node2 
server-id=23306
slave-skip-errors=all
binlog_format=mixed
binlog-ignore-db=mysql
binlog_expire_logs_seconds=604800

#只保留7天的二进制日志，以防磁盘被日志占满(可选)

expire-logs-days = 7

node3
server-id=33306
slave-skip-errors=all
binlog_format=mixed
binlog-ignore-db=mysql
binlog_expire_logs_seconds=604800

##### 注意，注意，注意,只有master节点有mysql-bin配置，每个节点的server-id必须不同,只能用数字不能用字母

添加完成重启mysql
systemctl restart mysqld

登入主节点mysql重置偏移量
先查看状态
show master status;

--重置偏移量如果不重置，从节点也会创建copy用户
reset master;
show master status;

show slave status;

5.注册从节点
登入所有从节点的mysql上执行以下命令:
master_host : 主节点主机名
master_user : 第2步创建的主从同步账户
master_port : 主节点mysql服务的端口号，因为没有这里改过所以是 3306
master_password : 第2步创建的主从同步账户的密码
master_log_file : 第4步获取的二进制文件名字
master_log_pos : 第4步获取的Position值

登陆从节点执行:
stop slave;
reset slave;

change master to master_host='node1',master_user='copy',master_port=3306,master_password='Copy@123456',master_log_file='mysql-bin.000001',master_log_pos=155,master_connect_retry=30;

启动 启动所有从节点的slave
start slave; 

启动的时候报错：

``` Last_IO_Errno: 2005  Last_IO_Error: error connecting to master 'copy@node1:3306' - retry-time: 60 retries: 1 message: Unknown MySQL server host 'node1' (2)```
				

				没有配置hosts IP映射，配置之后就好了

执行了一段时间添加
Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'binlog truncated in the middle of event; consider out of disk space on master; the first event 'mysql-bin.000001' at 157, the last event read from './mysql-bin.000001' at 124, the last byte read from './mysql-bin.000001' at 574.'

是由于position 已经更改，需要使用当前新的position
change master to master_host='node1',master_user='copy',master_port=3306,master_password='Copy@123456',master_log_file='mysql-bin.000001',master_log_pos=574;


show slave status \G

     状态都为yes  表明配置成功
       Slave_IO_Running: Yes
       Slave_SQL_Running: Yes

登陆主节点 创建测试数据库

 create database test_sync;

 登陆从节点 查看数据库是否已经同步
 show databases;

 如果已经创建test_sync 则表明主从复制配置完成。



#### 主从切换

show processlist;
直到看到状态都为 XXX has read all relay log 表示从库更新均执行完毕，则可以进行下一步。 

  stop slave;  # 完全停止 slave 复制 
  reset slave  ; # 完全清空 slave 复制信息
  reset master; # 清空本机上 master 的位置信息

如果遇到：when reading data from binary log: 'Could not find first log file name in binary log index file
flush logs;

这种都是 配置文件名称不正确导致

log: 'Could not find first log file name in binary log index file', Error_code: MY-013114	

```
flush logs;

show master status;

可以查看当前的binlog 文件是那个


因为刷新日志file的位置会+1，即File变成为:mysqld-bin.000011

马上到slave执行

CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000002',MASTER_LOG_POS=157;
  start  slave; 
  show slave status;
  
   状态都为yes  表明配置成功
   Slave_IO_Running: Yes
   Slave_SQL_Running: Yes
```



#### 2.双主复制

双主相对于主备复制多了一个从备复制到主的配置



1.保证两台数据库能够互相访问
在内网中保证两台服务器分别能访问对方的数据库信息：

```
my.cnf 配置
[mysqld]
log-bin=mysql-bin
binlog_format=mixed
binlog-ignore-db=mysql
innodb_force_recovery = 0
binlog_cache_size=1M
slave-skip-errors=all

# 只设置默认的忽略的就可以同步所有新创建的数据库和表
replicate-ignore-db = mysql,information_schema,performance_schema
log-slave-updates=on
auto_increment_offset=1 
auto_increment_increment=2




A服务器上设置B数据库权限：

CREATE USER 'copy'@'%' IDENTIFIED BY 'Copy@123456';
alter user 'copy'@'%' identified with mysql_native_password by 'Copy@123456';
grant all privileges on *.* to 'copy'@'%' with grant option;

flush privileges;
 
B服务器上设置A数据库权限

CREATE USER 'copy'@'%' IDENTIFIED BY 'Copy@123456';
alter user 'copy'@'%' identified with mysql_native_password by 'Copy@123456';
grant all privileges on *.* to 'copy'@'%' with grant option;

flush privileges;

使用同一个账户就行



change master to master_host='192.168.99.127',master_user='copy',master_port=3306,master_password='Copy@123456',master_log_file='mysql-bin.000001',master_log_pos=157;

start slave;

show slave status
```







### MHA环境搭建：


### 数据不一致问题处理

工具下载
https://www.percona.com/downloads/percona-toolkit/LATEST/


```

Can't locate Digest/MD5.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at ./pt-table-checksum line 788
解决方案：
yum -y install perl-Digest-MD5 

```

参考材料：

https://www.jianshu.com/p/72d824fc1eaa

### Cluster环境搭建：





参考材料：

https://cloud.tencent.com/developer/article/1508235



## MySQL升级

### 

## SQL优化

### 执行计划

type字段的结果值，从好到坏依次是：system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL
一般来说，好的sql查询至少达到range级别，最好能达到ref









## 分库分表

### 分库

单纯的分库就是垂直切分，把不同业务逻辑的表分开存储在在不同的数据库

分库的主要目的是为突破单节点数据库服务器的I/O能力限制，解决数据库水平扩展性问题。

水平分库

- 水平分库和水平分表相似，并且关系紧密，水平分库就是将单个库中的表作水平分表，然后将子表分别置于不同的子库当中，独立部署。
- 因为库中内容的主要载体是表，所以水平分库和水平分表基本上如影随形。
- 例如用户表，我们可以使用注册时间的范围来分表，将2020年注册的用户表usrtb2020部署在usrdata20中，2021年注册的用户表usrtb2021部署在usrdata21中。

垂直分库

- 同样的，垂直分库和垂直分表也十分类似，不过垂直分表拆分的是字段，而垂直分库，拆分的是表。
- 垂直分库是将一个库下的表作不同维度的分类，然后将其分配给不同子库的策略。
- 例如，我们可以将用户相关的表都放置在usrdata这个库中，将订单相关的表都放置在odrdata中，以此类推。
- 垂直分库的分类维度有很多，可以按照业务模块划分（用户/订单...），按照技术模块分（日志类库/图片类库...），或者空间，时间等等。



事务问题。

- **问题描述**：在执行分库分表之后，由于数据存储到了不同的库上，数据库事务管理出现了困难。如果依赖数据库本身的分布式事务管理功能去执行事务，将付出高昂的性能代价；如果由应用程序去协助控制，形成程序逻辑上的事务，又会造成编程方面的负担。
- **解决方法**：利用分布式事务，协调不同库之间的数据原子性，一致性。

跨库跨表的join问题。

- **问题描述**：在执行了分库分表之后，难以避免会将原本逻辑关联性很强的数据划分到不同的表、不同的库上，这时，表的关联操作将受到限制，我们无法join位于不同分库的表，也无法join分表粒度不同的表，结果原本一次查询能够完成的业务，可能需要多次查询才能完成。
- **解决方法**：tddl、MyCAT等都支持跨分片join。但是我们应该尽力避免跨库join，如果一定要整合数据，那么请在代码中多次查询完成。

额外的数据管理负担和数据运算压力。

- **问题描述**：额外的数据管理负担，最显而易见的就是数据的定位问题和数据的增删改查的重复执行问题，这些都可以通过应用程序解决，但必然引起额外的逻辑运算，例如，对于一个记录用户成绩的用户数据表userTable，业务要求查出成绩最好的100位，在进行分表之前，只需一个order by语句就可以搞定，但是在进行分表之后，将需要n个order by语句，分别查出每一个分表的前100名用户数据，然后再对这些数据进行合并计算，才能得出结果。
- **解决方法**：无解，这是水平拓展的代价。

### 分区

局限于单一数据库节点，将一张表分散存储在不同的物理块中



查询分区信息：

SELECT partition_name, partition_ordinal_position, partition_method, partition_expression, partition_description
FROM information_schema.partitions
WHERE table_schema = 'rain_test' AND table_name = 'user';



去除：only_full_group_by 兼容问题， 新安装的数据库不添加sql mode 就容易出现这个问题

sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION



#### 分区实现方式：

1. ##### 直接创建分区表



​	

2. ##### 已有数据库改造





### 分片

分表顾名思义，就是把一张超大的数据表，拆分为多个较小的表，得到有效的缓解。

超大表会带来如下的影响：

1. 单表数据量太大，会被频繁读写，加锁操作密集，导致性能降低。
2. 单表数据量太大，对应的索引也会很大，查询效率降低，增删操作的性能也会降低。

实现方式：



### 分表

侧重点不同，分区侧重提高读写性能，分表侧重提高并发性能。两者不冲突，可以配合使用。

## 千万级别数据处理

## 锁

表级的锁是 MDL（metadata lock)
- 读锁之间不互斥，因此你可以有多个线程同时对一张表增删改查。

- 读写锁之间、写锁之间是互斥的，用来保证变更表结构操作的安全性。因此，如果有两个线程要同时给一个表加字段，其中一个要等另一个执行完才能开始执行。


给一个表加字段，或者修改字段，或者加索引，需要扫描全表的数据。在对大表操作的时候，以免对线上服务造成影响。 行锁释放不会 立即释放，
3. 表级锁
3.1 表读锁(Table Read Lock) 
3.2 表写锁(Table Write Lock) 
3.3 元数据锁(meta data lock，MDL) 
3.4 自增锁(AUTO-INC Locks)



查看表锁情况:
```
show  open tables;

# 查看表锁定状态
mysql> show status like 'table%';
```
删除表锁:
```
unlock tables;
```

行级锁
4.1  什么是行级锁?
MySQL的行级锁，是由存储引擎来实现的，这里我们主要讲解InnoDB的行级锁。
InnoDB行锁是通过给 索引上的索引项加锁来实现的，因此InnoDB这种行锁实现特点:只有通过索引条件检索的数据，
 InnoDB才使用行级锁，否则，InnoDB将使用表锁!

InnoDB的行级锁，按照锁定范围来说，分为四种:
      记录锁(Record Locks):锁定索引中一条记录。
      间隙锁(Gap Locks):要么锁住索引记录中间的值，要么锁住第一个索引记录前面的值或者 最后一个索引记录后面的值。
      临键锁(Next-Key Locks):是索引记录上的记录锁和在索引记录之前的间隙锁的组合(间 隙锁 + 记录锁)。
      插入意向锁(Insert Intention Locks):做insert操作时添加的对记录id的锁。
InnoDB的行级锁，按照功能来说，分为两种:
     读锁:允许一个事务去读一行，阻止其他事务更新目标行数据。同时阻止其他事务加写锁，但
     不阻止其他事务加读锁。
     写锁:允许获得排他锁的事务更新数据，阻止其他事务获取或修改数据。同时阻止其他事务加
     读锁和写锁。

 - InnoDB的行级锁，按照锁定范围来说，分为四种:
     - 记录锁(Record Locks):锁定索引中一条记录。
     - 间隙锁(Gap Locks):要么锁住索引记录中间的值，要么锁住第一个索引记录前面的值或者 最后一个索引记录后面的值。
     - 临键锁(Next-Key Locks):是索引记录上的记录锁和在索引记录之前的间隙锁的组合(间 隙锁 + 记录锁)。
     - 插入意向锁(Insert Intention Locks):做insert操作时添加的对记录id的锁。

如何加行级锁?
对于UPDATE、DELETE和INSERT语句，InnoDB会自动给涉及数据集加写锁; 
对于普通SELECT语句，InnoDB不会加任何锁 事务可以通过以下语句手动给记录集加共享锁或排他锁。
4.3 加锁规则【非常重要】 主键索引
等值条件，命中，加记录锁 等值条件，未命中，加间隙锁 范围条件，命中，包含where条件的临键区间，加临键锁 范围条件，没有命中，加间隙锁
辅助索引
等值条件，命中，命中记录的辅助索引项 + 主键索引项加记录锁，辅助索引项两侧加间隙锁 等值条件，未命中，加间隙锁 范围条件，命中，包含where条件的临键区间加临键锁。命中记录的id索引项加记录锁 范围条件，没有命中，加间隙锁

#### 锁相关参数
InnoDB所使用的行级锁定争用状态查看:
```
show status  like  'innodb_row_lock%';
```
Innodb_row_lock_current_waits:当前正在等待锁定的数量;
 Innodb_row_lock_time:从系统启动到现在锁定总时间长度;
  Innodb_row_lock_time_avg:每次等待所花平均时间; 
  Innodb_row_lock_time_max:从系统启动到现在等待最常的一次所花的时间; 
  Innodb_row_lock_waits:系统启动后到现在总共等待的次数;




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



## MySQL Shell

```
dba.checkInstanceConfiguration("root@hostname:3306")     #检查节点配置实例，用于加入cluster之前
 
dba.rebootClusterFromCompleteOutage('myCluster');        #重启
 
dba.dropMetadataSchema();                                #删除schema
 
var cluster = dba.getCluster('myCluster')                #获取当前集群
 
cluster.checkInstanceState("root@hostname:3306")         #检查cluster里节点状态
 
cluster.rejoinInstance("root@hostname:3306")             #重新加入节点，我本地测试的时候发现rejoin一直无效，每次是delete后
 
addcluster.dissolve({force：true})                       #删除集群
 
cluster.addInstance("root@hostname:3306")                #增加节点
 
cluster.removeInstance("root@hostname:3306")             #删除节点
 
cluster.removeInstance('root@host:3306',{force:true})    #强制删除节点
 
cluster.dissolve({force:true})                           #解散集群
 
cluster.describe();                                      #集群描述
```





## 数据库表导入导出：

导入：

1、导出数据和表结构：

mysqldump -u用户名 -p密码 数据库名 > 数据库名.sql

mysqldump -uroot -p abc > abc.sql

mysql -hlocalhost  -uroot -p'root'  -P3306  < /home/sql/0928.sql

加上端口和IP 可以指定数据库

导出：

格式：mysqldump -h链接ip -P(大写)端口 -u用户名 -p密码  数据库名>d:XX.sql(路径)

>  示例：mysqldump -h132.72.192.432 -P3307 -uroot -p8888 htgl > bak.sql;
>
> 导入的时候 添加上数据库名称 就不用sql脚本 中指定了



# mysql 日志



常用日志文件如下： 

1. 错误日志：/var/log/mysql-error.log 
2.  二进制日志：/var/lib/mysql/mysql-bin  
3.  查询日志：
4.   慢查询日志：slow_query_log.log 
5.  事务重做日志：redo log 
6.  中继日志：relay log

可以通过命令查看当前数据库中的日志使用信息：

show variables like 'log_%';

1.错误日志（errorlog）log_error 参数控制错误日志是否写入文件及文件名称，默认情况下，错误日志被写入终端标准输出stderr

```
# 指定错误日志位置及名称
vim ``/etc/my``.cnf 
[mysqld] 
log_error = ``/data/mysql/logs/error``.log
```

2.慢查询日志（slow query log）

慢查询日志是用来记录执行时间超过 long_query_time 这个变量定义的时长的查询语句。通过慢查询日志，可以查找出哪些查询语句的执行效率很低，以便进行优化。

与慢查询相关的几个参数如下：

1. slow_query_log ：是否启用慢查询日志，默认为0，可设置为0，1。
2. slow_query_log_file ：指定慢查询日志位置及名称，默认值为host_name-slow.log，可指定绝对路径。
3. long_query_time ：慢查询执行时间阈值，超过此时间会记录，默认为10，单位为s。
4. log_output ：慢查询日志输出目标，默认为file，即输出到文件。

默认情况下，慢查询日志是不开启的，一般情况下建议开启，方便进行慢SQL优化。在配置文件中可以增加以下参数：

```
# 慢查询日志相关配置，可根据实际情况修改``vim /etc/my.cnf `
`[mysqld] ``slow_query_log = 1``slow_query_log_file = /data/mysql/logs/slow.log``long_query_time = 3``log_output = FILE
```

3.一般查询日志（general log）

一般查询日志又称通用查询日志，是 MySQL 中记录最详细的日志，该日志会记录 mysqld 所有相关操作，当 clients 连接或断开连接时，服务器将信息写入此日志，并记录从 clients 收到的每个 SQL 语句。当你怀疑 client 中的错误并想要确切知道 client 发送给mysqld的内容时，通用查询日志非常有用。

查询通用查询日志变量信息

```
 show global variables like '%general_log%';
```

默认情况下，general log 是关闭的，开启通用查询日志会增加很多磁盘 I/O， 所以如非出于调试排错目的，不建议开启通用查询日志。相关参数配置介绍如下：

```
# general log相关配置``vim ``/etc/my``.cnf ``[mysqld]``general_log = 0 ``//``默认值是0，即不开启，可设置为1``general_log_file = ``/data/mysql/logs/general``.log ``//``指定日志位置及名称
```

4.二进制日志（binlog）

关于二进制日志，前面有篇文章做过介绍。它记录了数据库所有执行的DDL和DML语句（除了数据查询语句select、show等），以事件形式记录并保存在二进制文件中。常用于数据恢复和主从复制。

与 binlog 相关的几个参数如下：

- log_bin ：指定binlog是否开启及文件名称。
- server_id ：指定服务器唯一ID，开启binlog 必须设置此参数。
- binlog_format ：指定binlog模式，建议设置为ROW。
- max_binlog_size ：控制单个二进制日志大小，当前日志文件大小超过此变量时，执行切换动作。
- expire_logs_days ：控制二进制日志文件保留天数，默认值为0，表示不自动删除，可设置为0~99。

binlog默认情况下是不开启的，不过一般情况下，建议开启，特别是要做主从同步时。

```
# binlog 相关配置``vim /etc/my.cnf ``[mysqld]``server-id = 1003306``log-bin = /data/mysql/logs/binlog``binlog_format = row``expire_logs_days = 15
```

5. logbuffer 
   内存日志
6. 日志落盘
   - Redo 日志落盘
     事务提交的时候写日志到磁盘

 Log BUffer写入磁盘时机由参数innodb_flush_log_at_trx_commit 控制
 - 0 代表每秒写入与事务无关
 - 1 代表事务提交写入磁盘   
 - 2 代表先写入os缓冲区，固定时间刷新到磁盘


7. checkpoint 
   什么是脏页？ 首先修改的数据在内存结构缓冲区中的页，缓冲区中的页与磁盘中的页数据不一致，所以成为缓冲区中的页为赃页
   如何刷新到磁盘？赃页从缓冲区刷新到磁盘，不是每次修改之后刷新而是通过checkpoint机制刷新磁盘。

   解决什么问题？
   - 脏页落盘，避免数据操作直接更改磁盘
   - 缩短数据恢复时间：数据库宕机时，不用重做所有redo日志，大大缩短恢复时间
   - 缓冲池不够用时将脏页刷新到磁盘：Bufferpool不够用的时候溢出页落盘，Lru淘汰非热点数据
   - redo日志不可用时：redo日志有固定大小，循环使用

Fuzzy checkpoint：四种检查点。
- 脏页太多 默认阈值是75%，脏页数据占到缓冲池总数75%时触发检查点落盘
- 缓冲池不够用时 根据LRU算法淘汰最近很少使用的情况的时候
- 重做日志不可用
- 固定刷新 每10秒一次的频率刷新，整个过程是异步的，不影响主用户进程
 通过 checkpoint 进行赃页落盘



 双写机制保证数据完整性 安全性，防止写入磁盘的时候部分写入失败的情况
 双写流程
- 首先复制赃页到双写缓冲区
- 第一次先顺序写入系统表空间-备份赃页
- 第二次 离散写入用户表空间
- 写入完成清理redolog

双写崩溃恢复过程：
- 找到系统表空间中双写缓冲区在对应的赃页副本数据
- 然后将其复制到独立表空间
- 最后应用redolog
  

 #### 什么是赃页？


## 具体问题解决

1.MySQL错误Illegal mix of collations (utf8_unicode_ci,IMPLICIT) and (utf8_general_ci,IMPLICIT)

解决方案：

检查表的集合规则，将两张表的编码集合改为一致

alter table htgw_sync_group convert to character set utf8 collate utf8mb3_unicode_ci;
##  锁

### 死锁

当出现死锁以后，有两种策略：一种策略是，直接进入等待，直到超时。这个超时时间可以通过参数 innodb_lock_wait_timeout 来设置。
另一种策略是，发起死锁检测，发现死锁后，主动回滚死锁链条中的某一个事务，让其他事务得以继续执行。将参数 innodb_deadlock_detect 设置为 on，表示开启这个逻辑。


查看db状态
show engine innodb status\G


###  发生死锁时
```
SELECT
    a.trx_id,
    d.SQL_TEXT,
    a.trx_state,
    a.trx_started,
    a.trx_query,
    b.ID,
    b.USER,
    b.DB,
    b.COMMAND,
    b.TIME,
    b.STATE,
    b.INFO,
    c.PROCESSLIST_USER,
    c.PROCESSLIST_HOST,
    c.PROCESSLIST_DB 
FROM
    information_schema.INNODB_TRX a
    LEFT JOIN information_schema.PROCESSLIST b ON a.trx_mysql_thread_id = b.id 
    LEFT JOIN PERFORMANCE_SCHEMA.threads c ON b.id = c.PROCESSLIST_ID
    LEFT JOIN PERFORMANCE_SCHEMA.events_statements_current d ON d.THREAD_ID = c.THREAD_ID;

2.分析锁定范围
SELECT ENGINE,ENGINE_TRANSACTION_ID,THREAD_ID,EVENT_ID,OBJECT_SCHEMA,OBJECT_NAME,INDEX_NAME,LOCK_TYPE, LOCK_MODE,LOCK_STATUS,LOCK_DATA FROM performance_schema.data_locks;

```
## 事务
### 事务并发问题

- 脏读 ： 一个事务读到了另一个事务未提交的数据
- 不可重复读 ：一个事务读到了领一个事务已经更新的数据，引发事务中多次查询结果不一致
- 幻读 ： 一个事务读到了另一个事务已经插入的数据，导致事务查询结果不一致
### 隔离级别
- 读未提交  一个事务读到了另一个事务未提交的数据
  -  存在3个问题：脏读、不可重复读、幻读
- 读已提交 一个事务读到了另一个事务已经提交的数据
  - 存在问题： 不可重复读、幻读
- 可重复读 一个事务读到的数据始终保持一致，无论另一个事务是否提交
  - 存在问题： 幻读
- 串行 同一时刻只能执行一个事务

常见数据库的默认隔离级别：
MySql： repeatable read
Oracle： read committed

### 更新丢失
- 基于版本控制
- 数据枷锁
### MVCC 读不加锁，读写不冲突
实现原理，不同的事务访问快照中不同的版本的数据

#### 什么是ReadView?
ReadView是张存储事务id的表，主要包含当前系统中有哪些活跃的读写事务，把它们的事务id放到一个
列表中。结合Undo日志的默认字段【事务trx_id】来控制那个版本的Undo日志可被其他事务看见。 四个列:
m_ids:表示在生成ReadView时，当前系统中活跃的读写事务id列表 m_low_limit_id:事务id下限，表示当前系统中活跃的读写事务中最小的事务id，m_ids事务列表 中的最小事务id m_up_limit_id:事务id上限，表示生成ReadView时，系统中应该分配给下一个事务的id值
1 2 3
# 事务2:
update tab_user set name='雄雄',age=18 where id=10;
##### 当事务2使用Update语句修改该行数据时，会首先使用写锁锁定目标行，将该行当前的值复制到Undo 中，然后再真正地修改当前行的值，最后填写事务ID，使用回滚指针指向Undo中修改前的行。
m_creator_trx_id:表示生成该ReadView的事务的事务id

MySQL 8.0
```
CREATE TABLE `tab_user` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `age` int(11) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
Insert into tab_user(id,name,age,address) values (1,'刘备',18,'蜀国');
```

```
# 事务01
-- 查询事务隔离级别:
#select @@tx_isolation;
SELECT @@transaction_isolation;
-- 设置数据库的隔离级别
set session transaction isolation level read committed; SELECT * FROM tab_user; # 默认是刘备
# Transaction 100
BEGIN;
UPDATE tab_user SET name = '关羽' WHERE id = 1; 
UPDATE tab_user SET name = '张飞' WHERE id = 1; 
COMMIT;

```

```
# 事务02
-- 查询事务隔离级别:
#select @@tx_isolation;
SELECT @@transaction_isolation;
-- 设置数据库的隔离级别
set session transaction isolation level read committed;
# Transaction 200
BEGIN;
# 更新了一些别的表的记录
...
UPDATE tab_user SET name = '赵云' WHERE id = 1;
UPDATE tab_user SET name = '诸葛亮' WHERE id = 1; COMMIT;
```

```
# 事务03
-- 查询事务隔离级别:
#select @@tx_isolation;
SELECT @@transaction_isolation;
-- 设置数据库的隔离级别
set session transaction isolation level read committed;
BEGIN;
# SELECT01:Transaction 100、200未提交
SELECT * FROM tab_user WHERE id = 1; # 得到的列c的值为'刘备'
# SELECT02:Transaction 100提交，Transaction 200未提交 SELECT * FROM tab_user WHERE id = 1; # 得到的列c的值为'张飞'
# SELECT03:Transaction 100、200提交
SELECT * FROM tab_user WHERE id = 1; # 得到的列c的值为'诸葛亮' COMMIT;
```
## update

数据库更新的时候，更新先找到一条记录然后枷锁，更新完成之后再找下一条记录

## 索引
索引是提高查询效率，使用B+树
### 索引类型
-  聚簇索引
-  辅助索引
-  组合索引
-  唯一索引

单列索引： 只有一个列
-  主键索引： 必须唯一，不能为null
-  唯一索引： 必须唯一，可以为null
-  普通索引：可以为空，可以不唯一
-  全文索引：支持全文搜索的索引，不建议使用
-  空间索引：支持OpenGIS 空间搜索 5.7 以上
-  前缀索引：用字段的一部分建立索引，在文本类型如CHAR，VARCHAR，TEXT类列上创建索引时，可以指定索引列的长度， 但是数值类型不能指定。
组合索引：
组合索引的使用，需要遵循最左前缀原则(最左匹配原则，后面详细讲解)。 一般情况下，建议使用组合索引代替单列索引(主键索引除外，具体原因后面讲解)。
```
ALTER TABLE table_name ADD INDEX index_name (column1,column2);
```


全文索引：

### 优势 劣势
降低IO频次，降低数据排序成本，提高数据检索效率
劣势，多占用磁盘空间
### 索引创建原则
数据结构：
- Hash表
  - 但是不支持范围快速查找，范围查找时还是只能通过扫描全表方式。
  - 数据结构比较稀疏，不适合做聚合，不适合做范围等查找。

  - 使用场景:对查询并发要求很高，K/V内存数据库，缓存
- 二叉树
  - 优点
    - 磁盘IO次数会大大减少。
    比较是在内存中进行的，比较的耗时可以忽略不计。
     B树的高度一般2至3层就能满足大部分的应用场景，所以使用B树构建索引可以很好的提升查询的 效率。
  - 缺点
    - B树不支持范围查询的快速查找:如果我们想要查找15和26之间的数据，查找到15之后，需要回到 根节点重新遍历查找，需要从根节点进行多次遍历，查询效率有待提高。 空间占用较大:如果data存储的是行记录，行的大小随着列数的增多，所占空间会变大。一个页中 可存储的数据量就会变少，树相应就会变高，磁盘IO次数就会变大。

必须有聚簇索引，如果没有按照如下规则
InnoDB创建索引的具体规则如下:
1. 在表上定义主键PRIMARY KEY，InnoDB将主键索引用作聚簇索引。
2. 如果表没有定义主键，InnoDB会选择第一个不为NULL的唯一索引列用作聚簇索引。
3. 如果以上两个都没有，InnoDB 会使用一个6 字节长整型的隐式字段 ROWID字段构建聚簇索引。该ROWID字段会在插入新行时自动递增。


除聚簇索引之外的所有索引都称为辅助索引

#### 辅助索引
除聚簇索引之外的所有索引都称为辅助索引，InnoDB的辅助索引只会存储主键值而非磁盘地址。 使用辅助索引需要检索两遍索引:
     首先检索辅助索引获得主键
     然后使用主键到主索引中检索获得记录。
####  回表查询
根据在辅助索引树中获取的主键id，到主键索引树检索数据的过程称为回表查询。
#### 组合索引



组合索引创建原则
1. 频繁出现在where条件中的列，建议创建组合索引。
2. 频繁出现在order by和group by语句中的列，建议按照顺序去创建组合索引。
order by a,b 需要组合索引列顺序(a,b)。如果索引的顺序是(b,a)，是用不到索引的。 3. 常出现在select语句中的列，也建议创建组合索引。
####  覆盖索引

根据在辅助索引树查询数据时，首先通过辅助索引找到主键值，然后需要再根据主键值
到主键索引中找到主键对应的数据。这个过程称为回表。

select中列数据如果可以直接在辅助索引树上全部获取，也就是说索引树已经“覆盖”了我们的查询需求， 这时MySQL就不会白费力气的回表查询，这中现象就是覆盖索引。

### 索引优化
1. 单表索引不能太多
2. 频繁更新的资源不建议建立索引。 频繁更新字段引发页分裂和页合并
3. 区分度低的字段，不建议建索引:比如性别，男，女;比如状态。区分度太低时，会导致扫描行数过多，再加上回表查询的消耗。
    如果使用索引，比全表扫描的性能还要差。这些字段一般会用在组合索引中。

4.  在InnoDB存储引擎中，主键索引建议使用自增的长整型，避免使用很长的字段:
5. 不建议用无序的值作为索引
6. 尽量创建组合索引，而不是单列索引:优点:
(1)1个组合索引等同于多个索引效果，节省空间。 (2)可以使用覆盖索引
### 索引优化
1. 全值匹配我最爱
2. 最左前缀匹配原则
3. 不在索引列上做任何操作【计算、函数、类型转换】，会导致索引失效，转而使用全表扫描 4. 存储引擎不能使用索引中范围条件右边的列
5. 尽量使用覆盖索引【只访问索引的查询，索引列和查询列一致】，减少使用select *
6. 不等于【!= 或 <>】，索引会失效
7. is null，is not null，索引会失效
8. like以通配符开头，索引会失效
9. 字符串不加单引号，索引会失效
10. 少用or，用它来连接时，索引会失效

####  InnoDB索引
InnoDB 会强制添加一个索引，
每个InnoDB表都有一个聚簇索引 ，也叫聚集索引。聚簇索引使用B+树构建，叶子节点存储的数据是整 行记录。一般情况下，聚簇索引等同于主键索引，当一个表没有创建主键索引时，InnoDB会自动创建一 个ROWID字段来构建聚簇索引。
除聚簇索引之外的所有索引都称为辅助索引。在中InnoDB，辅助索引中的叶子节点存储的数据都是该行 的主键值。 在检索时，InnoDB使用此主键值在聚簇索引中搜索行记录。

### 游标

-----------隐式游标：SELECT .... INTO ...

1、查询的结果只能是1行，不能是0行或者多行
2、不需要声明，直接可以使用

-----------显示游标：
--声明显式游标的语法结构：
DECLARE
    --声明的部分
  CURSOR 游标名[(参数1 数据类型[,参数2 数据类型.....])] 
  IS
  SELECT 结果集;
BEGIN
  --逻辑体
END;
--开发规范：游标名以 C_ 开头
--使用/执行游标的语法结构：2种
--第1种：需要手动去打开游标，提取数据，关闭游标
DECLARE
  --声明部分
BEGIN
  --逻辑体
  OPEN 游标名[(实际参数1[，实际参数2...])];  --打开游标
  FETCH 游标名 INTO 变量;  --提取数据
  CLOSE 游标名;  --关闭游标（千万别忘了！）
END; 


## 一些命令

```
sudo vi /etc/profile
export PATH=${PATH}:/usr/local/mysql/bin

```

## MySQL 语句：

### 1.使用select批量更新数据

```
update htgw_sync_main a INNER JOIN 
(SELECT sync_id,com_file_size,time, CONVERT(com_file_size/1221*8, UNSIGNED)  as "newtime",start_time,end_time,sync_state 
from  htgw_sync_main where time > 3000 and start_time >="2023-05-09 00:00:00") as b
on a.sync_id = b.sync_id 
SET a.time = b.newtime 
where a.sync_id = b.sync_id 
```

### 2. **库空间以及索引空间大小:**

```
select TABLE_SCHEMA, concat(truncate(sum(data_length)/1024/1024,2),' MB') as data_size,
    concat(truncate(sum(index_length)/1024/1024,2),'MB') as index_size
     from information_schema.tables
     group by TABLE_SCHEMA
     order by data_length desc;
     
查询某个数据库内每张表的大小：

SELECT TABLE_NAME,CONCAT(TRUNCATE(SUM(data_length)/1024/1024,2),' MB') AS data_size,
     CONCAT(TRUNCATE(index_length/1024/1024,2),' MB') AS index_size
     FROM information_schema.tables WHERE TABLE_SCHEMA = 'rain_test'
     GROUP BY TABLE_NAME;
     
 查看数据库中所有表的信息  
SELECT CONCAT(table_schema,'.',table_name) AS 'Table Name', 
CONCAT(TRUNCATE(table_rows/1000000,2),'M') AS 'Number of Rows', 
CONCAT(TRUNCATE(data_length/(1024*1024*1024),2),'G') AS 'Data Size', 
CONCAT(TRUNCATE(index_length/(1024*1024*1024),2),'G') AS 'Index Size' , 
CONCAT(TRUNCATE((data_length+index_length)/(1024*1024*1024),2),'G') AS  'Total' 
FROM information_schema.TABLES WHERE table_schema LIKE 'rain_test'; 
     
```

### 3.  批量

添加`rewriteBatchedStatements=true`后，`executeBatch批量提交到mysql的sql语句还是一条insert语句插入一条记录`。
`插入10000条数据耗时1289ms`，[批量插入](https://so.csdn.net/so/search?q=批量插入&spm=1001.2101.3001.7020)的效率得到大幅提升。 效率比不加提升50%



```
批量更新设置为false 30000条从18秒变为2秒
connect.setAutoCommit(false);

```





## 最佳实践：

### 1.执行计划

### 2.存储过程和函数



mysql 中有三种循环方式：

1.**while方式**

```
WHILE ( tmpname IS NOT NULL) DO 

/*自己的业务逻辑(我是把字符串相加)*/

SET tmpName = CONCAT(tmpName ," ") ; 
SET temp_id = CONCAT(temp_id ,tmpName) ; 
FETCH cur1 INTO tmpName;
END WHILE;
CLOSE cur1;
```



2. Repeat方式：

   ```
   OPEN mycursor;
     REPEAT 
       FETCH mycursor INTO a;
        IF NOT done THEN
               SET temp_id=CONCAT(temp_id,a,' ');/*字符串相加,自己的业务逻辑*/
           END IF;
        UNTIL done END REPEAT;
   CLOSE mycursor;
   ```

   

3. loop

```
OPEN cur1;  
     emp_loop: LOOP  
         FETCH cur1 INTO id;  
         IF done=1 THEN  
            LEAVE emp_loop; 
         END IF;  
          SET temp_id=CONCAT(temp_id,id,' ');/*字符串相加,自己的业务逻辑*/       
     END LOOP emp_loop;  
     CLOSE cur1;  
```



存储过程：

**存储函数有且只有一个返回值，而存储过程可以有多个返回值，也可以没有返回值。**

.**存储函数只能有输入参数**，而且不能带in, 而存储过程可以有多个in,out,inout参数。

存储过程中的语句功能更强大，存储过程可以实现很复杂的业务逻辑**，而函数有很多限制，如不能在函数中使用insert,update,delete,create等语句；**

4.存储函数只完成查询的工作，可接受输入参数并返回一个结果，也就是函数实现的功能针对性比较强。

**5.存储过程可以调用存储函数、但函数不能调用存储过程。**

6.存储过程一般是作为一个独立的部分来执行(call调用)。而函数可以作为查询语句的一个部分来调用.



##### 嵌套：

```
use test;
DROP PROCEDURE IF EXISTS fun1;
/*声明结束符为$*/
DELIMITER $

/*创建函数*/
CREATE PROCEDURE  fun1( )

BEGIN
    /*用于保存结果*/

    /*创建一个变量，用来保存当前行中a的值*/
    DECLARE _id1 int DEFAULT 0;
    DECLARE time1 int DEFAULT 0;
    DECLARE newend1 VARCHAR(60);
    /*创建一个变量，用来保存当前行中b的值*/
    DECLARE newtime1 int DEFAULT 0;
    DECLARE start_time1 VARCHAR(60);
    DECLARE end_time1 VARCHAR(60);
    /*创建游标结束标志变量*/
    DECLARE v_done int DEFAULT 0;
    DECLARE file_size1 DECIMAL(12,2);
    DECLARE avg_speed1 DECIMAL(12,2);
    DECLARE com_file_size1 DECIMAL(12,2);

    DECLARE avg_speed_new int DEFAULT 0;
    DECLARE time_new int DEFAULT 0;
    DECLARE end_new VARCHAR(60);
	DECLARE sped_ _id1 int DEFAULT 0;
	DECLARE sub_id1 int DEFAULT 0;
	DECLARE sub_max_speed DECIMAL(12,2);

    /*创建游标*/
    DECLARE cur_test1 CURSOR FOR
        SELECT _id,file_size,com_size,  avg_speed,start_time,time,
               CONVERT(com_size/1121*8, UNSIGNED)  as "newtime" ,
               end_time,
               adddate(start_time, interval  CONVERT(com_file_size/1121*8, UNSIGNED)   second) as newend
        from   _main ;

       -- where start_time >="2023-04-19 00:00:01" ;
	DECLARE cur_max_speed CURSOR FOR
        SELECT _id ,sub_id ,cur_speed
        from   _sub
        where _id = _id1;
	DECLARE continue handler for not found set v_done = 1;
    /*打开游标*/
    OPEN cur_test1;
    /*使用Loop循环遍历游标*/
		out_loop: LOOP
                FETCH cur_test1 INTO _id1,file_size1,com_size1,  avg_speed1,start_time1,time1,newtime1,end_time1,newend1;
				IF v_done  > 0 THEN
						LEAVE out_loop;
				END IF;
	        #使用游标（从游标中获取数据）
				SELECT  _id1,file_size1,com_size1,  avg_speed1,start_time1,time1,newtime1,end_time1,newend1;
				set avg_speed_new = 128+ CONVERT(RAND( ) *60, UNSIGNED);
				set time_new=CONVERT(com_file_size1/avg_speed_new, UNSIGNED);
				set  end_new=adddate(start_time1, interval  CONVERT(com_file_size1/avg_speed_new , UNSIGNED)   second);
				update   _main  set avg_speed = avg_speed_new,time =time_new,end_time = end_new  where _id = _id1;
				
				OPEN cur_max_speed;
				SET v_done = 0;
				REPEAT
					FETCH cur_max_speed INTO sped_ _id1,sub_id1,sub_max_speed;
                    set sub_max_speed = 138+ CONVERT(RAND( ) *60, UNSIGNED);
					SELECT sub_max_speed,sub_id1, _id1;
					update   _sub  set cur_speed = 144   where sub_id =sub_id1;
                until v_done   END REPEAT;
				 CLOSE cur_max_speed;
				 SET v_done = 0;
	  END LOOP out_loop;
	  CLOSE cur_test1;

    /*返回结果*/
END $
/*结束符置为;*/
DELIMITER ;

call fun1()

```



##### 创建分区存储过程

```
# 创建分区存储过程
DROP PROCEDURE IF EXISTS add_partition;
DELIMITER //

CREATE PROCEDURE add_partition()
BEGIN
    DECLARE max_pd_num INT;
    DECLARE max_pd_name varchar(32);
    DECLARE netxt_pation INT;
    DECLARE netxt_pation_name varchar(32);
    DECLARE max_id INT;

    DECLARE cur_test1 CURSOR FOR
        SELECT max(PARTITION_NAME)        as 'max_pd_name',
               max(partition_description) as 'max_pd_num'
        FROM information_schema.PARTITIONS

        WHERE table_schema = 'mydatabase'
          AND table_name = 'test_user'
          AND PARTITION_NAME like "p%";

    DECLARE cur_max_id CURSOR FOR
        SELECT max(id) as 'max_id'
        FROM mydatabase.test_user;

    OPEN cur_test1;

    FETCH cur_test1 INTO max_pd_name,max_pd_num;

    SELECT max_pd_name, max_pd_num;

    CLOSE cur_test1;


    OPEN cur_max_id;
    FETCH cur_max_id INTO max_id;

    SELECT max_id;

    out_loop:
    LOOP
        -- 	 设置值
        set netxt_pation := max_pd_num + 100;
        SELECT netxt_pation, max_pd_name;
        set netxt_pation_name = CONCAT('p', REPLACE(max_pd_name, 'p', '') + 1);

        SELECT netxt_pation_name;

        SET @sql = CONCAT('ALTER TABLE test_user
			REORGANIZE PARTITION default_part
        INTO (PARTITION ', netxt_pation_name, ' VALUES LESS THAN (', netxt_pation, ')
        , PARTITION default_part VALUES LESS THAN MAXVALUE);');

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        IF netxt_pation > max_id THEN
            LEAVE out_loop;
        END IF;


    END LOOP out_loop;
    CLOSE cur_max_id;


END
//

DELIMITER ;


call add_partition();
# 创建定时任务

# 查看定时任务
SELECT event_name, event_definition, interval_value, interval_field, status
FROM information_schema.EVENTS;

# 开启
alter event run_event on completion preserve enable;
# 关闭
alter event run_event on completion preserve disable;


drop event e_partition;

CREATE EVENT e_partition
    ON SCHEDULE EVERY 1 HOUR
    ON COMPLETION PRESERVE ENABLE
    DO CALL p_partition_month();
```





游标的handler 一定要设置，也一定要设置到游标声明之后。就是因为没有设置游标的handler 导致嵌套只能打印一条外层的，不在继续遍历。

DECLARE continue handler for not found set v_done = 1;

用户变量的分类
用户变量是用户自己定义的，作为 MySQL 编码规范，MySQL 中的用户变量以一个 "@" 开头。根据作用范围不同，又分为会话用户变量和局部变量

会话用户变量：作用域和会话变量一样，只对当前连接会话有效

```
#方式一：“=”或“:=”
SET @用户变量 = 值;
SET @用户变量 := 值;
```



局部变量：只在 BEGIN 和 END 语句块中有效。局部变量只能在存储过程和存储函数中使用

```
BEGIN
    #声明局部变量
    DECLARE 变量名1 变量数据类型 [DEFAULT 变量默认值];
    DECLARE 变量名2, 变量名3,...变量数据类型 [DEFAULT 变量默认值];
    #为局部变量赋值
    SET 变量名1 = 值;
    SELECT 值 INTO 变量名2 [FROM 子句];
    #查看局部变量的值
    SELECT 变量1, 变量2, 变量3;
END
```

DECLARE 定义的变量的作用范围**是BEGIN … END块内，只能在块中使用**。
SET 定义的**变量用户变量，作用范围是全局的**，如果在存储过程中定义了用户变量，在存储过程之外的sql也是可以调用的。

### 	3 .索引

1. 排序字段需要添加索引
2. 查询条件需要添加组合索引
3. <> 比 in 查询略（在只有一种排除条件下）



## 故障恢复：

### redo 日志丢失

问题描述（windows mysql8）：重新安装之后，挪动data目录中的数据导致redologo 丢失，删除 Data\#innodb_redo 目录中的redo 日志数据， 重启成功

### 从.ibd 文件恢复数据



1. 创建对应的数据库
2. 创建表结构 
3.  剔除表空间 ALTER TABLE  table_name  DISCARD TABLESPACE;
4. 复制原来的.ibd  文件
5.  恢复数据  ALTER TABLE table_name   IMPORT TABLESPACE;



问题总结：

 MySQL instance at 'node1:3306' currently has the super_read_only system variable set to protect it from inadvertent updates from application



## 参考资料

mysql8[集群搭建](https://www.cnblogs.com/ios9/p/14843778.html)

[主从](https://blog.csdn.net/z1171127310/article/details/126443223) 