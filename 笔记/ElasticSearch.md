# ElasticSearch相关

## 1.介绍

高扩展的分布式全文检索引擎==，它可以近乎实时的检索数据；本身扩展性很好，可以扩展到上百台服务器，处理PB级别的数据。ES使用Java开发。Lucene作为其核心来实现所有索引和搜索的功能，但是它的目的是通过简单的RESTful API来隐藏Lucene的复杂性，从而让全文搜索变得简单。 

1.分布式实时文件存储，并将每一个字段都编入索引，使其可以被搜索。
2.实时分析的分布式[搜索引擎](https://so.csdn.net/so/search?q=搜索引擎&spm=1001.2101.3001.7020)。
3.可以扩展到上百台服务器，处理PB级别的结构化或非结构化数据

## 2.作用




## 3.优点

分布式，无需人工搭建集群（solr就需要人为配置，使用Zookeeper作为注册中心）
Restful风格，一切API都遵循Rest原则，容易上手近实时搜索，数据更新在Elasticsearch中几乎是完全同步的



index 状态：





## 4.实现原理

### 4.1分片：





## 5.安装

不能使用root用户来启动

```
# 创建用户
useradd es
# 为用户修改密码
passwd es
重置密码
./elasticsearch-reset-password -u elastic

daX7Xw+1j0zNd8IXpD14

本地密码：
Xi3aLVfl43JNHdufBCom

142
eP3-Uii07tHLZ+hit=VO

143
xMLhNuN+8bZnlOEgD8GO
144
RiYighjuwV*e4lsxpKiY
```



官网

https://www.elastic.co/guide/en/elasticsearch/reference/8.8/rpm.html#rpm-repo

```sh
直接安装，需要配置仓库
 cd  /etc/yum.repos.d/
 vielasticsearch.repo

[elasticsearch]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md

sudo yum install --enablerepo=elasticsearch elasticsearch  -y

下载rpm包
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-x86_64.rpm

rpm --install elasticsearch-8.8.2-x86_64.rpm

开机启动
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
启动/停止
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service
sudo systemctl status elasticsearch.service

journalctl --unit elasticsearch

修改系统最大文件句柄数（修改后需要重启系统才能生效）
# vi /etc/security/limits.conf
*       soft    nproc   65535
*       hard    nproc   65535
*       soft    nofile  65535
*       hard    nofile  65535

reboot

修改最大虚拟内存
 vi /etc/sysctl.conf
vm.max_map_count=655360

上述启动命令默认是前台启动,窗口关闭后,将会退出,如果需要后台启动,则输入以下命令
./elasticsearch -d

需要用https
https://127.0.0.1:9200/
默认用户
elastic

密码就是打印到屏幕上的密码




```



```
 142 qvKpUo1_T1yqgkpn_KMk

143  - mongo2
Authentication and authorization are enabled.
TLS for the transport and HTTP layers is enabled and configured.

The generated password for the elastic built-in superuser is : WSzZnnZUUPPXXQdhNMFY

If this node should join an existing cluster, you can reconfigure this with
'/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
after creating an enrollment token on your existing cluster.

You can complete the following actions at any time:

Reset the password of the elastic built-in superuser with 
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with 
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with 
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.
144 - mongo1

Authentication and authorization are enabled.
TLS for the transport and HTTP layers is enabled and configured.

The generated password for the elastic built-in superuser is : 0877+C7=nc-=ESJjajwB

If this node should join an existing cluster, you can reconfigure this with
'/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
after creating an enrollment token on your existing cluster.

You can complete the following actions at any time:

Reset the password of the elastic built-in superuser with 
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with 
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with 
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.

-------------------------------------------------------------------------------------------------
### NOT starting on installation, please execute the following statements to configure elasticsearch service to start automatically using systemd
 sudo systemctl daemon-reload
 sudo systemctl enable elasticsearch.service
### You can start elasticsearch service by executing
 sudo systemctl start elasticsearch.service

Couldn't write '1' to 'vm/unprivileged_userfaultfd', ignoring: No such file or directory


```





### 集群配置

1.修改

/etc/elasticsearch/elasticsearch.yml

node1  主节点 , node2 node3 节点只是名称ip不同其他没有啥不同

增加如下

```
# 集群名称，默认是 elasticsearch
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
cluster.name: es
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
node.name: node1
#
# Add custom attributes to the node:
#
#node.attr.rack: r1
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
#bootstrap.memory_lock: true
#
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# By default Elasticsearch is only accessible on localhost. Set a different
# address here to expose this node on the network:
#
network.host: 192.168.182.143
#
# By default Elasticsearch listens for HTTP traffic on the first free port it
# finds starting at 9200. Set a specific HTTP port here:
#
http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
discovery.seed_hosts: ["192.168.182.142", "192.168.182.143","192.168.182.144"]
#
# Bootstrap the cluster using an initial set of master-eligible nodes:
#
cluster.initial_master_nodes: ["node1", "node2", "node3"]
#
# For more information, consult the discovery and cluster formation module documentation.
#
# ---------------------------------- Various -----------------------------------
#
# Allow wildcard deletion of indices:
#
#action.destructive_requires_name: false

#----------------------- BEGIN SECURITY AUTO CONFIGURATION -----------------------
#
# The following settings, TLS certificates, and keys have been automatically      
# generated to configure Elasticsearch security features on 01-07-2023 14:38:29
#
# --------------------------------------------------------------------------------

# Enable security features
xpack.security.autoconfiguration.enabled : true
xpack.security.enabled: true


xpack.security.enrollment.enabled: true
xpack.security.transport.ssl.verification_mode: none

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

# Enable encryption and mutual authentication between cluster nodes
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/elastic-certificates.p12
  truststore.path: certs/elastic-certificates.p12
# Create a new cluster with the current node only
# Additional nodes can still join the cluster later
#cluster.initial_master_nodes: ["localhost.localdomain"]

# Allow HTTP API connections from anywhere
# Connections are encrypted and require user authentication
http.host: 0.0.0.0

# Allow other nodes to join the cluster from anywhere
# Connections are encrypted and mutually authenticated
transport.host: 0.0.0.0
transport.port: 9300

#----------------------- END SECURITY AUTO CONFIGURATION -------------------------
node.roles: [master,data]



```

1.这里有两种方式，把安全的相关属性设置为false，启动三节点即可，集群创建成功。

为了安全就需要启用安全属性，需要各个节点之间的交互证书

生成集群节点证书：

```
生成ca证书
./bin/elasticsearch-certutil ca
使用ca证书生成集群通信证书
./bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

```

把证书复制到其他节点/etc/elasticsearch/certs 目录中

把证书密钥添加至本地密钥库

```
./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password


./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password
```



节点更新完成之后重启各个节点，查看节点状态，集群创建成功。

生成节点间通讯TLS证书

```javascript
生成CA证书
/usr/share/elasticsearch/bin/elasticsearch-certutil ca

创建密钥库
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12

/usr/share/elasticsearch/bin/elasticsearch-certutil http


retrieve the password for http.p12
/usr/share/elasticsearch/bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password

retrieve the password for transport.p12:
/usr/share/elasticsearch/bin/elasticsearch-keystore show xpack.security.transport.ssl.keystore.secure_password
```

```
状态查询
curl -XGET"http://localhost:9200/_cluster/health?pretty=true"
查询Elasticsearch运行状态
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic https://localhost:9200 
查询集群节点信息
curl --cacert /etc/elasticsearch/certs/http_ca.crt -u elastic https://localhost:9200/_cluster/health?pretty=true 

 curl --cacert /etc/elasticsearch/certs/http_ca.crt  -u elastic https://localhost:9200/_cat/nodes

142    qvKpUo1_T1yqgkpn_KMk

生成token
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node

/usr/share/elasticsearch/bin/elasticsearch-certutil cert

/usr/share/elasticsearch/bin/elasticsearch --enrollment-token eyJ2ZXIiOiI4LjguMiIsImFkciI6WyIxOTIuMTY4LjE4Mi4xNDI6OTIwMCJdLCJmZ3IiOiIxNDdjOWE5NGMwZDUwNTk2NWMwYWE0MmEyNDg3YzVkMjUyMWYzNjc5Y2QxZmMxOTBmYTg5ZDUxOTJlOTM1NjE4Iiwia2V5IjoibTkzMUZJa0JtRy1SVjJfNjZfYzk6M0hZN0Mxam5Uak9LWEVJQTJpN3BjUSJ9


/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token eyJ2ZXIiOiI4LjguMiIsImFkciI6WyIxOTIuMTY4LjE4Mi4xNDI6OTIwMCJdLCJmZ3IiOiIxNDdjOWE5NGMwZDUwNTk2NWMwYWE0MmEyNDg3YzVkMjUyMWYzNjc5Y2QxZmMxOTBmYTg5ZDUxOTJlOTM1NjE4Iiwia2V5IjoiU3BlVEZJa0JlNGN3cEVUbFBMR1g6UEpPRm1DTzZUNGlMelFtTV9pVXZDQSJ9

/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token eyJ2ZXIiOiI4LjguMiIsImFkciI6WyIxOTIuMTY4LjE4Mi4xNDI6OTIwMCJdLCJmZ3IiOiIxNDdjOWE5NGMwZDUwNTk2NWMwYWE0MmEyNDg3YzVkMjUyMWYzNjc5Y2QxZmMxOTBmYTg5ZDUxOTJlOTM1NjE4Iiwia2V5IjoiUnBkVEZJa0JlNGN3cEVUbHFyRWI6T2prOEdfTDBRbzZOR2dNME81enZwUSJ9


/usr/share/elasticsearch/bin/elasticsearch-node  remove-settings

repurpose - Repurpose this node to another master/data role, cleaning up any excess persisted data
unsafe-bootstrap - Forces the successful election of the current node after the permanent loss of the half or more master-eligible nodes
detach-cluster - Detaches this node from its cluster, allowing it to unsafely join a new cluster
override-version - Overwrite the version stored in this node's data path with [8.8.2] to bypass the version compatibility checks
remove-settings - Removes persistent settings from the cluster state
remove-customs - Removes custom metadata from the cluster state

```



#### 添加节点到已经存在的集群

https://www.elastic.co/guide/en/elasticsearch/reference/8.8/add-elasticsearch-nodes.html





#### 设置https ，添加之后之后kinabna访问集群

https://www.elastic.co/guide/en/elasticsearch/reference/8.8/security-basic-setup-https.html

```



```





错误：

1.ERROR: Skipping security auto configuration because it appears that the node is not starting up for the first time. The node might already be part of a cluster and this auto setup utility is designed to configure Security for new clusters only

这个是因为安装好之后启动过一次，之后注册节点没成功。

2.Skipping security auto configuration because this node is configured to bootstrap or to join a multi-node cluster, which is not supported

不能删除安全项配置，

```
xpack.security.enabled: true

xpack.security.enrollment.enabled: true

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

# Enable encryption and mutual authentication between cluster nodes
xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
```



3. ERROR: Skipping security auto configuration because it appears that security is already configured

   安装好之后配置了集群但是注册失败，具体原因还得继续排除

4. java.security.cert.CertPathValidatorException: Path does not chain with any of the trust anchors

   这种问题是开启了安全模式，各个节点没有配置证书的原因导致

   

### 卸载

systemctl stop elasticsearch.service

systemctl stop elasticsearch.service;
[root@localhost ~]# systemctl disable elasticsearch;
Removed /etc/systemd/system/multi-user.target.wants/elasticsearch.service.
[root@localhost ~]#  systemctl daemon-reload;

rpm -qa | grep elasticsearch;

rpm -e --nodeps   elasticsearch-8.8.2-1.x86_64

 rm -rf /etc/elasticsearch;
 rm -rf /opt/software/elasticsearch;

rm -rf /var/lib/elasticsearch /usr/share/elasticsearch





### cerebro 安装

启动 默认9000端口

systemctl   start cerebro.service



### 证书配置

Elasticsearch基础3——密钥库工具、证书生成工具及四种生成模式、https请求步骤流程



## 6.使用

1. 分词设置





2. 语法





3. 集群信息



4. 数据类型：

Text：
会分词，然后进行索引
支持模糊、精确查询
不支持聚合
keyword：
不进行分词，直接索引
支持模糊、精确查询
支持聚合

keyword类型不会被分词，常用于关键字搜索，比如姓名、email地址、主机名、状态码和标签等





- 集群的健康状态，通过api获取：GET _cluster/health?pretty

  关键指标说明：
  status：集群状态，分为green、yellow和red。
  number_of_nodes/number_of_data_nodes:集群的节点数和数据节点数。
  active_primary_shards：集群中所有活跃的主分片数。
  active_shards：集群中所有活跃的分片数。
  relocating_shards：当前节点迁往其他节点的分片数量，通常为0，当有节点加入或者退出时该值会增加。
  initializing_shards：正在初始化的分片。
  unassigned_shards：未分配的分片数，通常为0，当有某个节点的副本分片丢失该值就会增加。
  number_of_pending_tasks：是指主节点创建索引并分配shards等任务，如果该指标数值一直未减小代表集群存在不稳定因素
  active_shards_percent_as_number：集群分片健康度，活跃分片数占总分片数比例。

  number_of_pending_tasks：pending task只能由主节点来进行处理，这些任务包括创建索引并将shards分配给节点

- 集群状态信息可以由以下api获取：GET _cluster/stats?pretty

  关键指标说明：
  indices.count：索引总数。
  indices.shards.total：分片总数。
  indices.shards.primaries：主分片数量。
  docs.count：文档总数。
  store.size_in_bytes：数据总存储容量。
  segments.count：段总数。
  nodes.count.total：总节点数。
  nodes.count.data：数据节点数。
  nodes. process. cpu.percent：节点CPU使用率。
  fs.total_in_bytes：文件系统使用总容量。

  fs.free_in_bytes：文件系统剩余总容量。

- 节点指标可以通过以下api获取:GET /_nodes/stats?pretty

  name：节点名。
  roles：节点角色。
  indices.docs.count：索引文档数。
  segments.count：段总数。
  jvm.heap_used_percent：内存使用百分比。
  thread_pool.{bulk, index, get, search}.{active, queue, rejected}：线程池的一些信息，包括bulk、index、get和search线程池，主要指标有active（激活）线程数，线程queue（队列）数和rejected（拒绝）线程数量。

  以下一些指标是一个累加值，当节点重启之后会清零。
  indices.indexing.index_total：索引文档数。
  indices.indexing.index_time_in_millis：索引总耗时。
  indices.get.total：get请求数。
  indices.get.time_in_millis：get请求总耗时。
  indices.search.query_total：search总请求数。
  indices.search.query_time_in_millis：search请求总耗时。indices.search.fetch_total：fetch操作总数量。
  indices.search.fetch_time_in_millis：fetch请求总耗时。
  jvm.gc.collectors.young.collection_count：年轻代垃圾回收次数。
  jvm.gc.collectors.young.collection_time_in_millis：年轻代垃圾回收总耗时。
  jvm.gc.collectors.old.collection_count：老年代垃圾回收次数。

  jvm.gc.collectors.old.collection_time_in_millis：老年代垃圾回收总耗时。

- 索引监控指标注意针对单个索引，不过也可以通过"_all"对集群种所有索引进行监控，节点指标可以通过以下api获取：GET /_stats?pretty

  关键指标说明（indexname泛指索引名称）：
  indexname.primaries.docs.count：索引文档数量。
      以下一些指标是一个累加值，当节点重启之后会清零。
  indexname.primaries.indexing.index_total：索引文档数。
  indexname.primaries.indexing.index_time_in_millis：索引总耗时。
  indexname.primaries.get.total：get请求数。
  indexname.primaries.get.time_in_millis：get请求总耗时。
  indexname.primaries.search.query_total：search总请求数。
  indexname.primaries.search.query_time_in_millis：search请求总耗时。indices.search.fetch_total：fetch操作总数量。
  indexname.primaries.search.fetch_time_in_millis：fetch请求总耗时。
  indexname.primaries.refresh.total：refresh请求总量。
  indexname.primaries.refresh.total_time_in_millis：refresh请求总耗时。
  indexname.primaries.flush.total：flush请求总量。

  indexname.primaries.flush.total_time_in_millis：flush请求总耗时。

  

-  集群状态详情 https://blog.51cto.com/u_15812686/5739502

### 6.2 分片 配置

```
在根目录下检索所有index
GET /_search 
在指定索引下检索所有文档
https://192.168.99.118:9200/products/_search
添加数据
PUT products/_doc/5

{
  "name" : "xiaoming",
  "hobby" : "work",
  "job" : "worker",
  "age" : 11
}

postman 中选raw  json 

添加数据
POST  /mynewindex/_doc

指定id用put 不指定id用post

GET /search_index/_search?q=job:(java AND enginger)

GET /search_index/_search?q=job:(java OR enginger)

GET /search_index/_search?q=job:(NOT java  enginger)

GET /search_index/_search?q=job:((NOT java  enginger) || (worker -teacher))

删除数据
 POST   /library/_delete_by_query  -d '{"query":{"term":{"name":"计算机基础"}}}'
 DELETE  /library
Term Query将查询语句作为整个单词进行查询，即不对查询语句做分词处理


索引新增字段
 PUT 127.0.0.1:9200/library/books/_mapping -d '{"properties": {"publisher": {"type": "keyword"}}}'

```

### 6.3 映射

映射类似于 SQL 数据库中的模式。它规定了我们的索引将摄取的文档的形式. 就是定义存储在索引中的数据格式和数据类型，如果不符合数据类型该index数据插入失败。

### 6.4 查询

#### 模板查询：

1.先创建模板

```
PUT _scripts/my-search-template
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "match": {
          "message": "{{query_string}}"
        }
      },
      "from": "{{from}}",
      "size": "{{size}}"
    },
    "params": {
      "query_string": "My query string"
    }
  }
}
```





### 6.5 分词器

分词器的主要作用将用户输入的一段文本，按照一定逻辑，分析成多个词语的一种工具

分词器下载地址

analysis-ik 

https://github.com/infinilabs/analysis-ik/releases

```
./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v8.12.2/elasticsearch-analysis-ik-8.12.2.zip
```

#### 什么时候分词

- `创建索引`：当索引文档字符类型为`text`时，在建立索引时将会对该字段进行分词。
- `搜索`：当对一个`text`类型的字段进行全文检索时，会对用户输入的文本进行分词。

```
curl -X GET -H "Content-Type: application/json"  "http://localhost:9200/_analyze?pretty=true" -d'{"text":"我就是全村人的希望","analyzer": "ik_smart"}'
```



分词 添加时机：

1. 添加完所以之后，创建mapping的时候



| ik_smart    | ik分词器中的简单分词器，支持自定义字典，远程字典 | 学如逆水行舟，不进则退 | [学如逆水行舟,不进则退]                                      |
| ----------- | ------------------------------------------------ | ---------------------- | ------------------------------------------------------------ |
| ik_max_word | ik_分词器的全量分词器，支持自定义字典，远程字典  | 学如逆水行舟，不进则退 | [学如逆水行舟,学如逆水,逆水行舟,逆水,行舟,不进则退,不进,则,退] |







## 7.常见问题

7.1 错误排查

日志

 /var/log/elasticsearch/es.log

```
ERROR: Skipping security auto configuration because it appears that the node is not starting up for the first time. The node might already be part of a cluster and this auto setup utility is designed to configure Security for new clusters only.
```



## 8.参考资料



# Kibana



Kibana是ElasticSearch的数据可视化和实时分析的工具，利用Elasticsearch的聚合功能，生成各种图表，如柱形图，线状图，饼图等。

8.0.8  Kibana 适配8.8 版本es，8.7的 不适配

 https://www.elastic.co/guide/cn/kibana/current/rpm.html





安装

```
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch


cd  /etc/yum.repos.d/
vi kibana.repo 

[kibana-8.x]
name=Kibana repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md


yum install kibana

```



```sh
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service

启动
sudo systemctl start kibana.service
sudo systemctl stop kibana.service

sudo systemctl start kibana.service
sudo systemctl status kibana.service

```

### Start Elasticsearch and generate an enrollment token for Kibana[edit](https://github.com/elastic/kibana/edit/8.8/docs/setup/install/rpm.asciidoc)

When you start Elasticsearch for the first time, the following security configuration occurs automatically:

- Authentication and authorization are enabled, and a password is generated for the `elastic` built-in superuser.
- Certificates and keys for TLS are generated for the transport and HTTP layer, and TLS is enabled and configured with these keys and certificates.

The password and certificate and keys are output to your terminal.

You can then generate an enrollment token for Kibana with the [`elasticsearch-create-enrollment-token`](https://www.elastic.co/guide/en/elasticsearch/reference/8.8/create-enrollment-token.html) tool:

```sh
生成token
/usr/share/elasticsearch/
bin/elasticsearch-create-enrollment-token -s kibana


Reset the password of the elastic built-in superuser with 
'/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

Generate an enrollment token for Kibana instances with 
 '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

Generate an enrollment token for Elasticsearch nodes with 
'/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.




```

验证码生成

/usr/share/kibana/bin/kibana-verification-code 

不兼容

Couldn't configure Elastic
The Elasticsearch cluster (v8.7.1) is incompatible with this version of Kibana (v8.8.0).

升级  Elasticsearch,参见卸载之后重新安装即可







在安装完kibana后，直接启动kibana服务，只能在本机通过127.0.0.1:5601来访问。如果需要远端访问，则需要修改kibana.yml。

/etc/kibana/kibana.yml

修改kibana服务绑定地址。

server.host: "0.0.0.0"
配置完成后，重新启动kibana服务即可通过远端访问。



### kibana 使用

https://www.elastic.co/guide/cn/kibana/current/connect-to-elasticsearch.html

kibana https  配置

https://www.elastic.co/guide/en/elasticsearch/reference/8.8/security-basic-setup-https.html#encrypt-kibana-http



### metricbeat 配置

metricbeat setup
Exiting: couldn't connect to any of the configured Elasticsearch hosts. Errors: [error connecting to Elasticsearch at https://localhost:9200: Get "https://localhost:9200": x509: certificate signed by unknown authority]



解决方法： output.elasticsearch: 增加如下配置

output.elasticsearch:

 	ssl.verification_mode: none

```
setup.kibana:

  # Kibana Host
  # Scheme and port can be left out and will be set to the default (http and 5601)
  # In case you specify and additional path, the scheme is required: http://localhost:5601/path
  # IPv6 addresses should always be defined as: https://[2001:db8::1]:5601
  host: "localhost:5601"
  username: "elastic"
  password: "BzevJY1OL-kEBnw*ZJBu"

  # Kibana Space ID
  # ID of the Kibana Space into which the dashboards should be loaded. By default,
  # the Default Space will be used.
  #space.id:
# ---------------------------- Elasticsearch Output ----------------------------
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]

  # Performance preset - one of "balanced", "throughput", "scale",
  # "latency", or "custom".
  preset: balanced

  # Protocol - either `http` (default) or `https`.
  protocol: "https"
  ssl.verification_mode: none
  
   ssl:
    enabled: true
    ca_trusted_fingerprint: "C51513EFAA86B5E078095211814D969ECE2FA26031FBA70311BC8F119AD7D108"

```



```sh
systemctl status metricbeat
启用模块
metricbeat modules enable elasticsearch-xpack
禁止模块
metricbeat modules disable system

测试配置结果
metricbeat test output

systemctl restart metricbeat
```

### Logstash 配置

https://blog.csdn.net/u011197085/article/details/130469341



elaticSearch 8.12   htttps: 访问配置

```
input {
  jdbc {
    jdbc_driver_library => "/usr/share/logstash/logstash-core/lib/jars/mysql-connector-java-8.0.16.jar"
    jdbc_driver_class => "com.mysql.cj.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/es_test"
    jdbc_user => "root"
    jdbc_password => "root"
    statement => "SELECT * FROM mytable"
  }
}

output {
  elasticsearch {
    hosts => ["https://localhost:9200"]
    index => "myindex"
    document_id => "%{id}"
    user => "elastic"
    password => "BzevJY1OL-kEBnw*ZJBu"
    cacert => '/etc/elasticsearch/certs/http_ca.crt'
  }
}
```

/usr/share/logstash/bin/logstash -f /usr/share/logstash/conf/mysql.conf





配置参数如下：证书在这个目录 /etc/elasticsearch/certs

```
    ssl_certificate_verification => true
    truststore => "/home/elastic/elasticsearch-8.4.3/config/certs/http.p12"
    truststore_password => "EDkicmcvTIaby_aFALRl3w"
```

./bin/elasticsearch-keystore list  可以查看有那些密码

./bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password   显示对应key的密码

不同的服务区分

```
input {
  tcp {
    mode => "server"
    host => "0.0.0.0"  # 允许任意主机发送日志
    port => 5044       #监听的端口号
    codec => json_lines    # 数据格式
    type => consumer
  }
}
input{
	tcp{
	 mode => "server"
	 host => "0.0.0.0"
	 port => 5045
	  codec => json_lines    # 数据格式
    type => product
	}
}

filter {
  	grok {
    	match => {
      		"message" => '%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}'
    	}
  	}
 
	if[type] == "consumer" {
		mutate {
	  		add_tag => ["consumer"]
	  	}
	}
 
	if [type] == "product" {
		mutate {
			add_tag => ["product"]
		}
	} 
}


output {
if "consumer" in [tags] {
  elasticsearch {
      hosts  => ["http://10.211.55.3:9200"]   # ElasticSearch 的地址和端口
      index  => "consumer-%{+YYYY.MM.dd}"         # 指定索引名,可以根据自己的需求指定命名
      codec  => "json"
  }
  }
  if "product" in [tags] {
  elasticsearch {
      hosts  => ["http://10.211.55.3:9200"]   # ElasticSearch 的地址和端口
      index  => "product-%{+YYYY.MM.dd}"         # 指定索引名,可以根据自己的需求指定命名
      codec  => "json"
  }
  }
  stdout {
    codec => rubydebug
  }
}

```



logstach https 配置

https://blog.csdn.net/UbuntuTouch/article/details/126868040

https://www.elastic.co/guide/en/elasticsearch/reference/8.12/configuring-stack-security.html#stack-security-certificates

### filebeat



```sh


获取 ca_trusted_fingerprint
openssl x509 -fingerprint -sha256 -in /etc/elasticsearch/certs/http_ca.crt


 ssl:
    enabled: true
    ca_trusted_fingerprint: "C51513EFAA86B5E078095211814D969ECE2FA26031FBA70311BC8F119AD7D108"

```



```sh
filebeat setup -e  设置filebeat
```



需要启用gcp

filebeat  modules  enable gcp

```
# Module: gcp
# Docs: https://www.elastic.co/guide/en/beats/filebeat/8.12/filebeat-module-gcp.html

- module: gcp
  vpcflow:
    enabled: true
    var.project_id: my-gcp-project-id
    var.topic: gcp-vpc-flowlogs
    var.subscription_name: filebeat-gcp-vpc-flowlogs-sub
    var.credentials_file: ${path.config}/gcp-service-account-xyz.json

    var.keep_original_message: false

  firewall:
    enabled: true
    var.project_id: my-gcp-project-id

    var.topic: gcp-vpc-firewall

    var.subscription_name: filebeat-gcp-firewall-sub

    var.credentials_file: ${path.config}/gcp-service-account-xyz.json

   var.keep_original_message: false
  audit:
    enabled: true
    var.project_id: my-gcp-project-id
    var.topic: gcp-vpc-audit
    var.subscription_name: filebeat-gcp-audit
    var.credentials_file: ${path.config}/gcp-service-account-xyz.json
    var.keep_original_message: false

```

systemctl restart filebeat.service





systemctl status filebeat.service





# java 连接

8.+ 版本之后Java Transport Client (deprecated)  
使用 Elasticsearch Java API Client
https://www.elastic.co/guide/en/elasticsearch/client/java-api-client/current/index.html 

https://www.elastic.co/guide/en/elasticsearch/client/java-api-client/current/connecting.html

java client connection 

指导文档

https://www.elastic.co/guide/en/elasticsearch/client/java-api-client/current/getting-started-java.html

example

 https://github.com/elastic/elasticsearch-java/tree/8.8/java-client/src/test/java/co/elastic/clients/documentation

API key再对接 kibana 之后再管理界面创建API key即可

You can generate an API key on the **Management** page under Security.

```
<dependency>
      <groupId>co.elastic.clients</groupId>
      <artifactId>elasticsearch-java</artifactId>
      <version>8.8.2</version>
    </dependency>

    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.12.3</version>
    </dependency>
```



需要找es  /etc/elasticsearch/certs/http_ca.crt  和 账户和密码



