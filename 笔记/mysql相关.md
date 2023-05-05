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

确认时防火墙的问题 再去开放端口即可。

关闭防火墙之后还是连不上可以重启

systemctl restart mysqld

```
grant all privileges on *.* to 'root'@'%' with grant option;
flush privileges;
```


vi /etc/my.cnf 去除only_full_group_by模式，文本最后一行添加sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION



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





## 分库分表

### 分库

单纯的分库就是垂直切分，把不同业务逻辑的表分开存储在在不同的数据库



### 分区

局限于单一数据库节点，将一张表分散存储在不同的物理块中

### 分片

### 分表

侧重点不同，分区侧重提高读写性能，分表侧重提高并发性能。两者不冲突，可以配合使用。

## 千万级别数据处理

## 锁

表级的锁是 MDL（metadata lock)
- 读锁之间不互斥，因此你可以有多个线程同时对一张表增删改查。

- 读写锁之间、写锁之间是互斥的，用来保证变更表结构操作的安全性。因此，如果有两个线程要同时给一个表加字段，其中一个要等另一个执行完才能开始执行。


给一个表加字段，或者修改字段，或者加索引，需要扫描全表的数据。在对大表操作的时候，以免对线上服务造成影响。 行锁释放不会 立即释放，

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

7. checkpoint 
 通过 checkpoint 进行赃页落盘
 双写机制保证数据完整性 安全性，防止写入磁盘的时候部分写入失败的情况
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

## 参考资料

mysql8[集群搭建](https://www.cnblogs.com/ios9/p/14843778.html)

[主从](https://blog.csdn.net/z1171127310/article/details/126443223) 