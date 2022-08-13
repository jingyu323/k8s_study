# 关键组件
# k8s架构

![](images\k8s_arc.png)

**1）Master**

K8S中的Master是集群控制节点，负责整个集群的管理和控制

在Master上运行着以下关键进程：

kube-apiserver：提供了HTTP Rest接口的关键服务进程，是K8S里所有资源的增删改查等操作的唯一入口，也是集群控制的入口进程
kube-controller-manager：K8S里所有资源对象的自动化控制中心，集群内各种资源Controller的核心管理者，针对每一种资源都有相应的Controller，保证其下管理的每个Controller所对应的资源始终处于期望状态
kube-scheduler：负责资源调度（Pod调度）的进程，通过API Server的Watch接口监听新建Pod副本信息，并通过调度算法为该Pod选择一个最合适的Node
etcd：K8S里的所有资源对象以及状态的数据都被保存在etcd中
**2）Node**

Node是K8S集群中的工作负载节点，每个Node都会被Master分配一些工作负载，当某个Node宕机时，其上的工作负载会被Master自动转移到其他节点上

在每个Node上都运行着以下关键进程：

kubelet：负责Pod对应的容器的创建、启停等任务，同时与Master密切协作，实现集群管理的基本功能
kube-proxy：实现Kubernetes Service的通信与负载均衡机制的重要组件
Docker Engine：Docker引擎，负责本机的容器创建和管理工作
在默认情况下Kubelet会向Master注册自己，一旦Node被纳入集群管理范围，kubelet进程就会定时向Master汇报自身的信息（例如机器的CPU和内存情况以及有哪些Pod在运行等），这样Master就可以获知每个Node的资源使用情况，并实现高效均衡的资源调度策略。而某个Node在超过指定时间不上报信息时，会被Master判定为失败，Node的状态被标记为不可用，随后Master会触发工作负载转移的自动流程

# API Server

- 是集群管理的API入口。
- 是资源配额控制的入口。
- 提供了完备的集群安全机制



##  Pod

Pod可以有一个或者多个容器

## 	静态Pod

​		仅存在于特定节点上的Pod，不能通过API Server 进行管理。

- ​	创建静态Pod 有两种方式：配置文件和Http方式	

  ## ConfigMap

使用ConfigMap的限制条件：

1. 必须再Pod 之前创建

2. 只有处于相同Namespace的才能用

3. > 配额管理未能实现? 1.24.3 ***也没有实现吗？还是废弃了***

4. kubelet 只支持可以被API server管理的Pod使用ConfigMap，静态Pod不支持使用

5. POd对ConfigMap进行挂载的时候只能挂载为目录，如果有相同的目录，则已有的目录被ConfigMap的目录覆盖。解决这种问题需要先挂载到临时目录，然后通过cp或者link的方式应用的实际配置目录下

   ## Downward API

容器内部获取Pod信息

Pod注入信息到容器的方式：

1. 环境变量，单个变量的注入
2. volume 挂载：将组类信息生成文件并挂载到容器内部。

价值：

实现节点自动发现。

##     健康检查

1. LIvenessProbe 探针：判断容器是否存活，如果容器不包含Liveness Probe 探针，那么kubelet认为该容器LivenessProbe探针返回的永远是Success

2. ReadinessProbe探针：判断容器的服务是否可用

   LivenessPro和ReadinessPro均可以用如下方式实现：

   配置方式：

   1. ExecAction:在容器内部执行一个命令如果返回码为0则表明容器健康
   2. TCPSocketAction: 通过容器地址内的和端口号执行tcp检查
   3. HttpGetAction:通过探测容器的IP地址端口以及请求路径，如果返回值为200-400之间则认为容器健康

   ## Pod调度

   1.9之后RC被删除之后Pod副本一并会被删除，如果需要取消：

   ```
   --casecade=false
   ```

   调度方式：

   1. Deployment或者RC 全自动调度

   2. NodeSelector:定向调度

      通过在节点上打标签的方式，创建Pod的时候指定nodeSelector

   3. Node亲和性调度
      1. requiredDuringSchedulingIgnoredDuringExecution 相当于nodeSelector定向调度，硬限制
      2. preferredDuringSchedulingIgnoredDuringExecution:软限制尝试调度pod到node上。还可以设置多个软限制并定义权重以实现执行的先后顺序。IgnoredDuringExecution为如果pod在运行期间node的属性发生了变更，则系统会忽略变更，该pod可以继续在该节点运行

   4. Pod 亲和度调度和互斥策略

   5. 容忍和污点：Taints及Tolerations

      1.**添加污点** 为k8s-node02添加污点，污点程度为`NoSchedule`，`type=calculate`为标签
      
      ```text
      kubectl taint node k8s-node02 type=calculate:NoSchedule
      ```
      
      **2.查看污点**
      
      ```text
       kubectl describe nodes k8s-node02 | grep Taints
      ```
      
      
      
      https://blog.csdn.net/qq_34857250/article/details/90259693

   ### kube-scheduler 创建流程

   ​	![](images/20201223103750490.png)

   

   

   1. 用户提交pod请求：用户提交创建Pod的请求，可以通过API Server的REST API ，也可用Kubectl命令行工具，支持Json和Yaml两种格式；

   2. API Server 处理请求：API Server 处理用户请求，存储Pod数据到Etcd；

   3. Schedule调度pod：Schedule通过和 API Server的watch机制，查看到新的pod，按照预定的调度策略将Pod调度到相应的Node节点上；

                        1）过滤主机：调度器用一组规则过滤掉不符合要求的主机，比如Pod指定了所需要的资源，那么就要过滤掉资源不够的主机；

                       2）主机打分：对第一步筛选出的符合要求的主机进行打分，在主机打分阶段，调度器会考虑一些整体优化策略，比如把一个Replication Controller的副本分布到不同的主机上，使用最低负载的主机等；

                       3）选择主机：选择打分最高的主机，进行binding操作，结果存储到Etcd中；

   4. kubelet创建pod:  kubelet根据Schedule调度结果执行Pod创建操作: 调度成功后，会启动container, docker run, scheduler会调用API Server的API在etcd中创建一个bound pod对象，描述在一个工作节点上绑定运行的所有pod信息。运行在每个工作节点上的kubelet也会定期与etcd同步bound pod信息，一旦发现应该在该工作节点上运行的bound pod对象没有更新，则调用Docker API创建并启动pod内的容器。

   #### 选择node机制

   1. 过滤（Predicates 预选策略）

      	过滤阶段会将所有满足 Pod 调度需求的 Node 选出来。

   2. 打分（Priorities 优选策略）

      ​	在过滤阶段后调度器会为 Pod 从所有可调度节点中选取一个最合适的 Node。根据当前启用的打分规则，调度器会给每一个可调度节点进行打分


​    

# Pod升级回退

Pod如果是通过Deployment 创建的，则升级回退就是要使用Deployment的升级回退策略

##  Deployment  

1. 只能管理无状态应用, 总结k8s中的Pod、ReplicaSet、Deployment之间的管理关系，自顶到下为：Deployment=>ReplicaSet=>Pod。

   ### Deployment更新方式

   1. kubectl set image

   ```
   kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1 --record
   ```

   2. kubectl edit deployment 直接修改镜像

   3. \# 扩容    kubectl scale deployment nginx-deployment --replicas=5

   4.   缩容   kubectl scale --current-replicas=5 --replicas=3 deployment nginx-deployment

   5.   \# 删除deployment资源(基于yaml)    kubectl delete -f nginx.yml

   6. ```
      查看历史deployment
      kubectl rollout history deployment nginx-deployment   
       kubectl rollout status deployment nginx-deployment
      ```

   7.  \# 通过--to-revision指定回滚到特定的修订如：--to-revision=2    kubectl rollout undo deployment nginx-deployment

   ### Deployment更新策略

   1. Recreate
   2. RollingUpdate：滚动更新，为默认方式

   

   ### DaemonSet更新策略

   1. OnDelete：新的Daemonset配置创建之后并不立即创建新的Pod，只有在手动删除旧的之后才创建

   2. RollingUpdate：

      注意：

      1.不支持查看和管理Daemonset的更新历史记录

      2.不能直接通过 使用kubectl rollback来实现，需要提供旧版本的配置文件

   ### StatefuleSet

   - 创建StorageClass，用于StatefulSet自动为各个应用申请PVC
   - 创建一个Headlesse Service用户维护Mongo DB的集群状态
   - 创建一个StatefulSet









##  service 
解决的是容器负载的问题。service的引入旨在保证pod的动态变化对访问端透明，访问端只需要知道service的地址，由service来提供代理**解决的是**： 

 服务发现（防止pod 失联）防止Pod失联；定义一组Pod的访问策略

负载均衡（轮询转发请求到后端集群中的pod

1. 可以这么理解？ 
    service 对一组具有相同功能的***容器***  应用提供一个统一的入口。并且将请求负载分发到后端的各个容器应用上

    如果两个tomcat pod 对外提供服务，由于POD随时可漂移性IP访问方式并不可靠，所以需要做一个前端做一个负载均衡转发

    - Service 的类型：

2.  服务创建命令

    1.  创建应用 kubectl create -f webapp-rc.yaml，创建应用副本

    2. kubectl expose rc "webapp"  ,创建服务之后，使用命令 kubectl get svc  查看，可以看到已经分配好了cluster IP 

        ```go
        kubectl  expose  --help
        
        kubectl     expose     deployment 　　　　　 nginx-dep1   --port=2022         --target-port=80  　　--type=NodePort 　　　　　　　　-n kzf
        
                   　　　　     service代理资源类型    资源名称　　　代理对外端口　         pod 中内部端口　　　   端口暴露类型（默认ClusterIp）　　 命名空间
        ```

        方式二 创建yaml

        ```yaml
        apiVersion: v1
        kind: Service
        metadata:
          name: service-kzf1
          namespace: asdf
        spec:
          clusterIP: NodePort　　　　　　　　　　　　#不写默认类型为Clusterip
          ports:
          - port: 2021　　　　　　　　　　　　　　　　 #clusterip 集群端口
            targetPort: 80　　　　　　　　　　　　　　#pod 内部端口
          selector:
            app: nginx-label　　　　　　　　　　　　　#通过标签选择pod
        ```
    
    3. Service的访问被分发到了后端的Pod上去 负载分发策略
    
    4. **负载分发策略：**
    
        4. roundRobin 轮询模式
        2.  SessionAffinity  基于客户端IP保持会话模式，如果是相同客户端的请求会被转发到同一个Pod上
    
4. 外部服务
   1. 先创建一个无Label Slector Service,  无法选则后端Pod
   2. 手动创建与Service同名称的Endpoint

5. Headless Service 作用是不使用 Kubernetes 默认的负载均衡策略 ，clusterIP 设置为None

6. Cassadnra 根据Service 自动实现查找pod

7. 从集群外部访问Pod或者Service，Pod和Service都是Kubernetes的虚拟概念不能对外提供服务

   1. 将容器的Port映射到宿主机上

      ```yaml
      ports:
      - containerPort: 8080
       hostPort: 8081
      ```

   2.  将Service的Port映射到宿主机上，同时service type设置为nodePort

      ```yaml
      spec:
       type: NodePort
       ports:
       - port: 8080
         targetPort: 8080
         nodePort: 8081
      ```

8. 最佳实践
   
- 创建完成deployment之后，直接expose生成service，减少手动配置
  
9. service 的三种形式
   1. ClusterIP　 **集群IP，仅供k8s内部访问(只能在pod 或node 上访问，无法外部访问)，相当于service 加了1个vip，通过vip 提供访问地址，再转发给各个Pod**
   2. NodePort　　在每个node 节点为相应Pod启动一个对外端口（默认30000起步），映射pod 内部端口。通过任意一个Pod 所在的节点ip+port 就能访问pod ，多个pod 需要在service 前面加一个LB（lvs/proxy）把每个节点的ip+port 加入，才能实现负载均衡,这样每个服务都得添加一次，增加了管理维护成本
   3. Loadblance   云服务厂商提供的，自动添加service 映射对外端口到负载上面，例如阿里云可以通过SLB为service 提供负载均衡。只有云服务厂商的k8s 才有此形式
   
   
   
   #### EndPoint
   
   Endpoint是可被访问的服务端点，即一个状态为running的pod，它是service访问的落点，只有service关联的pod才可能成为endpoint。
   Endpoint、service和pod的关系：
   
   ![](images\endpoint.png)
   
   
   
   ## 将服务暴露给外部客户端

#### 方式一：NodePort

将服务的类型设置成NodePort每个集群节点都会在节点上打开 一个端口， 对于NodePort服务， 每个集群节点在节点本身（因此得名叫NodePort)上打开一个端口，并将在该端口上接收到的流量重定向到基础服务。该服务仅在内部集群 IP 和端口上才可访间， 但也可通过任意一个节点上的专用端口访问。因为nodeport 是clusterip 的拓展，所以此类型既可以通过clusterip 在集群内部访问也可以通过node-IP：port 在外部访问

#### 方式二：LoadBalance

将服务的类型设置成LoadBalance, NodePort类型的一 种扩展一这使得服务可以通过一个专用的负载均衡器来访问， 这是由Kubernetes中正在运行的云基础设施提供的。 负载均衡器将流量重定向到跨所有节点的节点端口。客户端通过负载均衡器的 IP 连接到服务。

#### 方式三：Ingress

创建一 个Ingress资源， 这是一 个完全不同的机制， 通过一 个IP地址公开多个服务——它运行在 HTTP 层（网络协议第7 层）上， 因此可以提供比工作在第4层的服务更多的功能。



## service 负载功能实现原理

service 负载均衡实现主要有两种方式

#### iptables(早期)

iptables 是一个工具它通过linux 的netfilter 来进行ip 包的过滤处理。主要通过维护一张规则表，从上到下匹配表中规则，每次变动都不是增量而是全表变动。随着表的增大效率降低。

#### 缺点：

宿主机上有大量 Pod 的时候，成百上千条 iptables 规则不断地被刷新，会大量占用该宿主机的 CPU 资源，甚至会让宿主机“卡”在这个过程中。所以说，一直以来，基于 iptables 的 Service 实现，都是制约 Kubernetes 项目承载更多量级的 Pod 的主要障碍 

#### ipvs(k8s version:1.11以后)

ipvs实际上就是lvs 的原理。采用它的轮询策略（w,rr/wrr.lc,wlc），内核级别的，效率高。

原理：

IPVS 模式的工作原理，其实跟 iptables 模式类似。当我们创建了前面的 Service 之后，kube-proxy 首先会在宿主机上创建一个虚拟网卡（叫作：kube-ipvs0），并为它分配 Service VIP 作为 IP 地址，如下所示：

```
# ip addr
  ...
  73：kube-ipvs0：<BROADCAST,NOARP>  mtu 1500 qdisc noop state DOWN qlen 1000
  link/ether  1a:ce:f5:5f:c1:4d brd ff:ff:ff:ff:ff:ff
  inet 10.0.1.175/32  scope global kube-ipvs0
  valid_lft forever  preferred_lft forever
```

而接下来，kube-proxy 就会通过 Linux 的 IPVS 模块，为这个 IP 地址设置三个 IPVS 虚拟主机，并设置这三个虚拟主机之间使用轮询模式 (rr) 来作为负载均衡策略。我们可以通过 ipvsadm 查看到这个设置，如下所示

```
# ipvsadm -ln
 IP Virtual Server version 1.2.1 (size=4096)
  Prot LocalAddress:Port Scheduler Flags
    ->  RemoteAddress:Port           Forward  Weight ActiveConn InActConn     
  TCP  10.102.128.4:80 rr
    ->  10.244.3.6:9376    Masq    1       0          0         
    ->  10.244.1.7:9376    Masq    1       0          0
    ->  10.244.2.3:9376    Masq    1       0          0
```

这三个 IPVS 虚拟主机的 IP 地址和端口，对应的正是三个被代理的 Pod。

这时候，任何发往 10.102.128.4:80 的请求，就都会被 IPVS 模块转发到某一个后端 Pod 上了。

而相比于 iptables，IPVS 在内核中的实现其实也是基于 Netfilter 的 NAT 模式，所以在转发这一层上，理论上 IPVS 并没有显著的性能提升。但是，IPVS 并不需要在宿主机上为每个 Pod 设置 iptables 规则，而是把对这些“规则”的处理放到了内核态，从而极大地降低了维护这些规则的代价。这也正印证了我在前面提到过的，“将重要操作放入内核态”是提高性能的重要手段。

不过需要注意的是，IPVS 模块只负责上述的负载均衡和代理功能。而一个完整的 Service 流程正常工作所需要的包过滤、SNAT 等操作，还是要靠 iptables 来实现。只不过，这些辅助性的 iptables 规则数量有限，也不会随着 Pod 数量的增加而增加。 



# CoreDns

### 1.作用 集群内部需要通过服务名称对服务进行访问，就需要一个域名和IP的解析

### 2.Pod 如何知道 DNS服务器地址

kubelet会将DNS Server 的 IP地址写到容器的/etc/resolv.conf文件中

具体来说

集群内 DNS 服务启动后，会获得 Cluster IP (就是Service 的IP，但只能在集群内使用)
系统（安装程序）会给kubelet配置 --cluster-dns=<dns service ip>
该 DNS IP 则会在容器启动时传递，写入到每个容器的 /etc/resolv.conf文件中 

### DNS域名解析原理

对于 Service，K8s DNS服务器会生成三类 DNS 记录，分别是 A 记录、 SRV 记录、 CNAME 记录

#### A记录

- 用于将域或子域指向某个IP地址，是DNS记录的最基本类型
- 记录包含域名，解析它的IP地址和以秒为单位的TTL，TTL代表生存时间，是此记录的到期时间
- 普通Service的A记录的映射关系
  - {service name}.{service namespace}.svc.{domin} --> Cluster IP
- headless Service 的 A 记录映射关系：
  - {service name}.{service namespace}.svc.{domin} --> 后端Pod IP 列表
- 如果 Pod Spec 指定 hostname 和 subdomin，那么会额外生成 Pod 的 A 记录
  - 
    如果 Pod Spec 指定 hostname 和 subdomin，那么会额外生成 Pod 的 A 记录
    {hostname}.{subdomain}.{pod namespace}.pod.cluster.local --> Pod IP

#### SRV 记录

通过描述某些服务协议和地址促进服务发现
定义一个符号名称和作为域名一部分的传输协议，并定义给定服务的优先级、权重、端口和目标
_sip._tcp.example.com.   3600 IN   SRV 10   70   5060 srvrecord.example.com
_sip._tcp.example.com.   3600 IN   SRV 10   20   5060 srvrecord2.ex

_sip 是服务的符号名称
_tcp 是服务使用的传输协议
两个记录都定义了10的优先级
第一个指定权重70，第二个指定权重20
最后两值定义了要连接的端口和主机名，以便与服务通信

 ```
_sip._tcp.example.com.   3600 IN   SRV 10   70   5060 srvrecord.example.com
_sip._tcp.example.com.   3600 IN   SRV 10   20   5060 srvrecord2.ex

_sip 是服务的符号名称
_tcp 是服务使用的传输协议
两个记录都定义了10的优先级
第一个指定权重70，第二个指定权重20
最后两值定义了要连接的端口和主机名，以便与服务通信
 ```

- k8s DNS 的 SRV 记录按照一个约定出城的规定实现了对服务端口的查询
  _{port name}._{port protocol}.{service name}.{service namespace}.svc.cluster.local --> Service Port
  SRV 记录是为 普通 或 headless 服务的部分指定端口创建的
  普通服务
  被解析的端口号和域名是 my-svc.my-namespace.svc.cluster.local
  Headless 服务
  此 name 解析为多个 answer，每个 answer 都支持服务
  每个 answer 都包含 auto-generated-name.my-svc.my-namespace.svc.cluster.local 表单的 Pod 端口号和域名

#### CNAME 记录

别名
用于将域或子域指向另一个主机名
可用于联合服务的跨集群服务发现 

# Ingress

 用于将不同的URL 访问转发到后端不同的Service，解决的是外部客户端访问一组服务的问题。

ngress相当于一个7层的负载均衡器，是Kubernetes对反向代理的一个抽象，它的工作原理类似于Nginx，可以理解成在Ingress里建立诸多映射规则，Ingress Controller通过监听这些配置规则并转化成Nginx的反向代理配置 , 然后对外部提供服务。在这里有两个核心概念：

Ingress：Kubernetes中的一个对象，作用是定义请求如何转发到Service的规则
Ingress Controller：具体实现反向代理及负载均衡的程序，对Ingress定义的规则进行解析，根据配置的规则来实现请求转发，实现方式有很多，比如Nginx、Haproxy 

​	1.使用Ingress ,需要创建Ingress controller，backend服务，Ingress 策略。创建Ingress 需要保证后端的服务已经创建完成否则会报错。

- ​	创建Ingress Controller，以Pod形式运行，监控Api Serverd的ingress接口后端的backend Service，如果service 有变化，则Ingress Controller自动更新其转发规则。
- 第一步：创建backend 服务，先创建默认
- 第二步：创建 Ingress Controller
- 第三步：定义转发策略

2. Ingress Controller 基于Ingress 转发规则将客户端 直接转发到service对应的后端Endpoint上，会跳过kube-proxy的转发功能，导致kube-proxy不再起作用。

3. Ingress 转发策略
   1. 单个后端服务
   2. 同一域名不同Url转发到不同的服务上
   3. 不同域名的服务转发到不同的服务上
   4. 不使用域名转发规则，用于一个网站不使用域名直接提供服务的场景。
      1. 默认开启https，需要修改INgress annotation，关闭默认转发
   
   总结各方式利弊
   hostPort和hostNetwork直接使用节点网络**，部署时节点需固定**，访问ip也固定(也可以用host)，端口为正常端口
   
   nodeport方式部署时不要求固定节点，可通过集群内任一ip进行访问，就是端口为30000以上，很多时候由于公司安全策略导致不能访问。
   
   LoadBalancer依赖于**云服务商提供的LoadBalancer**的实现机制。
   
   ingress需要额外安装**ingress模块**，配置路由规则，且仅能通过所配置域名访问，配置好域名后，可以直接对外提供服务，和传统的nginx作用类似

# 集群安全机制





# Kubernetes 的安全机制 APIServer 认证、授权、准入控制

Kubernetes安全
安全永远是一个重大的话题，特别是云计算平台，更需要设计出一套完善的安全方案，以应对复杂的场景。 Kubernetes主要使用Docker作为应用承载环境，Kubernetes首先设计出一套API和敏感信息处理方案，当然也基于Docker提供容器安全控制。以下是Kubernetes的安全设计原则：

1. 保证容器与其运行的宿主机之间有明确的隔离
2. 限制容器对基础设施或者其它容器造成不良影响的能力
3. 最小特权原则——限定每个组件只被赋予了执行操作所必需的最小特权，由此确保可能产生的损失达到最小
4. 允许系统用户明确区别于管理员
5. 允许赋予管理权限给用户
6. 允许应用能够从公开数据中提取敏感信息（keys, certs, passwords）


kubenetes 默认在两个端口提供服务：一个是基于 https 安全端口 6443，另一个是基于 http 的非安全端口 8080。其中非安全端口 8080 限制只能本机访问，即绑定的是 localhost。

**对于安全端口来讲，一个 API 请求到达 6443 端口后，主要经过以下几步处理：**

- **认证**
- **授权**
- **准入控制**
- **实际的 API 请求**

# API Server**的** 认证Authentication

API Server认证 Authentication提供管理三种级别的客户端身份认证方式：

最严格的HTTPS证书认证：基于CA根证书签名的双向数字证书认证方式；
HTTP Token认证：通过一个Token来识别合法用户；
HTTP Base认证：通过用户名+密码的方式认证；
1、HTTPS证书认证：
HTTPS通信双方的务器端向CA机构申请证书，CA机构是可信的第三方机构，它可以是一个公认的权威的企业，也可以是企业自身。企业内部系统一般都使用企业自身的认证系统。CA机构下发根证书、服务端证书及私钥给申请者；
HTTPS通信双方的客户端向CA机构申请证书，CA机构下发根证书、客户端证书及私钥个申请者；
客户端向服务器端发起请求，服务端下发服务端证书给客户端。客户端接收到证书后，通过私钥解密证书，并利用服务器端证书中的公钥认证证书信息比较证书里的消息，例如域名和公钥与服务器刚刚发送的相关消息是否一致，如果一致，则客户端认为这个服务器的合法身份；
客户端发送客户端证书给服务器端，服务端接收到证书后，通过私钥解密证书，获得客户端的证书公钥，并用该公钥认证证书信息，确认客户端是否合法；
客户端通过随机秘钥加密信息，并发送加密后的信息给服务端。服务器端和客户端协商好加密方案后，客户端会产生一个随机的秘钥，客户端通过协商好的加密方案，加密该随机秘钥，并发送该随机秘钥到服务器端。服务器端接收这个秘钥后，双方通信的所有内容都都通过该随机秘钥加密；
 ![im](E:/git_project/k8s_study/k8s/src/笔记/images/caauthor.png)

上述是双向SSL协议的具体通信过程，这种情况要求服务器和用户双方都有证书。单向认证SSL协议不需要客户拥有CA证书，对应上面的步骤，只需将服务器端验证客户端证书的过程去掉，以及在协商对称密码方案和对称通话秘钥时，服务器端发送给客户端的是没有加过密的（这并不影响SSL过程的安全性）密码方案。



2、HTTP Token原理：
HTTP Token的认证是用一个很长的特殊编码方式的并且难以被模仿的字符串——Token来表明客户身份的一种方式。在通常情况下，Token是一个复杂的字符串，比如我们用私钥签名一个字符串的数据就可以作为一个Token，此外每个Token对应一个用户名，存储在API Server能访问的一个文件中。当客户端发起API调用请求时，需要在HTTP Header里放入Token，这样一来API Server就能够识别合法用户和非法用户了。

3、HTTP Base：
常见的客户端账号登录程序，这种认证方式是把“用户名+冒号+密码”用BASE64算法进行编码后的字符串放在HTTP REQUEST中的Header Authorization域里发送给服务端，服务端收到后进行解码，获取用户名及密码，然后进行用户身份的鉴权过程。



## APIServer 授权



对合法用户进行授权（Authorization）并且随后在用户访问时进行鉴权，是权限与安全系统的重要一环。授权就是授予不同用户不同访问权限：

API Server 目前支持以下几种授权策略 (通过 API Server 的启动参数 --authorization-mode 设置)

- AlwaysDeny：标识拒绝所有的请求，一般用于测试


- AlwaysAllow：允许接受所有请求，如果集群不需要授权流程，则可以采用该策略


- ABAC：（Attribute-Base Access Control）基于属性的访问控制，表示使用用户配置的授权规则对用户请求进行匹配和控制，淘汰


- Webbook：通过调用外部 REST 服务对用户进行授权


- RBAC：基于角色的访问控制，现行默认规则，常用



ABAC授权模式：
为了简化授权的复杂度，对于ABAC模式的授权策略，Kubernetes仅有下面四个基本属性：

用户名（代表一个已经被认证的用户的字符型用户名）
是否是只读请求（REST的GET操作是只读的）
被访问的是哪一类资源，例如Pod资源/api/v1/namespaces/default/pods
被访问对象所属的Namespace
当API Server启用ABAC模式时，需要指定授权文件的路径和名字（--authorization_policy_file=SOME_FILENAME）,授权策略文件里的每一行都是一个Map类型的JOSN对象，被称为访问策略对象，我们可以通过设置“访问策略对象”中的如下属性来确定具体的授权行为：

user：字符串类型，来源于Token文件或基本认证文件中的用户名字段的值；
readonly：true时表示该策略允许GET请求通过；
resource：来自于URL的资源，例如“Pod”；
namespace：表明该策略允许访问某个namespace的资源；
eg：

{"user":"alice"}
{"user":"kubelet","resource":"Pods","readonly":true}
{"user":"kubelet","resource":"events"}
{"user":"bob","resource":"Pods","readonly":true,"ns":"myNamespace"}
RBAC 授权模式
 RBAC 基于角色的访问控制，在 kubernetes1.5 中引入，现行版本成为默认标准。相对其他访问控制方式，拥有以下优势：

对集群中的资源和非资源拥有完整的覆盖
整个 RBAC 完全由几个API 对象完成。同其他 API 对象一样，可以用 kubectl 或 API 进行操作。
可以在运行时进行调整，无需重启 API Server。
RBAC 的 API 资源对象说明
 RBAC 引入了 4个新的顶级资源对象：Role、ClusterRole、RoleBinding、ClusterRoleBinding、4种对象类型均可以通过 kubectl 与 API 操作。

Role：普通角色 | ClusterRole：集群角色

Rolebinding：普通角色绑定 ClusterRoleBinding：集群角色绑定 

## Admission Control 准入控制

通过了前面的认证和授权之后，还需要经过准入控制处理通过之后，apiserver 才会处理这个请求。Admission Control 有一个准入控制列表，我们可以通过命令行设置选择执行哪几个准入控制器。只有所有的准入控制器都检查通过之后，apiserver 才执行该请求，否则返回拒绝。

当前可配置的准入控制器主要有：

- 在认证和授权之外，Admission Controller也可以对Kubernetes API Server的访问控制，任何请求在访问API Server时需要经过一系列的验证，任何一环拒绝了请求，则会返回错误。
  实际上Admission Controller是作为Kubernetes API Serve的一部分，并以插件代码的形式存在，在API Server启动的时候，可以配置需要哪些Admission Controller，以及它们的顺序，如：

  --admission_control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota

  Admission Controller支持的插件如下：
  AlwaysAdmit：允许所有请求；
  AlwaysPullmages：在启动容器之前总去下载镜像，相当于在每个容器的配置项imagePullPolicy=Always
  AlwaysDeny：禁止所有请求，一般用于测试；
  DenyExecOnPrivileged：它会拦截所有想在Privileged Container上执行命令的请求，如果你的集群支持Privileged Container，你又希望限制用户在这些Privileged Container上执行命令，强烈推荐你使用它；
  Service Account：这个plug-in将ServiceAccount实现了自动化，默认启用，如果你想使用ServiceAccount对象，那么强烈你推荐使用它；
  SecurityContextDeny：这个插件将使用SecurityContext的Pod中的定义全部失效。SecurityContext在Container中定义了操作系统级别的安全设定（uid，gid，capabilityes，SELinux等）
  ResourceQuota：用于配额管理目的，作用于namespace上，它会观察所有请求，确保在namespace上的配额不会超标。推荐在Admission Control参数列表中这个插件排最后一个；
  LimitRanger：用于配额管理，作用于Pod与Container，确保Pod与Container上的配额不会超标；
  NamespaceExists（已过时）：对所有请求校验namespace是否已存在，如果不存在则拒绝请求，已合并至NamespaceLifecycle。
   NamespaceAutoProvision（已过时）：对所有请求校验namespace，如果不存在则自动创建该namespace，推荐使用NamespaceLifecycle。
  NamespaceLifecycle：如果尝试在一个不存在的namespace中创建资源对象，则该创建请求将被拒绝。当删除一个namespace时，系统将会删除该namespace中所有对象，保存Pod，Service等。
  在API Server上设置--admission-control参数，即可定制我们需要的准入控制链，如果启用多种准入控制选项，则建议的设置如下：

  --admission-control=NamespaceLifecycle，LimitRanger，SecurityContextDeny，ServiceAccount，ResourceQuota
  下面着重介绍三个准入控制器：

  SecurityContextDeny
  Security Context时运用于容器的操作系统安全设置（uid、gid、capabilities、SELinux role等），Admission Control的SecurityContextDeny插件的作用是，禁止创建设置了Security Context的Pod，例如包含以下配置项的Pod：

  spec.containers.securityContext.seLinuxOptions
  spec.containers.securityContext.runAsUser
  ResourceQuota
  ResourceQuota不仅能够限制某个Namespace中创建资源的数量，而且能够限制某个namespace中被Pod所请求的资源总量。该准入控制器和资源对象ResourceQuota一起实现了资源的配额管理；

  LimitRanger
  准入控制器LimitRanger的作用类似于上面的ResourceQuota控制器，这对Namespace资源的每个个体的资源配额。该插件和资源对象LimitRange一起实现资源限制管理 

  # Secrets

  Kubernetes提供了Secret来处理敏感信息，目前Secret的类型有3种：

  Opaque(default): 任意字符串
  kubernetes.io/service-account-token: 作用于ServiceAccount
  kubernetes.io/dockercfg: 作用于Docker registry

#    ServiceAccount

什么是service account? 顾名思义，相对于user account（比如：kubectl访问APIServer时用的就是user account），service account就是Pod中的Process用于访问Kubernetes API的account，它为Pod中的Process提供了一种身份标识。相比于user account的全局性权限，service account更适合一些轻量级的task，更聚焦于授权给某些特定Pod中的Process所使用。

 

Service Account概念的引入是基于这样的使用场景：运行在pod里的进程需要调用Kubernetes API以及非Kubernetes API的其它服务（如image repository/被mount到pod上的NFS volumes中的file等）。我们使用Service Account来为pod提供id。
Service Account和User account可能会带来一定程度上的混淆，User account可以认为是与Kubernetes交互的个体，通常可以认为是human, 目前并不作为一个代码中的类型单独出现，比如第一节中配置的用户，它们的区别如下。

Kubernetes有User Account和Service Account两套独立的账号系统：
1.User Account是给人用的，Service Account 是给Pod 里的进程使用的，面向的对象不同。
2.User Account是全局性的，即跨namespace使用。 Service Account 是属于某个具体的Namespace，即仅在所属的namespace下使用。
3.User Account是与后端的用户数据库同步的。创建一个新的user account通常需要较高的特权并且需要经过比较复杂的business process（即对于集群的访问权限的创建），而service account则不然。

 

如果kubernetes开启了ServiceAccount（–admission_control=…,ServiceAccount,… ）那么会在每个namespace下面都会创建一个默认的default的ServiceAccount。即service account作为一种resource存在于Kubernetes cluster中，我们可以通过kubectl获取

1、当前cluster中的service acount列表：

kubectl get serviceaccount --all-namespaces





# iptables



# ETCD



# Namespace

命名空间主要有两个方面的作用:

**资源隔离：**可为不同的团队/用户（或项目）提供虚拟的集群空间，共享同一个Kubernetes集群的资源。比如可以为团队A创建一个Namespace ns-a，团队A的项目都部署运行在 ns-a 中，团队B创建另一个Namespace ns-b，其项目都部署运行在 ns-b 中，或者为开发、测试、生产环境创建不同的Namespace，以做到彼此之间相互隔离，互不影响。我们可以使用 ResourceQuota 与 Resource LimitRange 来指定与限制 各个namesapce的资源分配与使用
**权限控制：**可以指定某个namespace哪些用户可以访问，哪些用户不能访问 

# 1. 安装的两种方式

 kubeadm 安装
 二进制安装
 https://blog.csdn.net/aa18855953229/article/details/108988316
 https://blog.csdn.net/redrose2100/article/details/123254371?spm=1001.2101.3001.6661.1&utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-1-123254371-blog-108988316.pc_relevant_multi_platform_whitelistv1&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7ECTRLIST%7Edefault-1-123254371-blog-108988316.pc_relevant_multi_platform_whitelistv1&utm_relevant_index=1

## 1.2 

# 2 docker 和containerd 区别

Docker作为k8s容器运行时，调用关系如下:
kubelet --> docker shim(在 kubelet进程中) --> dockerd --> containerd

Containerd作为k8s容器运行时，调用关系如下:
kubelet --> cri plugin (在 containerd进程中)--> containerd
其中dockerd虽增加了swarm cluster、docker build、docker API等功能，但也会引入一些bug，而与containerd相比，多了一层调用。
区别：
1、containerd不需要经过dockershim，所以调用链更短，组件更少，更稳定，占用节点资源更少，docker需要经过所以调用链更长；
2、docker调用cni是“docker-shim”，containerd调用cni是“containerd-cri”。

dockershim 将会从 Kubernetes 1.24 中完全移除，

| docker | containerd |      |
| ------ | ---------- | ---- |
|        |            |      |
|        |            |      |
|        |            |      |

**containerd 其实就是用来替换Docker的**

 

## 2.1 Docker相关操作

 	

# 3. 容器 service, Inress, 微服务负载均衡怎么做

# 4. 镜像怎么打包、发布

## 4.1 搭建私有镜像仓库

### Harbor搭建：

# 5. 容器网络,网络插件优缺点使用场景 

- veth 设备对

- 网桥

   ip route list 查看当前路由表

  netstat -rn  查看路由表

#### 		5.1 Docker 网络

- host
- container
- none
- bridge  默认类型

##### 5.2 Kubernets 网络

1. 容器之间直接通信

   - 同Pod之内的容器直接通过localhost就可以
   - 不容Pod节点的容器？

2. pod到Pod之间的通讯

   - 同一个Node内的通信。在同一个网桥上，IP地址段相同直接可以通讯

   - 不同Node之间的Pod通信。需要规划docker0 IP地址不能冲突。

     **多机网络模式：**一类是 Docker 在 1.9 版本中引入Libnetwork项目，对跨节点网络的原生支持；一类是通过插件（plugin）方式引入的第三方实现方案，比如 Flannel，Calico 等等

3. Pod到Service 之间的通信

4. 集群外部与内部的通信

   

# 6. ks8集群 升级 回退，扩缩容
## 6.1 集群的集群怎么做



# 7. 微服务场景应用
# 8. k8s 容量，多少节点可以提供多少服务能力
## 8.2 一个集群能管理多少节点

# 9.RS 和Deployment的区别

# 10.监控和日志

# 11.haproxy+keepalived

### haproxy 是一个开源的，高性能的，负载均衡软件，借助haproxy可以快速，可靠的构建一个负载均衡群集。

优点如下：

可靠性和稳定性非常好，可以和硬件级的负载均衡设备F5相媲美。

最高可同时维护40000-50000个并发连接，单位时间内处理的最大请求数为20000个。

#### keepalived keepalived基于vrrp协议，两台主机之间生成一个虚拟的ip，我们称漂移ip，漂移ip由主服务器承担，一但主服务器宕机，备份服务器就会抢占漂移ip，继续工作，有效的解决了群集中的单点故障。两者相结合，挺好的。

让haproxy监听keepalived的漂移ip工作，一但haproxy宕机，备份抢占漂移ip继续承担着代理的工作。

keepalived：就是对haproxy集群代理的单点IP做个虚拟IP保证可靠性，提高系统可用性。

# 12 K8s的服务发现

### 12.1集群内部服务访问

### 12.2集群内部服务访问

# 13 共享存储

PV 定义存储资源

PVC 定义资源使用多少

StorageClass 可以认为是具体的资源和实际的物理资源的绑定关系

# 14 子网隔离实现方案

# 