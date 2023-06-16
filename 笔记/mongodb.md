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

###  原子操作：

mongodb提供了许多原子操作，比如文档的保存，修改，删除等，都是原子操作。

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

所有的查询只针对集合，db代表数据库，不同数据库中的集合互相独立
只能主节点，查询
db.movies.find()


```

| 操作       | 格式                     | 范例                                        | RDBMS中的类似语句       |
| :--------- | :----------------------- | :------------------------------------------ | :---------------------- |
| 等于       | `{<key>:<value>`}        | `db.col.find({"by":"菜鸟教程"}).pretty()`   | `where by = '菜鸟教程'` |
| 小于       | `{<key>:{$lt:<value>}}`  | `db.col.find({"likes":{$lt:50}}).pretty()`  | `where likes < 50`      |
| 小于或等于 | `{<key>:{$lte:<value>}}` | `db.col.find({"likes":{$lte:50}}).pretty()` | `where likes <= 50`     |
| 大于       | `{<key>:{$gt:<value>}}`  | `db.col.find({"likes":{$gt:50}}).pretty()`  | `where likes > 50`      |
| 大于或等于 | `{<key>:{$gte:<value>}}` | `db.col.find({"likes":{$gte:50}}).pretty()` | `where likes >= 50`     |
| 不等于     | `{<key>:{$ne:<value>}}`  | `db.col.find({"likes":{$ne:50}}).pretty()`  | `where likes != 50`     |

##### MongoDB AND 条件

MongoDB 的 find() 方法可以传入多个键(key)，每个键(key)以逗号隔开，即常规 SQL 的 AND 条件。

语法格式如下：

```
>db.movies.find({key1:value1, key2:value2}).pretty()
```

### 6.3 创建集合



### 6.4索引



```
查询索引:db.collection.getIndexes(),
创建索引:db.collection.createIndex(),
删除索引:db.collection.dropIndex()
创建唯一索引
db.collection.createIndex({name:1},{unique:true}) #1从小到大排序
```



##### 6.4.1  单键索引

单键索引(Single Field Indexes)顾名思义就是单个字段作为索引列，mongoDB的所有collection默认都有一个单键索引_id，我们也可以对一些经常作为过滤条件的字段设置索引，如给age字段添加一个索引，语法十分简单：

```
//给age字段添加升序索引
　　db.userinfos.createIndex({age:1})
```

##### 6.4.2  复合索引



##### 6.4.2  哈希索引-定值查找

哈希索引(hashed Indexes)就是将field的值进行hash计算后作为索引，其强大之处在于实现O(1)查找，当然用哈希索引最主要的功能也就是实现定值查找，对于经常需要排序或查询范围查询的集合不要使用哈希索引。

db.collection.createIndex( { _id: "hashed" } )

db.collection.createIndex( { "fieldA" : 1, "fieldB" : "hashed", "fieldC" : -1 } )



### 6.5  集群

MongoDB 有三种集群部署模式，分别为[主从复制](https://so.csdn.net/so/search?q=主从复制&spm=1001.2101.3001.7020)（Master-Slaver）、副本集（Replica Set）和分片（Sharding）模式。



#### 6.5.1  分片

分片是跨多台机器存储数据的过程，它是 MongoDB 满足数据增长需求的方法。随着数据的不断增加，单台机器可能不足以存储全部数据，也无法提供足够的读写吞吐量。通过分片，您可以添加更多计算机来满足数据增长和读/写操作的需求

选定一个或多个key，按照选定的key进行数据分割，分割后的数据分别保存在不同的mongodb副本集中，这个是分片的基本思路。
分片思路可以水平扩展机器，根据业务需要扩展任意多的机器。读写压力分散到集群不同的机器中。



Sharded Cluster
A MongoDB sharded cluster consists of the following components:

shard: Each shard contains a subset of the sharded data. Each shard can be deployed as a replica set.

mongos: The mongos acts as a query router, providing an interface between client applications and the sharded cluster. Starting in MongoDB 4.4, mongos can support hedged reads to minimize latencies.

config servers: Config servers store metadata and configuration settings for the cluster.

Config server：MongoDB负责追踪数据块在shard上的分布信息，每个分片存储哪些数据块，叫做分片的元数据，保存在config server上的数据库 config中，一般使用3台config server，所有config server中的config数据库必须完全相同（建议将config server部署在不同的服务器，以保证稳定性）；





只要有一个config server失效，那么集群的metadata都将处于只读状态，可以对shards进行数据读写，但是chunks分离和迁移将不能进行，知道三个config servers全部有效为止。如果三个config servers都失效，那么意味着集群将不能读取metadata数据，如果此时重启mongos，那么它将不能获取metadata数据，将无法提供router，直到config servers有效。此外，metadata的数据量非常小，所以这不会对Config servers或者mongos带来存储上的压力。Config server的负载非常小，它对硬件配置要求很低，只需要较少的内存和存储空间即可。

  prodution环境中，需要三个config servers；如果仅仅为了测试可以只需要一个。



脑裂问题：



Shard server：将数据进行分片，拆分成数据块（chunk），每个trunk块的大小默认为64M，数据块真正存放的单位；

Mongos server：数据库集群请求的入口，所有的请求都通过mongos进行协调，查看分片的元数据，查找chunk存放位置，mongos自己就是一个请求分发中心，在生产环境通常有多mongos作为请求的入口，防止其中一个挂掉所有的mongodb请求都没有办法操作。

##### 配置config server replica set

三个server 不同的配置 bindIp: 192.168.182.144 需要不相同才行，同时配置多个起不来

```
sharding:
  clusterRole: configsvr
replication:
  replSetName: shardtest
systemLog:
   destination: file
   path: "/usr/local/mongodb/logs/mongodb.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/data"
processManagement:
   fork: true
net:
   bindIp: 192.168.182.144
setParameter:
   enableLocalhostAuthBypass: false
```



mongosh --host 192.168.182.142  --port  27019  登录节点

##### 配置Shard Replica Sets

```
sharding:
  clusterRole: shardsvr
replication:
  replSetName: shardRpSets
systemLog:
   destination: file
   path: "/usr/local/mongodb/logs/mongodbRpSets.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/usr/local/mongodb/shardRpSetsData"
processManagement:
   fork: true
net:
   bindIp: 192.168.182.142
setParameter:
   enableLocalhostAuthBypass: false
  
```

mongod --config  /etc/mongodb_sharedRpSet.conf



mongod --config  /etc/mongodb_sharedRpSet.conf

tcp        0      0 192.168.182.143:27018   0.0.0.0:*               LISTEN      4319/mongod 

查看端口命令：

netstat -anp | grep mongo 



默认端口27018  

mongosh --host 192.168.182.142  --port  27018  登录节点



```
 初始化集群
 rs.initiate()
 
 
 rs.add("192.168.182.143:27018")
  rs.add("192.168.182.144:27018")
 
```

##### 配置 `mongos`  for the Sharded Cluster



配置文件

```
sharding:
  configDB: shardtest/192.168.182.142:27019,192.168.182.143:27019,192.168.182.144:27019
systemLog:
   destination: file
   path: "/usr/local/mongodb/logs/mongosRpSets.log"
   logAppend: true
processManagement:
   fork: true
net:
   bindIp: 192.168.182.142
setParameter:
   enableLocalhostAuthBypass: false
  
  
```

mongos --config    /etc/mongodb_mongosRpSet.conf



连接集群节点

mongosh --host 192.168.182.142  --port  27017  登录节点

添加Shards 到 集群。 shardRpSets 是 Shard Replica Sets 的名称

```
sh.addShard( "shardRpSets/192.168.182.142:27018,192.168.182.143:27018,192.168.182.144:27018")
```



查看状态

sh.status()

添加前：

```
test> sh.status()
shardingVersion
{
  _id: 1,
  minCompatibleVersion: 5,
  currentVersion: 6,
  clusterId: ObjectId("6480a5c9547b59abc36ef6a4")
}
---
shards
[]
---
active mongoses
[]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently enabled': 'yes',
  'Currently running': 'no',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {}
  }
]

```

添加后

```
shardingVersion
{
  _id: 1,
  minCompatibleVersion: 5,
  currentVersion: 6,
  clusterId: ObjectId("6480a5c9547b59abc36ef6a4")
}
---
shards
[
  {
    _id: 'shardRpSets',
    host: 'shardRpSets/192.168.182.142:27018,192.168.182.143:27018,192.168.182.144:27018',
    state: 1,
    topologyTime: Timestamp({ t: 1686228160, i: 5 })
  }
]
---
active mongoses
[ { '6.0.6': 1 } ]
---
autosplit
{ 'Currently enabled': 'yes' }
---
balancer
{
  'Currently enabled': 'yes',
  'Currently running': 'no',
  'Failed balancer rounds in last 5 attempts': 0,
  'Migration Results for the last 24 hours': 'No recent migrations'
}
---
databases
[
  {
    database: { _id: 'config', primary: 'config', partitioned: true },
    collections: {}
  }
]

```





**开启数据库分片**

sh.enableSharding("test")



##### 分片设置 

shark key可以决定collection数据在集群的分布，shard key必须为索引字段或者为组合索引的左前缀。documents插入成功后，任何update操作都不能修改shard key，否则会抛出异常

###### Range分区：

首先shard key必须是数字类型，整个区间的上下边界分别为“正无穷大”、“负无穷大”，每个chunk覆盖一段子区间，即整体而言，任何shard key均会被某个特定的chunk所覆盖。区间均为作闭右开。每个区间均不会有重叠覆盖，且互相临近。当然chunk并不是预先创建的，而是随着chunk数据的增大而不断split。



  Range分区更好的支持range查询，根据指定的shard key进行range查询，

###### Hash分区

计算shard key的hash值（64位数字），并以此作为Range来分区，基本方式同1）；Hash值具有很强的散列能力，通常不同的shard key具有不同的hash值（冲突是有限的），这种分区方式可以将document更加随机的分散在不同的chunks上。





##### 分片迁移



##### 关于分片问题：

1.已经创建relicaset,config Server可以随意选择吗？

两种不同类型的集群，

2.分片同步和副本同步怎么保证数据的一致性，会不会有双份

这个问题其实是两种不同的集群组成类型



3.分片是一个服务器搞一个replicasets，还是使用不同的名称建不同分片副本





#### 6.5.2副本集

副本集可以解决主节点发生故障导致数据丢失或不可用的问题，但遇到需要存储海量数据的情况时，副本集机制就束手无策了。副本集中的一台机器可能不足以存储数据，或者说集群不足以提供可接受的读写吞吐量。

##### 创建副本集

https://www.mongodb.com/docs/v6.0/replication/

副本集有两种类型，三种角色。
两种类型：

主节点（Primary）类型：数据操作的主要连接点，可读写
次、辅助、从节点（Secondaries）类型：数据冗余备份节点，可以读（需要设置）或选举
三种角色：

主要成员（Primary）：主要接收所有写操作。就是主节点。
副本成员（Replicate）：从主节点通过复制操作以维护相同的数据集，即备份数据，不可写操作，但可以读操作（但需要配置）。是默认的一种从节点类型。
仲裁者（Arbiter）：不保留任何数据的副本，只具有投票选举作用。当然也可以将仲裁服务器维护为副本集的一部分，即副本成员同时也可以是仲裁者。也是一种从节点类型。 

```
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
auth=false #启用用户验证
#bind_ip=0.0.0.0 #绑定服务IP，若绑定127.0.0.1，则只能本机访问，不指定则默认本地所有IP

#启用日志文件
journal=true
#以后台方式运行进程

replSet=rs1
pidfilepath=/usr/local/mongodb/pid/main.pid

```



rs.initiate({_id:"rs1",
            members:[{_id:0,host:"192.168.182.142:27017" ,priority:2},
            {_id:1,host:"192.168.182.143:27017",priority:1}, 
            {_id:2,host:"192.168.182.144:27017", arbiterOnly:true}]})

rs.status() 查看状态

rs.conf() 查看配置

##### 添加节点

```
登录主节点添加节点
rs1 [direct: primary] test> rs.add("192.168.182.145:27017")
{
  ok: 1,
  '$clusterTime': {
    clusterTime: Timestamp({ t: 1685845557, i: 1 }),
    signature: {
      hash: Binary(Buffer.from("0000000000000000000000000000000000000000", "hex"), 0),
      keyId: Long("0")
    }
  },
  operationTime: Timestamp({ t: 1685845557, i: 1 })
}
rs1 [direct: primary] test> 
```

添加成功之后

访问主节点



java 驱动

  https://www.mongodb.com/docs/drivers/java/sync/v4.9/?_ga=2.113893319.1355180383.1685271753-1372951013.1685271753

https://mongodb.github.io/mongo-java-driver/4.9/driver-reactive/getting-started/installation/



### 6.6 高级操作

#### 6.6.1 数据库引用 



#### 6.6.2 全文检索 

2.6 版本以后是默认开启全文检索的 ,但 ensureIndex() 在 5.0 版本后已被移除，使用 createIndex() 代替。  

### 语法



```
db_name.table_name.createIndex({filed: "text"});   // 单个字段建立 全文索引 

创建全文检索 需要 use db之后查看相关的
db.test22222.createIndex({name:"text"});

db.test22222.ensureIndex({name:"text"})

执行查询需要use raintest


 
 查询索引
 db.test22222.getIndexes()
 全文搜索是按照关键字匹配的
 db.test22222.find({$text: {$search:"wan"}})   

不添加db的话直接回报错哦
raintest.test22222.createIndex({name:"text"});



ReferenceError: raintest is not defined

查看创建的多索引
db.raintest.test22222.getIndexes()

test> db.raintest.test22222.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  {
    v: 2,
    key: { _fts: 'text', _ftsx: 1 },
    name: 'name_text',
    weights: { name: 1 },
    default_language: 'english',
    language_override: 'language',
    textIndexVersion: 3
  }
]


```





## 7.常见问题

1.MongoDB报错“not authorized on admin to execute command“

此错误是因为没有授权给admin用户对system.version表执行命令的权限，解决方法如下:
\> db.grantRolesToUser ( "root", [ { role: "__system", db: "admin" } ] )

2.MongoServerError: replSetInitiate quorum check failed because not all proposed set members responded affirmatively: 192.168.182.144:27017 failed with Authentication failed., 192.168.182.143:27017 failed with Authentication failed

配置文件中开启了权限校验

3."ctx":"ReplCoord-0","msg":"Attempting to set local replica set config; validating config for startup"}
{"t":{"$date":"2023-06-07T11:32:24.884-04:00"},"s":"E",  "c":"REPL",     "id":21415,   "ctx":"ReplCoord-0","msg":"Locally stored replica set configuration is invalid; See http://www.mongodb.org/dochub/core/recover-replica-set-from-invalid-config for information on how to recover from this","attr":{"error":{"code":2,"codeName":"BadValue","errmsg":"Nodes started with the --configsvr flag must have configsvr:true in their config"},"localConfig":{"_id":"rs1","version":4,"term":6,"members":[{"_id":0,"host":"192.168.182.142:27017","arbiterOnly":



这个是因为之前创建了replicanset 集群，删除data目录下数据启动正常

4.Cannot assign requested address

{"t":{"$date":"2023-06-07T11:39:41.805-04:00"},"s":"E",  "c":"CONTROL",  "id":20568,   "ctx":"initandlisten","msg":"Error setting up listener","attr":{"error":{"code":9001,"codeName":"SocketException","errmsg":"Cannot assign requested address"}}}
{"t":{"$date":"2023-06-07T11:39:41.805-04:00"},"s":"I",  "c":"REPL",     "id":4784900, 



## 8.优化实践

8.1  优化建议

1. 数据模式设计；提倡单文档设计，将关联关系作为内嵌文档或者内嵌数组；当关联数据量较大时，考虑通过表关联实现，dbref或者自定义实现关联。

2. 避免单独使用不适用索引的查询符（$ne、$nin、$where等）。

3. 避免使用skip跳过大量数据 。

   - 通过查询条件尽量缩小数据范围。

   - 利用上一次的结果作为条件来查询下一页的结果。

4. 根据业务场景选择合适的写入策略，在数据安全和性能之间找到平衡点。
   1. 这个怎么找？



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

#### 官方手册

https://docs.mongoing.com/


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