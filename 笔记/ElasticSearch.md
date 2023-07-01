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

sudo yum install --enablerepo=elasticsearch elasticsearch 

下载rpm包
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.8.2-x86_64.rpm

rpm --install elasticsearch-8.8.2-x86_64.rpm

开机启动
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
启动/停止
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

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
cluster.name: es
# 节点名称
node.name: node1
# 是否作为集群的主节点 ，默认 true
node.master: true
# 是否作为集群的数据节点 ，默认 true
node.data: true
# 配置访问本节点的地址
network.host: 0.0.0.0

# 设置对外服务的http端口，默认为9200
http.port: 9200

# 设置节点间交互的tcp端口,默认是9300
transport.tcp.port: 9300

# 配置所有用来组建集群的机器的IP地址
discovery.zen.ping.unicast.hosts: ["192.168.182.142:9300", "192.168.182.143:9301","192.168.182.144:9302"]

# 配置当前集群中最少具有 master 资格节点数，对于多于两个节点的集群环境，建议配置大于1
discovery.zen.minimum_master_nodes: 2
```





### 卸载

systemctl stop elasticsearch.service

systemctl stop elasticsearch.service;
[root@localhost ~]# systemctl disable elasticsearch;
Removed /etc/systemd/system/multi-user.target.wants/elasticsearch.service.
[root@localhost ~]#  systemctl daemon-reload;

rpm -qa | grep elasticsearch;

rpm -e --nodeps  elasticsearch-8.7.1-1.x86_64

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

