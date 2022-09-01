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

  任何时候如果其它 follower 在 election timeout 期间都没有收到来自 leader 的 heartbeat，同样会将自己的状态切换为 candidate 并发起选举。每成功选举一次，新 leader 的任期（Term）都会比之前leader 的任期大1

- ***\*日志复制（Log replication）\*******\*：\****Raft日志由有序索引的一个个条目组成，每个日志条目包含了任期号和提案内容。Leader通过维护两个字段来追踪各个Follower的进度信息。一个是***\*NextIndex，\****表示Leader发送给该Follower节点的下一个日志条目索引;另一个是***\*MatchIndex\****，表示该Follower节点已复制的最大日志条目索引。
- 一个用户的请求发送过来，会经由HTTP Server转发给Store进行具体的事务处理，如果涉及到节点的修改，则交给Raft模块进行状态的变更、日志的记录，然后再同步给别的etcd节点以确认数据提交，最后进行数据的提交，再次同步

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

### 4 集群化应用实践

etcd作为一个高可用键值存储系统，天生就是为集群化而设计的。由于Raft算法在做决策时需要多数节点的投票，所以etcd一般部署集群推荐奇数个节点，推荐的数量为3、5或者7个节点构成一个集群。

#### 4.1 集群启动

etcd有三种集群化启动的配置方案，分别为静态配置启动、etcd自身服务发现、通过DNS进行服务发现。

通过配置内容的不同，你可以对不同的方式进行选择。值得一提的是，这也是新版etcd区别于旧版的一大特性，它摒弃了使用配置文件进行参数配置的做法，转而使用命令行参数或者环境变量的做法来配置参数。

##### 4.1.1. 静态配置

这种方式比较适用于离线环境，在启动整个集群之前，你就已经预先清楚所要配置的集群大小，以及集群上各节点的地址和端口信息。那么启动时，你就可以通过配置`initial-cluster`参数进行etcd集群的启动。

在每个etcd机器启动时，配置环境变量或者添加启动参数的方式如下。

```
ETCD_INITIAL_CLUSTER=``"infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380"``ETCD_INITIAL_CLUSTER_STATE=new
```

参数方法：

```
-initial-cluster 
infra0=http://10.0.1.10:2380,http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
 -initial-cluster-state new
```

值得注意的是，`-initial-cluster`参数中配置的url地址必须与各个节点启动时设置的`initial-advertise-peer-urls`参数相同。（`initial-advertise-peer-urls`参数表示节点监听其他节点同步信号的地址）

如果你所在的网络环境配置了多个etcd集群，为了避免意外发生，最好使用`-initial-cluster-token`参数为每个集群单独配置一个token认证。这样就可以确保每个集群和集群的成员都拥有独特的ID。

综上所述，如果你要配置包含3个etcd节点的集群，那么你在三个机器上的启动命令分别如下所示。

```
 1 $ etcd -name infra0 -initial-advertise-peer-urls http://10.0.1.10:2380 \
 2   -listen-peer-urls http://10.0.1.10:2380 \
 3   -initial-cluster-token etcd-cluster-1 \
 4   -initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
 5   -initial-cluster-state new
 6 
 7 $ etcd -name infra1 -initial-advertise-peer-urls http://10.0.1.11:2380 \
 8   -listen-peer-urls http://10.0.1.11:2380 \
 9   -initial-cluster-token etcd-cluster-1 \
10   -initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
11   -initial-cluster-state new
12 
13 $ etcd -name infra2 -initial-advertise-peer-urls http://10.0.1.12:2380 \
14   -listen-peer-urls http://10.0.1.12:2380 \
15   -initial-cluster-token etcd-cluster-1 \
16   -initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
17   -initial-cluster-state new
```

在初始化完成后，etcd还提供动态增、删、改etcd集群节点的功能，这个需要用到`etcdctl`命令进行操作。

##### 4.1.2. etcd自发现模式

通过自发现的方式启动etcd集群需要事先准备一个etcd集群。如果你已经有一个etcd集群，首先你可以执行如下命令设定集群的大小，假设为3.

```
$ curl -X PUT http://myetcd.local/v2/keys/discovery/6c007a14875d53d9bf0ef5a6fc0257c817f0fb83/_config/size -d value=3
```

然后你要把这个url地址`http://myetcd.local/v2/keys/discovery/6c007a14875d53d9bf0ef5a6fc0257c817f0fb83`作为`-discovery`参数来启动etcd。节点会自动使用`http://myetcd.local/v2/keys/discovery/6c007a14875d53d9bf0ef5a6fc0257c817f0fb83`目录进行etcd的注册和发现服务。

所以最终你在某个机器上启动etcd的命令如下。

```
$ etcd -name infra0 -initial-advertise-peer-urls http://10.0.1.10:2380 \
  -listen-peer-urls http://10.0.1.10:2380 \
  -discovery http://myetcd.local/v2/keys/discovery/6c007a14875d53d9bf0ef5a6fc0257c817f0fb83
```

如果你本地没有可用的etcd集群，etcd官网提供了一个可以公网访问的etcd存储地址。你可以通过如下命令得到etcd服务的目录，并把它作为`-discovery`参数使用。

```
$ curl http://discovery.etcd.io/new?size=3
http://discovery.etcd.io/3e86b59982e49066c5d813af1c2e2579cbf573de
```

同样的，当你完成了集群的初始化后，这些信息就失去了作用。当你需要增加节点时，需要使用`etcdctl`来进行操作。

为了安全，请务必每次启动新etcd集群时，都使用新的discovery token进行注册。另外，如果你初始化时启动的节点超过了指定的数量，多余的节点会自动转化为Proxy模式的etcd。

##### 4.1.3. DNS自发现模式

etcd还支持使用DNS SRV记录进行启动。关于DNS SRV记录如何进行服务发现，可以参阅[RFC2782](http://tools.ietf.org/html/rfc2782)，所以，你要在DNS服务器上进行相应的配置。

(1) 开启DNS服务器上SRV记录查询，并添加相应的域名记录，使得查询到的结果类似如下。

```
$ dig +noall +answer SRV _etcd-server._tcp.example.com
_etcd-server._tcp.example.com. 300 IN   SRV 0 0 2380 infra0.example.com.
_etcd-server._tcp.example.com. 300 IN   SRV 0 0 2380 infra1.example.com.
_etcd-server._tcp.example.com. 300 IN   SRV 0 0 2380 infra2.example.com.
```

(2) 分别为各个域名配置相关的A记录指向etcd核心节点对应的机器IP。使得查询结果类似如下。

```
$ dig +noall +answer infra0.example.com infra1.example.com infra2.example.com
infra0.example.com. 300 IN  A   10.0.1.10
infra1.example.com. 300 IN  A   10.0.1.11
infra2.example.com. 300 IN  A   10.0.1.12
```

做好了上述两步DNS的配置，就可以使用DNS启动etcd集群了。配置DNS解析的url参数为`-discovery-srv`，其中某一个节点地启动命令如下。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
$ etcd -name infra0 \
-discovery-srv example.com \
-initial-advertise-peer-urls http://infra0.example.com:2380 \
-initial-cluster-token etcd-cluster-1 \
-initial-cluster-state new \
-advertise-client-urls http://infra0.example.com:2379 \
-listen-client-urls http://infra0.example.com:2379 \
-listen-peer-urls http://infra0.example.com:2380
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

当然，你也可以直接把节点的域名改成IP来启动。

#### 4.2 关键部分源码解析

etcd的启动是从主目录下的`main.go`开始的，然后进入`etcdmain/etcd.go`，载入配置参数。如果被配置为Proxy模式，则进入startProxy函数，否则进入startEtcd，开启etcd服务模块和http请求处理模块。

在启动http监听时，为了保持与集群其他etcd机器（peers）保持连接，都采用的`transport.NewTimeoutListener`启动方式，这样在超过指定时间没有获得响应时就会出现超时错误。而在监听client请求时，采用的是`transport.NewKeepAliveListener`，有助于连接的稳定。

在`etcdmain/etcd.go`中的setupCluster函数可以看到，根据不同etcd的参数，启动集群的方法略有不同，但是最终需要的就是一个IP与端口构成的字符串。

在静态配置的启动方式中，集群的所有信息都已经在给出，所以直接解析用逗号隔开的集群url信息就好了。

DNS发现的方式类似，会预先发送一个tcp的SRV请求，先查看`etcd-server-ssl._tcp.example.com`下是否有集群的域名信息，如果没有找到，则去查看`etcd-server._tcp.example.com`。根据找到的域名，解析出对应的IP和端口，即集群的url信息。

较为复杂是etcd式的自发现启动。首先就用自身单个的url构成一个集群，然后在启动的过程中根据参数进入`discovery/discovery.go`源码的`JoinCluster`函数。因为我们事先是知道启动时使用的etcd的token地址的，里面包含了集群大小(size)信息。在这个过程其实是个不断监测与等待的过程。启动的第一步就是在这个etcd的token目录下注册自身的信息，然后再监测token目录下所有节点的数量，如果数量没有达标，则循环等待。当数量达到要求时，才结束，进入正常的启动过程。

配置etcd过程中通常要用到两种url地址容易混淆，一种用于etcd集群同步信息并保持连接，通常称为peer-urls；另外一种用于接收用户端发来的HTTP请求，通常称为client-urls。

- `peer-urls`：通常监听的端口为`2380`（老版本使用的端口为`7001`），包括所有已经在集群中正常工作的所有节点的地址。
- `client-urls`：通常监听的端口为`2379`（老版本使用的端口为`4001`），为适应复杂的网络环境，新版etcd监听客户端请求的url从原来的1个变为现在可配置的多个。这样etcd可以配合多块网卡同时监听不同网络下的请求。

#### 4.3 运行时节点变更

etcd集群启动完毕后，可以在运行的过程中对集群进行重构，包括核心节点的增加、删除、迁移、替换等。运行时重构使得etcd集群无须重启即可改变集群的配置，这也是新版etcd区别于旧版包含的新特性。

只有当集群中多数节点正常的情况下，你才可以进行运行时的配置管理。因为配置更改的信息也会被etcd当成一个信息存储和同步，如果集群多数节点损坏，集群就失去了写入数据的能力。所以在配置etcd集群数量时，强烈推荐至少配置3个核心节点。

##### 4.3.1. 节点迁移、替换

当你节点所在的机器出现硬件故障，或者节点出现如数据目录损坏等问题，导致节点永久性的不可恢复时，就需要对节点进行迁移或者替换。当一个节点失效以后，必须尽快修复，因为etcd集群正常运行的必要条件是集群中多数节点都正常工作。

迁移一个节点需要进行四步操作：

- 暂停正在运行着的节点程序进程
- 把数据目录从现有机器拷贝到新机器
- 使用api更新etcd中对应节点指向机器的url记录更新为新机器的ip
- 使用同样的配置项和数据目录，在新的机器上启动etcd。

##### 4.3.2. 节点增加

增加节点可以让etcd的高可用性更强。举例来说，如果你有3个节点，那么最多允许1个节点失效；当你有5个节点时，就可以允许有2个节点失效。同时，增加节点还可以让etcd集群具有更好的读性能。因为etcd的节点都是实时同步的，每个节点上都存储了所有的信息，所以增加节点可以从整体上提升读的吞吐量。

增加一个节点需要进行两步操作：

- 在集群中添加这个节点的url记录，同时获得集群的信息。
- 使用获得的集群信息启动新etcd节点。

##### 4.3.3. 节点移除

有时你不得不在提高etcd的写性能和增加集群高可用性上进行权衡。Leader节点在提交一个写记录时，会把这个消息同步到每个节点上，当得到多数节点的同意反馈后，才会真正写入数据。所以节点越多，写入性能越差。在节点过多时，你可能需要移除一个或多个。

移除节点非常简单，只需要一步操作，就是把集群中这个节点的记录删除。然后对应机器上的该节点就会自动停止。

##### 4.3.4. 强制性重启集群

当集群超过半数的节点都失效时，就需要通过手动的方式，强制性让某个节点以自己为Leader，利用原有数据启动一个新集群。

此时你需要进行两步操作。

- 备份原有数据到新机器。
- 使用`-force-new-cluster`加备份的数据重新启动节点

注意：强制性重启是一个迫不得已的选择，它会破坏一致性协议保证的安全性（如果操作时集群中尚有其它节点在正常工作，就会出错），所以在操作前请务必要保存好数据。

### 5 Proxy模式

Proxy模式也是新版etcd的一个重要变更，etcd作为一个反向代理把客户的请求转发给可用的etcd集群。这样，你就可以在每一台机器都部署一个Proxy模式的etcd作为本地服务，如果这些etcd Proxy都能正常运行，那么你的服务发现必然是稳定可靠的。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129011.jpg)

图11 Proxy模式示意图

所以Proxy并不是直接加入到符合强一致性的etcd集群中，也同样的，Proxy并没有增加集群的可靠性，当然也没有降低集群的写入性能。

#### 5.1 Proxy取代Standby模式的原因

那么，为什么要有Proxy模式而不是直接增加etcd核心节点呢？实际上etcd每增加一个核心节点（peer），都会增加Leader节点一定程度的包括网络、CPU和磁盘的负担，因为每次信息的变化都需要进行同步备份。增加etcd的核心节点可以让整个集群具有更高的可靠性，但是当数量达到一定程度以后，增加可靠性带来的好处就变得不那么明显，反倒是降低了集群写入同步的性能。因此，增加一个轻量级的Proxy模式etcd节点是对直接增加etcd核心节点的一个有效代替。

熟悉0.4.6这个旧版本etcd的用户会发现，Proxy模式实际上是取代了原先的Standby模式。Standby模式除了转发代理的功能以外，还会在核心节点因为故障导致数量不足的时候，从Standby模式转为正常节点模式。而当那个故障的节点恢复时，发现etcd的核心节点数量已经达到的预先设置的值，就会转为Standby模式。

但是新版etcd中，只会在最初启动etcd集群时，发现核心节点的数量已经满足要求时，自动启用Proxy模式，反之则并未实现。主要原因如下。

- etcd是用来保证高可用的组件，因此它所需要的系统资源（包括内存、硬盘和CPU等）都应该得到充分保障以保证高可用。任由集群的自动变换随意地改变核心节点，无法让机器保证性能。所以etcd官方鼓励大家在大型集群中为运行etcd准备专有机器集群。
- 因为etcd集群是支持高可用的，部分机器故障并不会导致功能失效。所以机器发生故障时，管理员有充分的时间对机器进行检查和修复。
- 自动转换使得etcd集群变得复杂，尤其是如今etcd支持多种网络环境的监听和交互。在不同网络间进行转换，更容易发生错误，导致集群不稳定。

基于上述原因，目前Proxy模式有转发代理功能，而不会进行角色转换。

#### 5.2 关键部分源码解析

从代码中可以看到，Proxy模式的本质就是起一个HTTP代理服务器，把客户发到这个服务器的请求转发给别的etcd节点。

etcd目前支持读写皆可和只读两种模式。默认情况下是读写皆可，就是把读、写两种请求都进行转发。而只读模式只转发读的请求，对所有其他请求返回501错误。

值得注意的是，除了启动过程中因为设置了`proxy`参数会作为Proxy模式启动。在etcd集群化启动时，节点注册自身的时候监测到集群的实际节点数量已经符合要求，那么就会退化为Proxy模式。

### 6 数据存储

etcd的存储分为内存存储和持久化（硬盘）存储两部分，内存中的存储除了顺序化的记录下所有用户对节点数据变更的记录外，还会对用户数据进行索引、建堆等方便查询的操作。而持久化则使用预写式日志（WAL：Write Ahead Log）进行记录存储。

在WAL的体系中，所有的数据在提交之前都会进行日志记录。在etcd的持久化存储目录中，有两个子目录。一个是WAL，存储着所有事务的变化记录；另一个则是snapshot，用于存储某一个时刻etcd所有目录的数据。通过WAL和snapshot相结合的方式，etcd可以有效的进行数据存储和节点故障恢复等操作。

既然有了WAL实时存储了所有的变更，为什么还需要snapshot呢？随着使用量的增加，WAL存储的数据会暴增，为了防止磁盘很快就爆满，etcd默认每10000条记录做一次snapshot，经过snapshot以后的WAL文件就可以删除。而通过API可以查询的历史etcd操作默认为1000条。

首次启动时，etcd会把启动的配置信息存储到`data-dir`参数指定的数据目录中。配置信息包括本地节点的ID、集群ID和初始时集群信息。用户需要避免etcd从一个过期的数据目录中重新启动，因为使用过期的数据目录启动的节点会与集群中的其他节点产生不一致（如：之前已经记录并同意Leader节点存储某个信息，重启后又向Leader节点申请这个信息）。所以，为了最大化集群的安全性，一旦有任何数据损坏或丢失的可能性，你就应该把这个节点从集群中移除，然后加入一个不带数据目录的新节点。

#### 6.1 预写式日志（WAL）

WAL（Write Ahead Log）最大的作用是记录了整个数据变化的全部历程。在etcd中，所有数据的修改在提交前，都要先写入到WAL中。使用WAL进行数据的存储使得etcd拥有两个重要功能。

- 故障快速恢复： 当你的数据遭到破坏时，就可以通过执行所有WAL中记录的修改操作，快速从最原始的数据恢复到数据损坏前的状态。
- 数据回滚（undo）/重做（redo）：因为所有的修改操作都被记录在WAL中，需要回滚或重做，只需要方向或正向执行日志中的操作即可。
- wal日志是二进制的，解析出来后是以上数据结构LogEntry。
  - 第一个字段type，主要有两种，一种是0表示Normal，1表示ConfChange（ConfChange表示 Etcd 本身的配置变更同步，比如有新的节点加入等）。
    第二个字段是term，每个term代表一个主节点的任期，每次主节点变更term就会变化。
    第三个字段是index，这个序号是严格有序递增的，代表变更序号。
    第四个字段是二进制的data，将raft request对象的pb结构整个保存下。etcd 源码下有个tools/etcd-
    dump-logs，可以将wal日志dump成文本查看，可以协助分析Raft协议。

#### WAL与snapshot在etcd中的命名规则

在etcd的数据目录中，WAL文件以`$seq-$index.wal`的格式存储。最初始的WAL文件是`0000000000000000-0000000000000000.wal`，表示是所有WAL文件中的第0个，初始的Raft状态编号为0。运行一段时间后可能需要进行日志切分，把新的条目放到一个新的WAL文件中。

假设，当集群运行到Raft状态为20时，需要进行WAL文件的切分时，下一份WAL文件就会变为`0000000000000001-0000000000000021.wal`。如果在10次操作后又进行了一次日志切分，那么后一次的WAL文件名会变为`0000000000000002-0000000000000031.wal`。可以看到`-`符号前面的数字是每次切分后自增1，而`-`符号后面的数字则是根据实际存储的Raft起始状态来定。

snapshot的存储命名则比较容易理解，以`$term-$index.wal`格式进行命名存储。term和index就表示存储snapshot时数据所在的raft节点状态，当前的任期编号以及数据项位置信息。

#### 6.2 关键部分源码解析

从代码逻辑中可以看到，WAL有两种模式，读模式（read）和数据添加（append）模式，两种模式不能同时成立。一个新创建的WAL文件处于append模式，并且不会进入到read模式。一个本来存在的WAL文件被打开的时候必然是read模式，并且只有在所有记录都被读完的时候，才能进入append模式，进入append模式后也不会再进入read模式。这样做有助于保证数据的完整与准确。

集群在进入到`etcdserver/server.go`的`NewServer`函数准备启动一个etcd节点时，会检测是否存在以前的遗留WAL数据。

检测的第一步是查看snapshot文件夹下是否有符合规范的文件，若检测到snapshot格式是v0.4的，则调用函数升级到v0.5。从snapshot中获得集群的配置信息，包括token、其他节点的信息等等，然后载入WAL目录的内容，从小到大进行排序。根据snapshot中得到的term和index，找到WAL紧接着snapshot下一条的记录，然后向后更新，直到所有WAL包的entry都已经遍历完毕，Entry记录到ents变量中存储在内存里。此时WAL就进入append模式，为数据项添加进行准备。

当WAL文件中数据项内容过大达到设定值（默认为10000）时，会进行WAL的切分，同时进行snapshot操作。这个过程可以在`etcdserver/server.go`的`snapshot`函数中看到。所以，实际上数据目录中有用的snapshot和WAL文件各只有一个，默认情况下etcd会各保留5个历史文件。

### 7 Raft

新版etcd中，raft包就是对Raft一致性算法的具体实现。关于Raft算法的讲解，网上已经有很多文章，有兴趣的读者可以去阅读一下[Raft算法论文](https://ramcloud.stanford.edu/raft.pdf)非常精彩。本文则不再对Raft算法进行详细描述，而是结合etcd，针对算法中一些关键内容以问答的形式进行讲解。有关Raft算法的术语如果不理解，可以参见概念词汇表一节。

#### 7.1 Raft常见问答一览

- Raft中一个Term（任期）是什么意思？ Raft算法中，从时间上，一个任期讲即从一次竞选开始到下一次竞选开始。从功能上讲，如果Follower接收不到Leader节点的心跳信息，就会结束当前任期，变为Candidate发起竞选，有助于Leader节点故障时集群的恢复。发起竞选投票时，任期值小的节点不会竞选成功。如果集群不出现故障，那么一个任期将无限延续下去。而投票出现冲突也有可能直接进入下一任再次竞选。

  ![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129012.jpg)

  图12 Term示意图

- Raft状态机是怎样切换的？ Raft刚开始运行时，节点默认进入Follower状态，等待Leader发来心跳信息。若等待超时，则状态由Follower切换到Candidate进入下一轮term发起竞选，等到收到集群多数节点的投票时，该节点转变为Leader。Leader节点有可能出现网络等故障，导致别的节点发起投票成为新term的Leader，此时原先的老Leader节点会切换为Follower。Candidate在等待其它节点投票的过程中如果发现别的节点已经竞选成功成为Leader了，也会切换为Follower节点。

  ![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129013.jpg)

  图13 Raft状态机

- 如何保证最短时间内竞选出Leader，防止竞选冲突？ 在Raft状态机一图中可以看到，在Candidate状态下， 有一个times out，这里的times out时间是个随机值，也就是说，每个机器成为Candidate以后，超时发起新一轮竞选的时间是各不相同的，这就会出现一个时间差。在时间差内，如果Candidate1收到的竞选信息比自己发起的竞选信息term值大（即对方为新一轮term），并且新一轮想要成为Leader的Candidate2包含了所有提交的数据，那么Candidate1就会投票给Candidate2。这样就保证了只有很小的概率会出现竞选冲突。

- 如何防止别的Candidate在遗漏部分数据的情况下发起投票成为Leader？ Raft竞选的机制中，使用随机值决定超时时间，第一个超时的节点就会提升term编号发起新一轮投票，一般情况下别的节点收到竞选通知就会投票。但是，如果发起竞选的节点在上一个term中保存的已提交数据不完整，节点就会拒绝投票给它。通过这种机制就可以防止遗漏数据的节点成为Leader。

- Raft某个节点宕机后会如何？ 通常情况下，如果是Follower节点宕机，如果剩余可用节点数量超过半数，集群可以几乎没有影响的正常工作。如果是Leader节点宕机，那么Follower就收不到心跳而超时，发起竞选获得投票，成为新一轮term的Leader，继续为集群提供服务。需要注意的是；etcd目前没有任何机制会自动去变化整个集群总共的节点数量，即如果没有人为的调用API，etcd宕机后的节点仍然被计算为总节点数中，任何请求被确认需要获得的投票数都是这个总数的半数以上。

  ![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129014.jpg)

  图14 节点宕机

- 为什么Raft算法在确定可用节点数量时不需要考虑拜占庭将军问题？ 拜占庭问题中提出，允许n个节点宕机还能提供正常服务的分布式架构，需要的总节点数量为3n+1，而Raft只需要2n+1就可以了。其主要原因在于，拜占庭将军问题中存在数据欺骗的现象，而etcd中假设所有的节点都是诚实的。etcd在竞选前需要告诉别的节点自身的term编号以及前一轮term最终结束时的index值，这些数据都是准确的，其他节点可以根据这些值决定是否投票。另外，etcd严格限制Leader到Follower这样的数据流向保证数据一致不会出错。

- 用户从集群中哪个节点读写数据？ Raft为了保证数据的强一致性，所有的数据流向都是一个方向，从Leader流向Follower，也就是所有Follower的数据必须与Leader保持一致，如果不一致会被覆盖。即所有用户更新数据的请求都最先由Leader获得，然后存下来通知其他节点也存下来，等到大多数节点反馈时再把数据提交。一个已提交的数据项才是Raft真正稳定存储下来的数据项，不再被修改，最后再把提交的数据同步给其他Follower。因为每个节点都有Raft已提交数据准确的备份（最坏的情况也只是已提交数据还未完全同步），所以读的请求任意一个节点都可以处理。

- etcd实现的Raft算法性能如何？ 单实例节点支持每秒1000次数据写入。节点越多，由于数据同步涉及到网络延迟，会根据实际情况越来越慢，而读性能会随之变强，因为每个节点都能处理用户请求。

#### 7.2 关键部分源码解析

在etcd代码中，Node作为Raft状态机的具体实现，是整个算法的关键，也是了解算法的入口。

在etcd中，对Raft算法的调用如下，你可以在`etcdserver/raft.go`中的`startNode`找到：

```
storage := raft.NewMemoryStorage()
n := raft.StartNode(0x01, []int64{0x02, 0x03}, 3, 1, storage)
```

通过这段代码可以了解到，Raft在运行过程记录数据和状态都是保存在内存中，而代码中`raft.StartNode`启动的Node就是Raft状态机Node。启动了一个Node节点后，Raft会做如下事项。

首先，你需要把从集群的其他机器上收到的信息推送到Node节点，你可以在`etcdserver/server.go`中的`Process`函数看到。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
func (s *EtcdServer) Process(ctx context.Context, m raftpb.Message) error {
    if m.Type == raftpb.MsgApp {
        s.stats.RecvAppendReq(types.ID(m.From).String(), m.Size())
    }
    return s.node.Step(ctx, m)
}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

在检测发来请求的机器是否是集群中的节点，自身节点是否是Follower，把发来请求的机器作为Leader，具体对Node节点信息的推送和处理则通过`node.Step()`函数实现。

其次，你需要把日志项存储起来，在你的应用中执行提交的日志项，然后把完成信号发送给集群中的其它节点，再通过`node.Ready()`监听等待下一次任务执行。有一点非常重要，你必须确保在你发送完成消息给其他节点之前，你的日志项内容已经确切稳定的存储下来了。

最后，你需要保持一个心跳信号`Tick()`。Raft有两个很重要的地方用到超时机制：心跳保持和Leader竞选。需要用户在其raft的Node节点上周期性的调用Tick()函数，以便为超时机制服务。

综上所述，整个raft节点的状态机循环类似如下所示：

```
for` `{``  ``select` `{``  ``case` `<-s.Ticker:``    ``n.Tick()``  ``case` `rd := <-s.Node.Ready():``    ``saveToStorage(rd.State, rd.Entries)``    ``send(rd.Messages)``    ``process(rd.CommittedEntries)``    ``s.Node.Advance()``  ``case` `<-s.done:``    ``return``  ``}``}
```

　　

而这个状态机真实存在的代码位置为`etcdserver/server.go`中的`run`函数。

对状态机进行状态变更（如用户数据更新等）则是调用`n.Propose(ctx, data)`函数，在存储数据时，会先进行序列化操作。获得大多数其他节点的确认后，数据会被提交，存为已提交状态。

之前提到etcd集群的启动需要借助别的etcd集群或者DNS，而启动完毕后这些`外力`就不需要了，etcd会把自身集群的信息作为状态存储起来。所以要变更自身集群节点数量实际上也需要像用户数据变更那样添加数据条目到Raft状态机中。这一切由`n.ProposeConfChange(ctx, cc)`实现。当集群配置信息变更的请求同样得到大多数节点的确认反馈后，再进行配置变更的正式操作，代码如下。

```
var` `cc raftpb.ConfChange``cc.Unmarshal(data)``n.ApplyConfChange(cc)
```

　　

注意：一个ID唯一性的表示了一个集群，所以为了避免不同etcd集群消息混乱，ID需要确保唯一性，不能重复使用旧的token数据作为ID。

### 8 Store

Store这个模块顾名思义，就像一个商店把etcd已经准备好的各项底层支持加工起来，为用户提供五花八门的API支持，处理用户的各项请求。要理解Store，只需要从etcd的API入手即可。打开[etcd的API列表](https://github.com/coreos/etcd/blob/master/Documentation/api.md)，我们可以看到有如下API是对etcd存储的键值进行的操作，亦即Store提供的内容。API中提到的目录（Directory）和键（Key），上文中也可能称为etcd节点（Node）。

- 为etcd存储的键赋值

  `curl http:``//127.0.0.1:2379/v2/keys/message -XPUT -d value="Hello world"``{``  ``"action"``: ``"set"``,``  ``"node"``: {``    ``"createdIndex"``: 2,``    ``"key"``: ``"/message"``,``    ``"modifiedIndex"``: 2,``    ``"value"``: ``"Hello world"``  ``}``}`

反馈的内容含义如下：

- action: 刚刚进行的动作名称。

- node.key: 请求的HTTP路径。etcd使用一个类似文件系统的方式来反映键值存储的内容。

- node.value: 刚刚请求的键所存储的内容。

- node.createdIndex: etcd节点每次有变化时都会自增的一个值，除了用户请求外，etcd内部运行（如启动、集群信息变化等）也会对节点有变动而引起这个值的变化。

- node.modifiedIndex: 类似node.createdIndex，能引起modifiedIndex变化的操作包括set, delete, update, create, compareAndSwap and compareAndDelete。

- 查询etcd某个键存储的值

  ```
  curl http://127.0.0.1:2379/v2/keys/message
  ```

- 修改键值：与创建新值几乎相同，但是反馈时会有一个

  ```
  prevNode
  ```

  值反应了修改前存储的内容。

  ```
  curl http://127.0.0.1:2379/v2/keys/message -XPUT -d value="Hello etcd"
  ```

- 删除一个值

  ```
  curl http://127.0.0.1:2379/v2/keys/message -XDELETE
  ```

- 对一个键进行定时删除：etcd中对键进行定时删除，设定一个TTL值，当这个值到期时键就会被删除。反馈的内容会给出expiration项告知超时时间，ttl项告知设定的时长。

  ```
  curl http://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -d ttl=5
  ```

- 取消定时删除任务

  ```
  curl http://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -d ttl= -d prevExist=true
  ```

- 对键值修改进行监控：etcd提供的这个API让用户可以监控一个值或者递归式的监控一个目录及其子目录的值，当目录或值发生变化时，etcd会主动通知。

  ```
  curl http://127.0.0.1:2379/v2/keys/foo?wait=true
  ```

- 对过去的键值操作进行查询：类似上面提到的监控，只不过监控时加上了过去某次修改的索引编号，就可以查询历史操作。默认可查询的历史记录为1000条。

  ```
  curl 'http://127.0.0.1:2379/v2/keys/foo?wait=true&waitIndex=7'
  ```

- 自动在目录下创建有序键。在对创建的目录使用

  ```
  POST
  ```

  参数，会自动在该目录下创建一个以createdIndex值为键的值，这样就相当于以创建时间先后严格排序了。这个API对分布式队列这类场景非常有用。

  [![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

  ```
  curl http://127.0.0.1:2379/v2/keys/queue -XPOST -d value=Job1
  {
      "action": "create",
      "node": {
          "createdIndex": 6,
          "key": "/queue/6",
          "modifiedIndex": 6,
          "value": "Job1"
      }
  }
  ```

  [![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

- 按顺序列出所有创建的有序键。

  ```
  curl -s 'http://127.0.0.1:2379/v2/keys/queue?recursive=true&sorted=true'
  ```

- 创建定时删除的目录：就跟定时删除某个键类似。如果目录因为超时被删除了，其下的所有内容也自动超时删除。

  ```
  curl http://127.0.0.1:2379/v2/keys/dir -XPUT -d ttl=30 -d dir=true
  ```

刷新超时时间。

```
 curl http://127.0.0.1:2379/v2/keys/dir -XPUT -d ttl=30 -d dir=true -d prevExist=true
```

- 自动化CAS（Compare-and-Swap）操作：etcd强一致性最直观的表现就是这个API，通过设定条件，阻止节点二次创建或修改。即用户的指令被执行当且仅当CAS的条件成立。条件有以下几个。
  - prevValue 先前节点的值，如果值与提供的值相同才允许操作。
  - prevIndex 先前节点的编号，编号与提供的校验编号相同才允许操作。
  - prevExist 先前节点是否存在。如果存在则不允许操作。这个常常被用于分布式锁的唯一获取。

假设先进行了如下操作：设定了foo的值。

```
curl http://127.0.0.1:2379/v2/keys/foo -XPUT -d value=one
```

然后再进行操作：

```
curl http://127.0.0.1:2379/v2/keys/foo?prevExist=false -XPUT -d value=three
```

就会返回创建失败的错误。

- 条件删除（Compare-and-Delete）：与CAS类似，条件成立后才能删除。

- 创建目录

  ```
  curl http://127.0.0.1:2379/v2/keys/dir -XPUT -d dir=true
  ```

- 列出目录下所有的节点信息，最后以

  ```
  /
  ```

  结尾。还可以通过recursive参数递归列出所有子目录信息。

  ```
  curl http://127.0.0.1:2379/v2/keys/
  ```

- 删除目录：默认情况下只允许删除空目录，如果要删除有内容的目录需要加上

  ```
  recursive=true
  ```

  参数。

  ```
  curl 'http://127.0.0.1:2379/v2/keys/foo_dir?dir=true' -XDELETE
  ```

- 创建一个隐藏节点：命名时名字以下划线

  ```
  _
  ```

  开头默认就是隐藏键。

  ```
  curl http://127.0.0.1:2379/v2/keys/_message -XPUT -d value="Hello hidden world"
  ```

相信看完这么多API，读者已经对Store的工作内容基本了解了。它对etcd下存储的数据进行加工，创建出如文件系统般的树状结构供用户快速查询。它有一个`Watcher`用于节点变更的实时反馈，还需要维护一个`WatcherHub`对所有`Watcher`订阅者进行通知的推送。同时，它还维护了一个由定时键构成的小顶堆，快速返回下一个要超时的键。最后，所有这些API的请求都以事件的形式存储在事件队列中等待处理。

# 应用场景

### 场景一：服务发现（Service Discovery）

服务发现要解决的也是分布式系统中最常见的问题之一，即在同一个分布式集群中的进程或服务，要如何才能找到对方并建立连接。本质上来说，服务发现就是想要了解集群中是否有进程在监听udp或tcp端口，并且通过名字就可以查找和连接。要解决服务发现的问题，需要有下面三大支柱，缺一不可。

1. 一个强一致性、高可用的服务存储目录。基于Raft算法的etcd天生就是这样一个强一致性高可用的服务存储目录。
2. 一种注册服务和监控服务健康状态的机制。用户可以在etcd中注册服务，并且对注册的服务设置`key TTL`，定时保持服务的心跳以达到监控健康状态的效果。
3. 一种查找和连接服务的机制。通过在etcd指定的主题下注册的服务也能在对应的主题下查找到。为了确保连接，我们可以在每个服务机器上都部署一个Proxy模式的etcd，这样就可以确保能访问etcd集群的服务都能互相连接。

### 场景二：消息发布与订阅

在分布式系统中，最适用的一种组件间通信方式就是消息发布与订阅。即构建一个配置共享中心，数据提供者在这个配置中心发布消息，而消息使用者则订阅他们关心的主题，一旦主题有消息发布，就会实时通知订阅者。通过这种方式可以做到分布式系统配置的集中式管理与动态更新。

- 应用中用到的一些配置信息放到etcd上进行集中管理。这类场景的使用方式通常是这样：应用在启动的时候主动从etcd获取一次配置信息，同时，在etcd节点上注册一个Watcher并等待，以后每次配置有更新的时候，etcd都会实时通知订阅者，以此达到获取最新配置信息的目的。
- 分布式搜索服务中，索引的元信息和服务器集群机器的节点状态存放在etcd中，供各个客户端订阅使用。使用etcd的`key TTL`功能可以确保机器状态是实时更新的。
- 分布式日志收集系统。这个系统的核心工作是收集分布在不同机器的日志。收集器通常是按照应用（或主题）来分配收集任务单元，因此可以在etcd上创建一个以应用（主题）命名的目录P，并将这个应用（主题相关）的所有机器ip，以子目录的形式存储到目录P上，然后设置一个etcd递归的Watcher，递归式的监控应用（主题）目录下所有信息的变动。这样就实现了机器IP（消息）变动的时候，能够实时通知到收集器调整任务分配。
- 系统中信息需要动态自动获取与人工干预修改信息请求内容的情况。通常是暴露出接口，例如JMX接口，来获取一些运行时的信息。引入etcd之后，就不用自己实现一套方案了，只要将这些信息存放到指定的etcd目录中即可，etcd的这些目录就可以通过HTTP的接口在外部访问。



### 场景三：负载均衡

在`场景一`中也提到了负载均衡，本文所指的负载均衡均为软负载均衡。分布式系统中，为了保证服务的高可用以及数据的一致性，通常都会把数据和服务部署多份，以此达到对等服务，即使其中的某一个服务失效了，也不影响使用。由此带来的坏处是数据写入性能下降，而好处则是数据访问时的负载均衡。因为每个对等服务节点上都存有完整的数据，所以用户的访问流量就可以分流到不同的机器上。

- etcd本身分布式架构存储的信息访问支持负载均衡。etcd集群化以后，每个etcd的核心节点都可以处理用户的请求。所以，把数据量小但是访问频繁的消息数据直接存储到etcd中也是个不错的选择，如业务系统中常用的二级代码表（在表中存储代码，在etcd中存储代码所代表的具体含义，业务系统调用查表的过程，就需要查找表中代码的含义）。
- 利用etcd维护一个负载均衡节点表。etcd可以监控一个集群中多个节点的状态，当有一个请求发过来后，可以轮询式的把请求转发给存活着的多个状态。类似KafkaMQ，通过ZooKeeper来维护生产者和消费者的负载均衡。同样也可以用etcd来做ZooKeeper的工作。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129005.jpg)

图5 负载均衡

### 场景四：分布式通知与协调

这里说到的分布式通知与协调，与消息发布和订阅有些相似。都用到了etcd中的Watcher机制，通过注册与异步通知机制，实现分布式环境下不同系统之间的通知与协调，从而对数据变更做到实时处理。实现方式通常是这样：不同系统都在etcd上对同一个目录进行注册，同时设置Watcher观测该目录的变化（如果对子目录的变化也有需要，可以设置递归模式），当某个系统更新了etcd的目录，那么设置了Watcher的系统就会收到通知，并作出相应处理。

- 通过etcd进行低耦合的心跳检测。检测系统和被检测系统通过etcd上某个目录关联而非直接关联起来，这样可以大大减少系统的耦合性。
- 通过etcd完成系统调度。某系统有控制台和推送系统两部分组成，控制台的职责是控制推送系统进行相应的推送工作。管理人员在控制台作的一些操作，实际上是修改了etcd上某些目录节点的状态，而etcd就把这些变化通知给注册了Watcher的推送系统客户端，推送系统再作出相应的推送任务。
- 通过etcd完成工作汇报。大部分类似的任务分发系统，子任务启动后，到etcd来注册一个临时工作目录，并且定时将自己的进度进行汇报（将进度写入到这个临时目录），这样任务管理者就能够实时知道任务进度。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129006.jpg)

图6 分布式协同工作

### 场景五：分布式锁

因为etcd使用Raft算法保持了数据的强一致性，某次操作存储到集群中的值必然是全局一致的，所以很容易实现分布式锁。锁服务有两种使用方式，一是保持独占，二是控制时序。

- 保持独占即所有获取锁的用户最终只有一个可以得到。etcd为此提供了一套实现分布式锁原子操作CAS（`CompareAndSwap`）的API。通过设置`prevExist`值，可以保证在多个节点同时去创建某个目录时，只有一个成功。而创建成功的用户就可以认为是获得了锁。
- 控制时序，即所有想要获得锁的用户都会被安排执行，但是获得锁的顺序也是全局唯一的，同时决定了执行顺序。etcd为此也提供了一套API（自动创建有序键），对一个目录建值时指定为`POST`动作，这样etcd会自动在目录下生成一个当前最大的值为键，存储这个新的值（客户端编号）。同时还可以使用API按顺序列出所有当前目录下的键值。此时这些键的值就是客户端的时序，而这些键中存储的值可以是代表客户端的编号。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0130000.jpg)

图7 分布式锁

### 场景六：分布式队列

分布式队列的常规用法与场景五中所描述的分布式锁的控制时序用法类似，即创建一个先进先出的队列，保证顺序。

另一种比较有意思的实现是在保证队列达到某个条件时再统一按顺序执行。这种方法的实现可以在/queue这个目录中另外建立一个/queue/condition节点。

- condition可以表示队列大小。比如一个大的任务需要很多小任务就绪的情况下才能执行，每次有一个小任务就绪，就给这个condition数字加1，直到达到大任务规定的数字，再开始执行队列里的一系列小任务，最终执行大任务。
- condition可以表示某个任务在不在队列。这个任务可以是所有排序任务的首个执行程序，也可以是拓扑结构中没有依赖的点。通常，必须执行这些任务后才能执行队列中的其他任务。
- condition还可以表示其它的一类开始执行任务的通知。可以由控制程序指定，当condition出现变化时，开始执行队列任务。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129008.jpg)

图8 分布式队列

### 场景七：集群监控与Leader竞选

通过etcd来进行监控实现起来非常简单并且实时性强。

1. 前面几个场景已经提到Watcher机制，当某个节点消失或有变动时，Watcher会第一时间发现并告知用户。
2. 节点可以设置`TTL key`，比如每隔30s发送一次心跳使代表该机器存活的节点继续存在，否则节点消失。

这样就可以第一时间检测到各节点的健康状态，以完成集群的监控要求。

另外，使用分布式锁，可以完成Leader竞选。这种场景通常是一些长时间CPU计算或者使用IO操作的机器，只需要竞选出的Leader计算或处理一次，就可以把结果复制给其他的Follower。从而避免重复劳动，节省计算资源。

这个的经典场景是搜索系统中建立全量索引。如果每个机器都进行一遍索引的建立，不但耗时而且建立索引的一致性不能保证。通过在etcd的CAS机制同时创建一个节点，创建成功的机器作为Leader，进行索引计算，然后把计算结果分发到其它节点。

![img](http://cdn4.infoqstatic.com/statics_s2_20170829-0315/resource/articles/etcd-interpretation-application-scenario-implement-principle/zh/resources/0129009.jpg)

图9 Leader竞选

### 场景八：为什么用etcd而不用ZooKeeper？

阅读了[“ZooKeeper典型应用场景一览”](http://jm-blog.aliapp.com/?p=1232)一文的读者可能会发现，etcd实现的这些功能，ZooKeeper都能实现。那么为什么要用etcd而非直接使用ZooKeeper呢？

相较之下，ZooKeeper有如下缺点：

1. 复杂。ZooKeeper的部署维护复杂，管理员需要掌握一系列的知识和技能；而Paxos强一致性算法也是素来以复杂难懂而闻名于世；另外，ZooKeeper的使用也比较复杂，需要安装客户端，官方只提供了Java和C两种语言的接口。
2. Java编写。这里不是对Java有偏见，而是Java本身就偏向于重型应用，它会引入大量的依赖。而运维人员则普遍希望保持强一致、高可用的机器集群尽可能简单，维护起来也不易出错。
3. 发展缓慢。Apache基金会项目特有的[“Apache Way”](http://www.infoworld.com/article/2612082/open-source-software/has-apache-lost-its-way-.html)在开源界饱受争议，其中一大原因就是由于基金会庞大的结构以及松散的管理导致项目发展缓慢。

而etcd作为一个后起之秀，其优点也很明显。

1. 简单。使用Go语言编写部署简单；使用HTTP作为接口使用简单；使用Raft算法保证强一致性让用户易于理解。
2. 数据持久化。etcd默认数据一更新就进行持久化。
3. 安全。etcd支持SSL客户端安全认证。

最后，etcd作为一个年轻的项目，真正告诉迭代和开发中，这既是一个优点，也是一个缺点。优点是它的未来具有无限的可能性，缺点是无法得到大项目长时间使用的检验。然而，目前CoreOS、Kubernetes和CloudFoundry等知名项目均在生产环境中使用了etcd，所以总的来说，etcd值得你去尝试。

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



其他参考

- https://ms2008.github.io/2019/12/04/etcd-rumor/
- ReadIndex：https://zhuanlan.zhihu.com/p/31050303
- LeaseRead：https://zhuanlan.zhihu.com/p/31118381
- 线性一致读：https://zhengyinyong.com/post/etcd-linearizable-read-implementation/
- https://juejin.im/post/5d843b995188257e8e46e25d
- https://skyao.io/learning-etcd3/documentation/op-guide/gateway.html
- https://github.com/etcd-io/etcd/issues/7522
- https://github.com/etcd-io/etcd/blob/master/Documentation/learning/design-learner.md
- [etcd 问题、调优、监控](http://www.xuyasong.com/?p=1983)
- [etcd：从应用场景到实现原理的全方位解读](https://www.cnblogs.com/datacoding/p/7473953.html)