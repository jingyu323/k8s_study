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

添加开机启动
vi /etc/rc.local

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

db.createUser({user:"admin",pwd:"admin",roles:[{role:"root",db:"admin"}]})

rs.conf()
```

### 创建副本集

https://www.mongodb.com/docs/v6.0/replication/

副本集有两种类型，三种角色。
两种类型：

主节点（Primary）类型：数据操作的主要连接点，可读写
次、辅助、从节点（Secondaries）类型：数据冗余备份节点，可以读（需要设置）或选举
三种角色：

主要成员（Primary）：主要接收所有写操作。就是主节点。
副本成员（Replicate）：从主节点通过复制操作以维护相同的数据集，即备份数据，不可写操作，但可以读操作（但需要配置）。是默认的一种从节点类型。
仲裁者（Arbiter）：不保留任何数据的副本，只具有投票选举作用。当然也可以将仲裁服务器维护为副本集的一部分，即副本成员同时也可以是仲裁者。也是一种从节点类型。 



openssl rand -base64 20 > keyfile 

chmod 400 keyfile







 rs.initiate({_id:"rs0",members:[{_id:0,host:"192.168.182.142:27017"},{_id:1,host:"192.168.182.143:27017"}, {_id:2,host:"192.168.182.144:27017"}]})



rs.status() 查看状态







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



### 6.4索引

##### 6.4.1  单键索引

单键索引(Single Field Indexes)顾名思义就是单个字段作为索引列，mongoDB的所有collection默认都有一个单键索引_id，我们也可以对一些经常作为过滤条件的字段设置索引，如给age字段添加一个索引，语法十分简单：

```
//给age字段添加升序索引
　　db.userinfos.createIndex({age:1})
```

##### 6.4.2  复合索引







java 驱动

  https://www.mongodb.com/docs/drivers/java/sync/v4.9/?_ga=2.113893319.1355180383.1685271753-1372951013.1685271753

https://mongodb.github.io/mongo-java-driver/4.9/driver-reactive/getting-started/installation/

## 7.常见问题

1.MongoDB报错“not authorized on admin to execute command“

此错误是因为没有授权给admin用户对system.version表执行命令的权限，解决方法如下:
\> db.grantRolesToUser ( "root", [ { role: "__system", db: "admin" } ] )

2.MongoServerError: replSetInitiate quorum check failed because not all proposed set members responded affirmatively: 192.168.182.144:27017 failed with Authentication failed., 192.168.182.143:27017 failed with Authentication failed

## 参考资料

操作方法

https://www.mongodb.com/docs/manual/reference/method/db.collection.find/

简单介绍

https://blog.csdn.net/qq_15138049/article/details/127244575

文档

https://www.runoob.com/mongodb/mongodb-databases-documents-collections.html

### 问题：

#### mongoDb连接字符串中的+srv是什么意思？

SRV 记录的使用消除了每个客户端为集群传递完整的状态信息集的要求。相反,单个 SRV 记录标识与集群关联的所有节点(及其端口号),关联的 TXT 记录定义 URI 的选项。

在配置集群时使用域名可以为集群变更时提供一层额外的保护。例如需要将集群整体迁移到新网段，直接修改域名解析即可。另外，MongoDB 提供的 mongodb+srv:// 协议可以提供额外一层的保护。该协议允许通过域名解析得到所有 mongos 或节点的地址，而不是写在连接字符串中。
 



## 面试问题

1、mongodb是什么？ 

  2、mongodb有哪些特点？ 

  3、你说的NoSQL数据库是什么意思?NoSQL与RDBMS直接有什么区别?为什么要使用和不使用NoSQL数据库?说一说NoSQL数据库的几个优点? 

  4、NoSQL数据库有哪些类型? 

  5、MySQL与MongoDB之间最基本的差别是什么? 

  6、你怎么比较MongoDB、CouchDB及CouchBase? 

  7、MongoDB成为最好NoSQL数据库的原因是什么? 

  8、journal回放在条目(entry)不完整时(比如恰巧有一个中途故障了)会遇到问题吗? 

  9、分析器在MongoDB中的作用是什么? 

  10、名字空间(namespace)是什么? 

  11、 如果用户移除对象的属性，该属性是否从存储层中删除? 

  12、能否使用日志特征进行安全备份? 

  13、允许空值null吗? 

  14、更新操作立刻fsync到磁盘? 

  15、如何执行事务/加锁? 

  16、为什么我的数据文件如此庞大? 

  17、启用备份故障恢复需要多久? 

  18、什么是master或primary? 

  19、什么是secondary或slave? 

  20、我必须调用getLastError来确保写操作生效了么? 

  21、我应该启动一个集群分片(sharded)还是一个非集群分片的 MongoDB 环境? 

  22、分片(sharding)和复制(replication)是怎样工作的? 

  23、数据在什么时候才会扩展到多个分片(shard)里? 

  24、当我试图更新一个正在被迁移的块(chunk)上的文档时会发生什么? 

  25、如果在一个分片(shard)停止或者很慢的时候，我发起一个查询会怎样? 

  26、我可以把moveChunk目录里的旧文件删除吗? 

  27、我怎么查看 Mongo 正在使用的链接? 

  28、如果块移动操作(moveChunk)失败了，我需要手动清除部分转移的文档吗? 

  29、如果我在使用复制技术(replication)，可以一部分使用日志(journaling)而其他部分则不使用吗? 

  30、当更新一个正在被迁移的块（Chunk）上的文档时会发生什么？ 

  31、MongoDB在A:{B,C}上建立索引，查询A:{B,C}和A:{C,B}都会使用索引吗？ 

  32、如果一个分片（Shard）停止或很慢的时候，发起一个查询会怎样？ 

  33、MongoDB支持存储过程吗？如果支持的话，怎么用？ 

  34、如何理解MongoDB中的GridFS机制，MongoDB为何使用GridFS来存储文件？ 

  35、什么是NoSQL数据库？NoSQL和RDBMS有什么区别？在哪些情况下使用和不使用NoSQL数据库？ 

  36、MongoDB支持存储过程吗？如果支持的话，怎么用？ 

  37、如何理解MongoDB中的GridFS机制，MongoDB为何使用GridFS来存储文件？ 

  38、为什么MongoDB的数据文件很大？ 

  39、当更新一个正在被迁移的块（Chunk）上的文档时会发生什么？ 

  40、MongoDB在A:{B,C}上建立索引，查询A:{B,C}和A:{C,B}都会使用索引吗？ 

  41、如果一个分片（Shard）停止或很慢的时候，发起一个查询会怎样？ 

  42、分析器在MongoDB中的作用是什么? 

  43、如果用户移除对象的属性，该属性是否从存储层中删除？ 

  44、能否使用日志特征进行安全备份？ 

  45、更新操作立刻fsync到磁盘？ 

  46、如何执行事务/加锁？ 

  47、什么是master或primary？ 

  48、getLastError的作用 

  49、分片（sharding）和复制（replication）是怎样工作的？ 

  50、数据在什么时候才会扩展到多个分片（shard）里？ 

  51、 当我试图更新一个正在被迁移的块（chunk）上的文档时会发生什么？ 

  52、 我怎么查看 Mongo 正在使用的链接？ 

  53、mongodb的结构介绍 

  54、数据库的整体结构 

  55、MongoDB是由哪种语言写的 

  56、MongoDB的优势有哪些 

  57、什么是集合 

  58、什么是文档 

  59、什么是”mongod“ 

  60、"mongod"参数有什么 

  61、什么是"mongo" 

  62、MongoDB哪个命令可以切换数据库 

  63、什么是非关系型数据库 

  64、非关系型数据库有哪些类型 

  65、为什么用MOngoDB？ 

  66、在哪些场景使用MongoDB 

  67、MongoDB中的命名空间是什么意思? 

  68、哪些语言支持MongoDB? 

  69、在MongoDB中如何创建一个新的数据库 

  70、在MongoDB中如何查看数据库列表 

  71、MongoDB中的分片是什么意思 

  72、如何查看使用MongoDB的连接Sharding - MongoDB Manual21.如何查看使用MongoDB的连接 

  73、什么是复制 

  74、在MongoDB中如何在集合中插入一个文档 

  75、在MongoDB中如何除去一个数据库Collection Methods24.在MongoDB中如何除去一个数据库 

  76、在MongoDB中如何创建一个集合。 

  77、在MongoDB中如何查看一个已经创建的集合 

  78、在MongoDB中如何删除一个集合 

  79、为什么要在MongoDB中使用分析器 

  80、MongoDB支持主键外键关系吗 

  81、MongoDB支持哪些数据类型 

  82、为什么要在MongoDB中用"Code"数据类型 

  83、为什么要在MongoDB中用"Regular Expression"数据类型 

  84、为什么在MongoDB中使用"Object ID"数据类型 

  85、如何在集合中插入一个文档 

  86、"ObjectID"由哪些部分组成 

  87、在MongoDb中什么是索引 

  88、如何添加索引 

  89、用什么方法可以格式化输出结果 

  90、如何使用"AND"或"OR"条件循环查询集合中的文档 

  91、在MongoDB中如何更新数据 

  92、如何删除文档 

  93、在MongoDB中如何排序 

  94、什么是聚合 

  95、在MongoDB中什么是副本集