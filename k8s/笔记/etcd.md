#  ETCD简介

etcd是由CoreOS团队发的一个分布式一致性的KV存储系统，可用于服务注册发现和共享配置，随着CoreOS和Kubernetes等项目在开源社区日益火热，它们项目中都用到的etcd组件作为一个高可用强一致性的服务发现存储仓库，渐渐为开发人员所关注。在云计算时代，如何让服务快速透明地接入到计算集群中，如何让共享配置信息快速被集群中的所有机器发现，更为重要的是，如何构建这样一套高可用、安全、易于部署以及响应快速的服务集群，已经成为了迫切需要解决的问题。 

对 Zookeeper 进行的 etcd 改进包括：

- 动态重新配置集群成员
- 高负载下稳定的读写
- 多版本并发控制数据模型
- 可靠的键值监控
- 租期原语将 session 中的连接解耦
- 用于分布式共享锁的 API



## 1.ETCD命令

启动

 ./etcd --config-file= /mnt/app//etcd/conf/etcd.json

查看节点

./etcdctl member list

查看集群状态（Leader节点）：

$ ./etcdctl cluster-health



#### 读写：

1.下面通过给message key设置Hello值示例：

$ ./etcdctl set /message Hello

Hello

$ curl -X PUT http://127.0.0.1:2379/v2/keys/message -d value="Hello"
{"action":"set","node":{"key":"/message","value":"Hello","modifiedIndex":4,"createdIndex":4}}
2.读取message的值：

$ ./etcdctl  get /message
Hello

$ curl http://127.0.0.1:2379/v2/keys/message
{"action":"get","node":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}
3.删除message key：

$ ./etcdctl  rm  /message

$ curl -X DELETE http://127.0.0.1:2379/v2/keys/message
{"action":"delete","node":{"key":"/message","modifiedIndex":10,"createdIndex":9},"prevNode":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}
说明：因为是集群，所以message在其中一个节点创建后，在集群中的任何节点都可以查询到。

4.查看所有key-value：

curl -s http://127.0.0.1:2379/v2/keys/?recursive=true



# ETCD架构和原理

![](images\etcd_jiagou.png)

- ***\*选举（Leader election）\*******\*：\****Raft定义集群节点有4种状态，分别是Leader、Follower、Candidate、PreCandidate。***\*正常情况下\*******\*，\****Leader节点会按照心跳间隔时间，定时广播心跳消息给Follower节点，以维持Leader身份。Follower收到后回复消息给Leader。Leader都会带有一个任期号(term)，用于比较各个节点数据新旧，识别过期Leader等。***\*当Leader节点异常时，\****Follower节点会接收Leader的心跳消息超时，当超时时间大于竞选超时时间后，会进入PreCandidate状态，不自增任期号仅发起预投票，获得大多数节点认可后，进入Candidate状态并等待一个随机时间，然后发起选举流程，自增任期号投票给自己，并向其他节点发送竞选投票信息。当节点收到其他节点的竞选消息后，首先判断竞选节点的数据及任期号大于本节点，并且在本节点未发起选举给自己投，则可以投票给竞选节点，否则拒绝投票。
- ***\*日志复制（Log replication）\*******\*：\****Raft日志由有序索引的一个个条目组成，每个日志条目包含了任期号和提案内容。Leader通过维护两个字段来追踪各个Follower的进度信息。一个是***\*NextIndex，\****表示Leader发送给该Follower节点的下一个日志条目索引;另一个是***\*MatchIndex\****，表示该Follower节点已复制的最大日志条目索引。

## 1. etcd 集群生命周期管理

- etcd 集群创建，销毁，停止，升级，故障恢复等。
- etcd 集群状态监控，包括集群健康状态、member 健康状态，访问量，存储数据量等。
- etcd 异常诊断、预案、黑盒探测，配置巡检等。

## 2. etcd 数据管理

etcd 数据管理包括数据迁移、备份管理以及恢复，脏数据清理，热点数据识别等。这块是 alpha 的特色，我们发现开源或其他产品这方面做得工作很少。我们做的功能具体如下。

### **1）etcd 数据备份及恢复**

两种方式如下：

- 传统模式冷备：支持从 etcdserver 将 snapshot 数据备份至阿里云 OSS 或本地，故障时可以根据这个 snapshot 备份文件恢复。
- raft learner 热备：对于新版本的使用了 raft learner 特性的 etcd 集群，我们可以使用 learner 作为热备节点，当故障发生时，我们强制将 learner 转换为正常节点，并将客户端访问切到这个新节点上，相比于传统方式故障恢复时间更快，并且 learner 可以部署在不同的地域，实现异地多活的能力。

### **2）脏数据清理**

我们可以根据指定 etcd key 前缀删除垃圾 kv 的能力，降低 etcd server 存储压力。

### **3）热点数据识别**

我们开发了按照 etcd key 前缀进行聚合分析热点 key 的能力，另外还可以分析不同 key 前缀的 db 存储使用量。利用这个能力，我们多次帮助客户排查分析 etcd 热点 key，解决 etcd 滥用问题，这个在大规模 etcd 集群上是一个必备的能力。

### **4）数据迁移能力，两种方式**

- snapshot 方式：通过 etcdsnapshot 备份，再恢复进行迁移方式。
- raft learner 模式：我们使用 raft learner 特性可以快速从原集群分裂衍生出新的集群实现集群迁移。

### **5）数据水平拆分**

当集群数据存储数据量超大时，我们支持使用水平拆分将不同客户数据拆分存储到不同的 etcd 集群中。我们在阿里内部 ASI 集群就用了这个功能，使其支持超万规模节点。

总结一下，我们采用 Kubernetes 作为 etcd 集群的运行底座，基于开源 operator 改良适配研发了新的 etcd 管控软件 alpha，覆盖 etcd 全生命周期管控工作，一套软件管理所有 etcd 集群，显著提升了 etcd 管控效率。

# etcd 内核架构升级更新

etcd 是云原生社区中非常重要的一款软件，几年的演进发展，解决了很多 bug, 提升了内核的性能和存储容量。但开源软件就像是一个毛坯房，真正在生产环境使用问题还是有的，阿里内部有更大数据存储规模和性能方面的要求，另外 etcd 自身多租户共享使用 QoS 控制能力很弱，不适用于我们的使用场景。

我们早期使用开源的 etcd 3.2/3.3 版本, 针对一些我们的使用场景需求，后续我们加入了一些稳定性和安全增强，形成了现在我们使用阿里内部版本，如下展示了重要的几个不同：

## 1. 自适应历史数据清理 compact 技术

etcd 会存储用户数据的历史值，但是它不能长久的存储所有历史值，否则存储空间会不足。因此 etcd 内部会利用 Compact 机制周期性地清理历史值数据。当我们的集群超大，数据量超大时，每次清理对运行时性能影响很大，可以类比一次 full gc。本技术可以根据业务请求量调整 Compact 时机，避开业务使用高峰期, 减少干扰。

## 2. 基于 raft learner 的只读节点水平扩展能力

raft learner 是 raft 协议中的一种特殊的角色，他不参与 leader 选举， 但是可以从 leader 处获得集群中最新的数据，因此他可以作为集群的只读节点进行水平扩展，提升集群处理读请求的能力。

## 3. 基于 raft learner 的热备节点

除了上面说的 raft learner 可以作为只读节点，我们也可以将其使能用于作为集群的热备节点，目前我们广泛使用热备节点做异地双活，保证集群高可用。

## 4. etcd 集群 QoS 能力

公有云上，我们有大量的用户采用共享 etcd 集群的方式使用 etcd, 在这种多租户使用场景下我们即需要保证租户公平使用 etcd 存储资源，也要保证稳定性即不会因为某一租户的滥用将集群整体搞挂，影响其他租户使用。为此我们自研了相应的QoS限流功能，可以实现不同租户运行时读写数据流量限制以及静态存储数据空间限制。



# 常见问题：



### 脑裂问题

集群化的软件总会提到脑裂问题，如ElasticSearch、Zookeeper集群，脑裂就是同一个集群中的不同节点，对于集群的状态有了不一样的理解。

etcd 中有没有脑裂问题？答案是： 没有

```bash
The majority side becomes the available cluster and the minority side is unavailable; there is no “split-brain” in etcd.
```

以网络分区导致脑裂为例，一开始有5个节点, Node 5 为 Leader

![img](https://vermouth-blog-image.oss-cn-hongkong.aliyuncs.com/monitor/3944b217-12ba-48b3-8e7b-f3ff12d5d40b.jpg?x-oss-process=style/watermark)

由于出现网络故障，124 成为一个分区，35 成为一个分区， Node 5 的 leader 任期还没结束的一段时间内，仍然认为自己是当前leader，但是此时另外一边的分区，因为124无法连接 5，于是选出了新的leader 1，网络分区形成。

![img](https://vermouth-blog-image.oss-cn-hongkong.aliyuncs.com/monitor/e52364d2-45e8-47b8-80d4-db2608fe6ec1.jpg?x-oss-process=style/watermark)

35分区是否可用？如果写入了1而读取了 5，是否会读取旧数据(stale read)?

答：35分区属于少数派，被认为是异常节点，无法执行写操作。写入 1 的可以成功，并在网络分区恢复后，35 因为任期旧，会自动成为 follower，异常期间的新数据也会从 1 同步给 35。

而 5 的读请求也会失败，etcd 通过ReadIndex、Lease read保证线性一致读，即节点5在处理读请求时，首先需要与集群多数节点确认自己依然是Leader并查询 commit index，5做不到多数节点确认，因此读失败。

因此 etcd 不存在脑裂问题。线性一致读的内容下面会提到。

### etcd 是强一致性吗

是强一致性，读和写都可以保证线性一致，关于一致性的分析可以看 [这篇文章](http://www.xuyasong.com/?p=1970)

#### 线性一致读

线性一致性读需要在所有节点走一遍确认，查询速度会有所降低，要开启线性一致性读，在不同的 client是有所区别的:

- v2 版本：通过 sdk访问时，quorum=true 的时候读取是线性一致的，通过etcdctl访问时，该参数默认为true。
- v3 版本：通过 sdk访问时，WithSerializable=true 的时候读取是线性一致的，通过etcdctl访问时consistency=“l”表示线性（默认为 l，非线性为 s）

为了保证线性一致性读，早期的 etcd（_etcd v3.0 _）对所有的读写请求都会走一遍 Raft 协议来满足强一致性。然而通常在现实使用中，读请求占了 etcd 所有请求中的绝大部分，如果每次读请求都要走一遍 raft 协议落盘，etcd 性能将非常差。

因此在 etcd v3.1 版本中优化了读请求（PR#6275），使用的方法满足一个简单的策略：每次读操作时记录此时集群的 commit index，当状态机的 apply index 大于或者等于 commit index 时即可返回数据。由于此时状态机已经把读请求所要读的 commit index 对应的日志进行了 apply 操作，符合线性一致读的要求，便可返回此时读到的结果

## 性能优化

##### 存储优化

Etcd的存储层采用tree-index作为索引，boltdb作为持久化存储。性能的优化也主要围绕这两个组件进行。

Etcd默认的tree-index采用了粒度比较粗的内部锁。这导致了两个面向相近节点的写请求有很大的几率发生冲突并阻塞。提升内部锁的深度和数量，可以让面向tree-index上不同子树的请求尽可能少的产生互锁，大幅度提升存储层面对高并发请求的效率。

持久化存储的boltdb也面对存储结构方面的性能问题。Etcd内部使用默认为4KB的页面大小来存储数据。用户在删除页数据的时候，Etcd并不会将页面直接还给系统，而是使用freelist记录空闲状态的页面，当用户再次写入数据时，Etcd使用满足数据长度要求的freelist中的若干个连续页面。

其实结论已经出现了，问题出现在freelist的“连续性”要求上。从头开始遍历直到找到一个空闲页面或许并不麻烦，但从头开始遍历找到>=N个连续空闲页面就比较麻烦了，这带来了极高的时间复杂度。阿里云团队对此提出了解决方案，他们建立了一个hashmap，以key为连续空闲页面的数量，value为满足数量要求的起始页面序号的集合。Hashmap的更新并不需要高频率反复遍历列表，当用户删除数据时，hashmap就会随之更新；当用户写入数据，需要申请一个长度为N的空间时，会向hashmap请求key=N的集合，并返回value中的第一个序号，作为数据存储的起始位置，同时hashmap也会更新。

##### 网络优化

众所周知，信息在网络中的传输时间与网络带宽成反比，与信息量成正比。在网络带宽不发生变化的前提下，完成一个网络请求传输的数据越少，速度就越快。

Etcd在存储层使用了tree-index作为json/xml树状逻辑结构的元数据到平铺的key-value之间的路由，这意味着，树状结构任何深度的节点都能够通过索引到达。在此前提下，如果想要修改json/xml的数据，可以将路由进行到最小的公共深度，并不修改全部数据，而是修改树状结构某一个子树的数据，这样就减少了通信量。甚至，多次数据操作还可以分解为多个子操作，提升最小的公共深度，以减少对无用数据的读取，和对未修改数据的覆写。

举个简单例子，/api/v1/metadata下可访问到json数据{key1: {key11: value11, key12: value12}, key2: value2}，如果相对value11进行更改，未经优化的方法是将修改后的json数据{ key1: {key11: newvalue11, key12: value12}, key2: value2}作为PUT请求的参数，访问/api/v1/metadata进行修改。由于tree-index的存在，请求可被优化为向/api/v1/metadata/key1/key11发送PUT请求，参数为newvalue11，或者向/api/v1/metadata发送PUT请求，参数为{URI: key1/key11, value: newvalue11}。通过精确利用tree-index，减小了数据的发送长度，提升了网络请求的效率。



# 参考材料

### ETCD 安装

https://blog.51cto.com/u_12386780/5160982?abTest=51cto

https://blog.51cto.com/u_11555417/5547222?abTest=51cto

https://blog.csdn.net/qq_42987484/article/details/103571446



### 架构介绍

https://blog.csdn.net/weixin_49925141/article/details/123023334

https://www.cnblogs.com/datacoding/p/7473953.html





