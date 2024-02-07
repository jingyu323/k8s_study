# Redis相关

## 1.介绍

## 2.配置

```
##控制一个pool最多有多少个状态为idle(空闲的)的jedis实例，默认值也是8。
redis.maxIdle=80
##最小空闲数
redis.minIdle=10
##最大连接数：能够同时建立的“最大链接个数”
redis.maxTotal=500
#每次最大连接数
redis.numTestsPerEvictionRun=1024
##最大建立连接等待时间：单位ms
##当borrow一个jedis实例时，最大的等待时间，如果超过等待时间，则直接抛出JedisConnectionException；
redis.maxWait=5000
##使用连接时，检测连接是否成功 
redis.testOnBorrow=true
#连接耗尽时是否阻塞，false报异常，true阻塞超时,默认true
redis.blockWhenExhausted=false
##在return给pool时，是否提前进行validate操作
redis.testOnReturn=true

##当客户端闲置多长时间后关闭连接，如果指定为0，表示关闭该功能，单位毫秒
redis.timeout=3000
#在空闲时检查有效性，默认false
redis.testWhileIdle=true
#连接的最小空闲时间，连接池中连接可空闲的时间
redis.minEvictableIdleTimeMills=30000

#释放扫描的扫描间隔，单位毫秒数；检查一次连接池中空闲的连接,把空闲时间超过minEvictableIdleTimeMillis毫秒的连接断开，直到连接池中的连接数到minIdle为止
redis.timeBetweenEvictionRunsMillis=60000

```



## 3.优点

## 4.实现原理

## 5.安装

解压安装包 

tar zvxf redis-6.2.7.tar.gz 

yum install gcc 

make PREFIX=/usr/local/redis install



systemctl status redis-server

## 6.使用

客户端登录

./bin/redis-cli -p 6499

### 数据类型
1.zset  有序集合



Redis 有序[集合](https://so.csdn.net/so/search?q=集合&spm=1001.2101.3001.7020)和集合一样也是 string 类型元素的集合,且不允许重复的成员。

不同的是每个元素都会关联一个 double 类型的分数。redis 正是通过分数来为集合中的成员进行从小到大的排序。

有序集合的成员是唯一的,但分数(score)却可以重复

```
zadd：新增成员
zrem：根据指定key进行删除
zrank：指定key和值，获取下标
zadd zset 1 one 2 two 3 three 4 four 5 five
zrange：获取成员信息
zrevrange：倒序展示列表
zrank：指定key和值，获取下标
```



2.String数据类型 

最大能存储 512MB 的数据，String类型是二进制安全的，即可以存储任何数据、比如数字、图片、序列化对象等



适用场景：

1. 计数器
2. 统计多单位的数量
3. 粉丝数
4. 对象缓存存储



```
SETNX key value:不存在键的话执行set操作，存在的话不执行

```





3.Set  



4.Hash 存储字典

Redis hash 是一个 string 类型的 field（字段） 和 value（值） 的映射表，hash 特别适合用于存储对象。

Redis 中每个 hash 可以存储 232 - 1 键值对（40多亿）。

hash类型可以理解为map集合，{key1:value1,key2:value2} 

```
hmset map name liudd age 2 sex man
 
hgetall map

hmset user:1 name 张 age 18 job stu
 
 特有命令
incrby：指定属性增加整数增量
incrbyfloat：指定属性增加浮点型增量

```



5.List  有序列表

Redis列表是简单的[字符串](https://so.csdn.net/so/search?q=字符串&spm=1001.2101.3001.7020)列表，按照插入顺序排序。你可以添加一个元素到列表的头部（左边）或者尾部（右边）

一个列表最多可以包含 232 - 1 个元素 (4294967295, 每个列表超过40亿个元素)。

list可以理解为一个通道，可以左边进，也可以右边进。

##### Hyperloglog 





##### Geospatial

Geospatial类型，底层实现原理实现为zset类型！

这只是假设地球是一个球体，因为使用的距离公式是Haversine公式。这个公式仅适用于地球，而不是一个完美的球体。当在社交网站和其他大多数需要查询半径的应用中使用时，这些偏差都不算问题。但是，在最坏的情况下的偏差可能是0.5%，所以一些地理位置很关键的应用还是需要谨慎考虑。



https://blog.csdn.net/liu_dongdong55/article/details/120881332?spm=1001.2014.3001.5502



##### 事务

Redis 的事务只是一组命令的集合，一个事务中的所有命令都会被[序列化](https://so.csdn.net/so/search?q=序列化&spm=1001.2101.3001.7020)，执行过程中按照顺序执行，并且其它会话提交的命令不会插入到事务执行的命令序列中

1. 保证
Redis 事务可以一次执行多个命令， 并且带有以下三个重要的保证：

批量操作在发送 EXEC 命令前被放入队列缓存。
收到 EXEC 命令后进入事务执行，事务中任意命令执行失败，其余的命令依然被执行。
在事务执行过程，其他客户端提交的命令请求不会插入到事务执行命令序列中。
Redis 的事务就是一次性，顺序性，排他性的执行一个队列中的一系列命令

2. 特点
Redis 的事务并没有隔离级别的概念，事务中的命令在执行之前会被放入队列缓存，并不会被实际执行，也就不存在事务内的查询要看到事务内的更新，而事务外的查询看不到的情况
Redis 的单条命令时保证原子性的，但是 Redis 的事务是不保证原子性的且没有回滚。事务中的任意一条命令执行失败后，其余的命令仍然会执行 ( 但是语法错误的命令会导致事务中所有命令都不会被执行 ) 

#####  Bitmaps

Bitmaps 并不是实际的数据类型，而是定义在String类型上的一个面向字节操作的集合。因为字符串是二进制安全的块，他们的最大长度是512M，最适合设置成2^32个不同字节。

Bitmaps 的最大优势之一在存储信息时极其节约空间。例如，在一个以增量用户ID来标识不同用户的系统中，记录用户的四十亿的一个单独bit信息（例如，要知道用户是否想要接收最新的来信）仅仅使用512M内存。 

### 实现锁机制

##### 实现分布式锁

如果setnx 返回ok 说明拿到了锁；如果setnx 返回 nil，说明拿锁失败，被其他线程占用。

#### 设置了超时时间，就确保万无一失了吗？

操作锁内资源超过笔者设置的超时时间，那么就会导致其他进程拿到锁，等进程A回来了，回手就是把其他进程的锁删了

可以加一层判定，当自己的进程结束或者过期，若value不是自己的值，则不进行删除操作流程











## 7.常见问题

1.redis 只有单线程吗？

redis是单线程的，主要是io线程，redis持久化、集群同步邓操作则是由另外的线程来执行的

2.redis 单线程为什么还这么快

redis大部分操作都是在内存中完成的，单线程模型避免了多线程之间的线程竞争，redis 采用I/O多路复用机制处理大量的socket 请求

6.0版本之后 采用了多线程处理I/O，其他的数据读写还是采用单线程

3.redis 数据存储持久化

- AOF日志 记录的是redis 收到的 操作命令
- RDB 存储内存快照
  4. 解决数据不一致问题方法：
     - 写入数据的时候同时更新缓存
     - 读操作双重检查
     - **定时同步数据**
     - 消息队列

## 缓存



缓存穿透- 缓存中不存的数据每次都去数据库中查询

 	给不存在的key设置一个null 值，防止恶意攻击

缓存并发-  解决方法：对更新加锁，保证只有一个线程更新数据

缓存雪崩：

- 失效时间随机，防止缓存集体失效
- 选择设置缓存不过期，后台来更新缓存数据，避免因缓存失效的问题导致的雪崩问题

热点数据缓存：



缓存



## 参考资料