# MongoDB相关

## 1.介绍

mongo和mysql对比

| SQL术语/概念 | MongoDB术语/概念 | 解释/说明                           |
| :----------- | :--------------- | :---------------------------------- |
| database     | database         | 数据库                              |
| table        | collection       | 数据库表/集合                       |
| row          | document         | 数据记录行/文档                     |
| column       | field            | 数据字段/域                         |
| index        | index            | 索引                                |
| table joins  |                  | 表连接,MongoDB不支持                |
| primary key  | primary key      | 主键,MongoDB自动将_id字段设置为主键 |



集合和mysql表进行对比

|       RDBMS        | MongoDB                           |
| :----------------: | :-------------------------------- |
|       数据库       | 数据库                            |
|        表格        | 集合                              |
|         行         | 文档                              |
|         列         | 字段                              |
|       表联合       | 嵌入文档                          |
|        主键        | 主键 (MongoDB 提供了 key 为 _id ) |
| 数据库服务和客户端 |                                   |
|   Mysqld/Oracle    | mongodb                           |
|   mysql/sqlplus    | mongo                             |



### 



### 1.1 角色

1. 数据库用户角色：read、readWrite;
2. 数据库管理角色：dbAdmin、dbOwner、userAdmin；
3. 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
4. 备份恢复角色：backup、restore；
5. 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
6. 超级用户角色：root  
// 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
7. 内部角色：__system





## 2.作用

## 3.优点

## 4.实现原理

## 5.安装

https://www.mongodb.com/try/download/community-kubernetes-operator

选择

```
 
tar -zxvf mongodb-linux-x86_64-rhel70-4.2.23.tgz

vim /etc/profile
# 添加mongodb环境变量
export PATH=$PATH:/usr/local/mongodb/bin
# 重新加载配置文件
source /etc/profile
# 检查环境变量
echo $PATH


vim /etc/mongodb.conf
#指定数据库路径
dbpath=/usr/local/mongodb/data
#指定MongoDB日志文件
logpath=/usr/local/mongodb/logs/mongodb.log
# 使用追加的方式写日志
logappend=true
#端口号
port=27017 
#方便外网访问,外网所有ip都可以访问，不要写成固定的linux的ip
bind_ip=0.0.0.0
fork=true # 以守护进程的方式运行MongoDB，创建服务器进程
#auth=true #启用用户验证
#bind_ip=0.0.0.0 #绑定服务IP，若绑定127.0.0.1，则只能本机访问，不指定则默认本地所有IP



启动
./mongod -f /etc/mongodb.conf
```

连接mogodb,使用 mongosh

vi /etc/yum.repos.d/mongodb-org-6.0.repo

```
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/6.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
```



```
yum install -y mongodb-mongosh
 
 执行
 mongosh
 连接到不同端口
 mongosh --port 28015
```

设置密码：

```
1.auth改为false
show dbs

test> show dbs
admin   40.00 KiB
config  12.00 KiB
local   72.00 KiB

查看用户
show users


#切换到admin数据库
use admin
#使用db.createUser()函数在admin数据库下创建用户
db.createUser({user:"root",pwd:"root",roles:[{role:"userAdminAnyDatabase",db:"admin"},{role:"readWriteAnyDatabase",db:"admin"}]})


#进行验证，认证通过返回：1
db.auth('root','root')


```





## 6.使用

### 数据类型

## MongoDB 数据类型

下表为MongoDB中常用的几种数据类型。

| 数据类型           | 描述                                                         |
| :----------------- | :----------------------------------------------------------- |
| String             | 字符串。存储数据常用的数据类型。在 MongoDB 中，UTF-8 编码的字符串才是合法的。 |
| Integer            | 整型数值。用于存储数值。根据你所采用的服务器，可分为 32 位或 64 位。 |
| Boolean            | 布尔值。用于存储布尔值（真/假）。                            |
| Double             | 双精度浮点值。用于存储浮点值。                               |
| Min/Max keys       | 将一个值与 BSON（二进制的 JSON）元素的最低值和最高值相对比。 |
| Array              | 用于将数组或列表或多个值存储为一个键。                       |
| Timestamp          | 时间戳。记录文档修改或添加的具体时间。                       |
| Object             | 用于内嵌文档。                                               |
| Null               | 用于创建空值。                                               |
| Symbol             | 符号。该数据类型基本上等同于字符串类型，但不同的是，它一般用于采用特殊符号类型的语言。 |
| Date               | 日期时间。用 UNIX 时间格式来存储当前日期或时间。你可以指定自己的日期时间：创建 Date 对象，传入年月日信息。 |
| Object ID          | 对象 ID。用于创建文档的 ID。                                 |
| Binary Data        | 二进制数据。用于存储二进制数据。                             |
| Code               | 代码类型。用于在文档中存储 JavaScript 代码。                 |
| Regular expression | 正则表达式类型。用于存储正则表达式。                         |

### 









###  6.1 用户操作 

```
#切换到admin数据库
use admin
#查看所有用户
db.system.users.find()

#使用db.createUser()函数在admin数据库下创建用户
db.createUser({user:"root",pwd:"root",roles:[{role:"userAdminAnyDatabase",db:"admin"},{role:"readWriteAnyDatabase",db:"admin"}]})

#删除用户 删除时需要切换到该账户所在的数据库
db.system.users.remove({user:"user"})

```

###  6.2 数据库操作

```
切换数据库，有则切换，没有则创建，
use DATABASE_NAME
查看所有的db，有些没有数据的DB是查询不到的
show dbs
查看当前DB名称
db
删除数据库
db.dropDatabase();

创建集合
db.createCollection("raintest")
查看集合
show tables

```

### 6.3 创建集合

```

```





java 驱动

  https://www.mongodb.com/docs/drivers/java/sync/v4.9/?_ga=2.113893319.1355180383.1685271753-1372951013.1685271753

https://mongodb.github.io/mongo-java-driver/4.9/driver-reactive/getting-started/installation/

## 7.常见问题

## 参考资料

操作方法

https://www.mongodb.com/docs/manual/reference/method/db.collection.find/

简单介绍

https://blog.csdn.net/qq_15138049/article/details/127244575