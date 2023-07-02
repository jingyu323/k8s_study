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

## 4.实现原理

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
uwoa39X4RI1rnLtHiKrY
144
IFOiAvm1Yu+TkYm=IwTz
```



官网

https://www.elastic.co/guide/en/elasticsearch/reference/8.7/rpm.html#rpm-repo

```sh
直接安装，需要配置仓库
 cd  /etc/yum.repos.d/
 elasticsearch.repo

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

node1  主节点

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
#network.host: 192.168.0.1
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
#discovery.seed_hosts: ["host1", "host2"]
#
# Bootstrap the cluster using an initial set of master-eligible nodes:
#
cluster.initial_master_nodes: ["node1", "node2"]
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



```

注册节点





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



错误：

1.ERROR: Skipping security auto configuration because it appears that the node is not starting up for the first time. The node might already be part of a cluster and this auto setup utility is designed to configure Security for new clusters only





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

## 6.使用

1.分词设置

2.语法



## 7.常见问题

7.1 错误排查

日志

 /var/log/elasticsearch/es.log



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


sudo yum install kibana -y

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



##### kibana 使用

https://www.elastic.co/guide/cn/kibana/current/connect-to-elasticsearch.html

