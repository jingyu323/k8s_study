# Redis相关

## 1.介绍



集群模式：



主从模式：



哨兵模式：





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

 

1）、基于内存存储，可以降低对关系型数据库的访问频次，从而缓解数据库压力

2）、数据IO操作能支持更高级别的QPS，官方发布的指标是10W；

3）、提供了比较多的数据存储结构，比如string、list、hash、set、zset等等。

4）、采用单线程实现IO操作，避免了并发情况下的线程安全问题。

5）、可以支持数据持久化，避免因服务器故障导致数据丢失的问题

6）、Redis还提供了更多高级功能，比如分布式锁、分布式队列、排行榜、查找附近的人等功能，为更复杂的需求提供了成熟的解决方案。





## 4.实现原理

redis 持久化方式：AOF  RDB

### 4.1    RDB

1. 技术原理
RDB持久化是通过将Redis在内存中的数据库记录定时dump到磁盘上的二进制文件中，实现数据的持久化。这个过程可以理解为对Redis内存数据的快照。当Redis需要持久化数据时，它会fork一个子进程，子进程负责将内存中的数据写入到临时文件中，写入成功后，再用这个临时文件替换上次的快照文件。由于这个过程是在子进程中完成的，所以主进程可以继续处理客户端的请求，不会受到持久化操作的影响。

2. 触发机制
RDB持久化有三种触发机制：

​		save命令：这是一个同步操作，会阻塞当前Redis服务器，直到RDB完成为止。因此，线上环境一般禁止使用。
​		bgsave命令：这是Redis内部默认的持久化方式，它是一个异步操作。当执行bgsave命令时，Redis会fork一个子进程来完成RDB的过程，主进程可以继续处		理客户端请求。
​		自动触发：可以在redis.conf配置文件中设置自动触发的条件，比如“save 900 1”表示在900秒内，如果至少有1个key发生变化，则自动触发bgsave命令 

3. 优点
  RDB文件紧凑，全量备份，非常适合用于进行备份和灾难恢复。
  对于大规模数据的恢复，且对于数据恢复的完整性不是非常敏感的场景，RDB的恢复速度要比AOF方式更加的高效。
  生成RDB文件的时候，redis主进程会fork()一个子进程来处理所有保存工作，主进程不需要进行任何磁盘IO操作。
4. 缺点
  fork的时候，内存中的数据被克隆了一份，大致2倍的膨胀性需要考虑。
  当进行快照持久化时，会开启一个子进程专门负责快照持久化，子进程会拥有父进程的内存数据，父进程修改内存子进程不会反应出来，所以在快照持久化期间修改的数据不会被保存，可能丢失数据。
  在一定间隔时间做一次备份，所以如果redis意外down掉的话，就会丢失最后一次快照后的所有修改。
5. 示例
假设Redis的配置文件中设置了以下自动触发条件：

​	save 900 1
​	save 300 10
​	save 60 10000
​	1
​	2
​	3
这意味着在以下三种情况下，会自动触发bgsave命令进行持久化：

在900秒内，如果至少有1个key发生变化。
在300秒内，如果至少有10个key发生变化。
在60秒内，如果至少有10000个key发生变化 

### 4.2 AOF（追加文件持久化）

###### 1. 技术原理

AOF持久化是通过将Redis执行过的每个写操作以日志的形式记录下来，当服务器重启时会重新执行这些命令来恢复数据。AOF文件以追加的方式写入，即新的写操作会追加到文件的末尾，而不是覆盖之前的内容。这种方式可以确保数据的完整性和一致性。

2. 触发机制
AOF持久化是异步操作的，Redis会在后台线程中执行fsync操作，将AOF文件的内容同步到磁盘上。用户可以通过配置appendfsync参数来控制fsync操作的频率：

appendfsync always：每次有数据修改发生时都会写入AOF文件，这样会严重降低Redis的速度。
appendfsync everysec：每秒钟同步一次，这是AOF的缺省策略，它可以在性能和数据安全性之间取得一个平衡。
appendfsync no：从不主动同步，而是让操作系统决定何时进行同步，这种方式性能最好，但数据安全性最差。
3. 优点
AOF可以更好的保护数据不丢失，一般AOF会每隔1秒，通过一个后台线程执行一次fsync操作，最多丢失1秒钟的数据。
AOF只是追加写日志文件，对服务器性能影响较小，速度比RDB要快，消耗的内存较少。
AOF日志文件即使过大的时候，出现后台重写操作，也不会影响客户端的读写。
AOF日志文件的命令通过非常可读的方式进行记录，这个特性非常适合做灾难性的误删除的紧急恢复。
4. 缺点
AOF文件会越来越大，需要定期进行AOF重写来压缩文件大小。
在数据恢复时，AOF需要执行所有的写操作命令，这可能比RDB的全量加载要慢一些

###### 5. 示例

Redis的配置文件中设置以下参数来启用AOF持久化：

 `appendonly yes
appendfsync everysec`

这意味着Redis会启用AOF持久化，并且每秒钟将AOF文件的内容同步到磁盘上。当Redis执行写操作时，这些操作会被追加到AOF文件的末尾。例如，如果执行了以下命令：

SET mykey "hello"
INCR mycounter
1
2
那么AOF文件中会记录这些命令：

*2\r\n$3\r\nSET\r\n$5\r\nmykey\r\n$5\r\nhello\r\n*2\r\n$4\r\nINCR\r\n$9\r\nmycounter\r\n
1
当Redis服务器重启时，它会重新执行AOF文件中的这些命令来恢复数据。

<table><thead><tr><th></th><th>RDB</th><th>AOF</th></tr></thead><tbody><tr><td><strong>技术原理</strong></td><td>将内存中的数据库记录定时dump到磁盘上的二进制文件中</td><td>将Redis执行过的每个写操作以日志的形式记录下来</td></tr><tr><td><strong>触发机制</strong></td><td>save、bgsave、自动触发</td><td>appendfsync控制同步频率</td></tr><tr><td><strong>性能影响</strong></td><td>fork时会有短暂的阻塞，但主进程可以继续处理请求</td><td>异步操作，对性能影响较小</td></tr><tr><td><strong>文件大小</strong></td><td>紧凑，全量备份</td><td>会逐渐增大，需要定期重写</td></tr><tr><td><strong>数据恢复速度</strong></td><td>较快，适合大规模数据的恢复</td><td>较慢，需要执行所有的写操作命令</td></tr><tr><td><strong>数据安全性</strong></td><td>可能丢失最后一次快照后的所有修改</td><td>最多丢失1秒钟的数据</td></tr><tr><td><strong>适用场景</strong></td><td>对数据恢复完整性不是非常敏感的场景</td><td>对数据安全性要求较高的场景</td></tr></tbody></table>



Redis的RDB和AOF两种持久化方式各有优缺点，适用于不同的场景。RDB适用于大规模数据的备份和灾难恢复，恢复速度较快，但可能丢失最后一次快照后的所有修改。AOF则更适合对数据安全性要求较高的场景，可以最大程度地保护数据不丢失，但恢复速度较慢，且AOF文件会逐渐增大，需要定期重写。在实际应用中，可以根据具体需求和性能要求进行权衡和选择，甚至可以同时使用两种持久化方式来确保数据的安全性和可靠性。
 

#### 同时使用 RDB 和 AOF

当同时启用 RDB 和 AOF 时，Redis 在重启时会优先使用 AOF 文件来恢复数据，因为 AOF 通常更为完整。如果 AOF 被禁用或配置为 no，则使用 RDB 文件恢复数据。

**配置 RDB**:

`save 900 1
save 300 10
save 60 10000`

**配置 AOF**:

```
appendonly yes
# 设置 AOF 同步策略
# always: 每次操作后都同步，最安全但性能最低
# everysec: 每秒同步一次，折中方案
# no: 不主动 fsync，依赖于操作系统的调度
appendfsync everysec

```

这样，Redis 就会同时使用 RDB 和 AOF 来确保数据的安全性和完整性。如果发生崩溃，Redis 会尝试从 AOF 文件中恢复尽可能多的数据；如果 AOF 文件不可用或损坏，它会回退到最近的 RDB 快照。这种组合提供了更好的容错性，但也增加了存储需求和潜在的恢复时间。

## 5.安装

解压安装包 

tar zvxf redis-6.2.7.tar.gz 

yum install gcc 

make PREFIX=/usr/local/redis install



systemctl status redis-server

## 6.使用

缓存，作为Key-Value形态的内存数据库，Redis 最先会被想到的应用场景便是作为数据缓存

分布式锁，分布式环境下对资源加锁

分布式共享数据，在多个应用之间共享

排行榜，自带排序的数据结构（zset）

消息队列，pub/sub功能也可以用作发布者 / 订阅者模型的消息



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



优点：1.实现方便 2.性能高效 3.避免单点故障

缺点：如何设置合适的超时时间问题导致锁不可靠









#### 设置了超时时间，就确保万无一失了吗？

操作锁内资源超过笔者设置的超时时间，那么就会导致其他进程拿到锁，等进程A回来了，回手就是把其他进程的锁删了

可以加一层判定，当自己的进程结束或者过期，若value不是自己的值，则不进行删除操作流程



（1）防止解锁失败：如拿到锁后执行业务逻辑时一旦出现异常就无法释放锁，解决这个问题只需**将释放锁的逻辑放入finally代码块中即可，无论是否有异常都会释放锁**

（2）设置锁的有效期 

 原子性有现成的接口，如下：

Boolean ifAbsent = valueOperations.setIfAbsent(key, value, 30, TimeUnit.SECONDS); 

（3）防止误删锁：**加锁的时候把值设置为唯一的，如UUID、雪花算法等方式，释放锁时获取锁的值判断是不是当前线程设置的值，如果是再去删除** 

（4）Watch Dog机制：也叫看门狗，旨在延长锁的过期时间；为什么要这么做呢？比如把锁的过期时间设为10秒，但拿到锁的线程要执行20秒才结束，锁超时自动释放其它线程便能获取到，这是不被允许的，所以看门狗就闪亮登场了；它的大概流程是在加锁成功后启动一个监控线程，每隔1/3的锁的过期时间就去重置锁过期时间，比如说锁设置为30秒，那就是每隔10秒判断锁是否存在，存在就去延长锁的过期时间，重新设置为30秒，业务执行结束关闭监控线程；这样就解决了业务未执行完锁被释放的问题， 





### Redisson

#### 公平锁

RLock fairLock = redissonClient.getFairLock("fairLock_" + goodsId);

fairLock.lock();

fairLock.unlock();



#### 红锁  解决分布式加锁的问题

可以使用红锁来解决主从架构锁失效问题：就是说在主从架构系统中，线程A从master中获取到分布式锁，数据还未同步到slave中时master就挂掉了，slave成为新的master，其它线程从新的master获取锁也成功了，就会出现并发安全问题



#### 联锁 

 联锁（RedissonMultiLock）对象可以将多个RLock对象关联为一个联锁，实现加锁和解锁功能。每个RLock对象实例可以来自于不同的Redisson实例。

RLock one = redissonClient.getLock("one_" + id);
		RLock two = redissonClient.getLock("two_" + id);
		RLock three = redissonClient.getLock("three_" + id);
		RedissonMultiLock multiLock = new RedissonMultiLock(one, two, three);  







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



##### 缓存穿透- 缓存中不存的数据每次都去数据库中查询

 	给不存在的key设置一个null 值，防止恶意攻击，设置短期过期时间

##### 缓存并发-  解决方法：对更新加锁，保证只有一个线程更新数据

##### 缓存雪崩：

- 失效时间随机，防止缓存集体失效
- 选择设置缓存不过期，后台来更新缓存数据，避免因缓存失效的问题导致的雪崩问题

热点数据缓存：



缓存



 

### 数据不一致问题：

本质是写数据库和更新缓存两个步骤之前存在可能存在一种更新执行失败时导致数据不一致的情况出现，而不是短暂的数据不一致问题

#### Redis数据一致性问题的三种解决方案：

##### 1. 延迟双删

先进行缓存清除，再执行update，最后（延迟N秒）再执行缓存清除。进行两次删除，且中间需要延迟一段时间

##### 2. 通过发送MQ，在消费者线程去同步Redis

异步重试我们可以使用消息队列来完成，因为消息队列可以保证消息的可靠性，消息不会丢失，也可以保证正确消费，当且仅当消息消费成功后才会将消息从消息队列中删除。

优点1：可以大幅减少接口的延迟返回的问题

优点2：MQ本身有重试机制，无需人工去写重试代码

优点3：解耦，把查询Mysql和同步Redis完全分离，互不干扰

##### 3. Canal 订阅日志实现

订阅数据库变更日志，当数据库发生变更时，我们可以拿到具体操作的数据，然后再去根据具体的数据，去删除对应的缓存。

##### 4.MISCONF Redis isat ora.redisson.client ,handler,CommandDecoder ,decode lCommandDecoder . iava:371)at org.redisson.client,handler 

一般要检查数据文件所在目录权限，权限不足导致文件合并失败

redis.log报如下错误

Error moving temp DB file temp-3420.rdb on the final destination dump.rdb (in server root dir D:\home\htkj\Redis-x64-3.2.100): Input/output error

##### 5.AOF破损文件的修复

     如果redis在append数据到AOF文件时，机器宕机了，可能会导致AOF文件破损用redis-check-aof --fix命令来修复破损的AOF文件。

## 参考资料