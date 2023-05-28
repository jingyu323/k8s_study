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
```



官网

https://www.elastic.co/guide/en/elasticsearch/reference/8.7/rpm.html#rpm-repo

```sh
下载rpm包
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.7.1-x86_64.rpm

su es
rpm --install elasticsearch-8.7.1-x86_64.rpm

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
```

## 6.使用

1.分词设置

2.语法



## 7.常见问题

## 8.参考资料



# Kibana



Kibana是ElasticSearch的数据可视化和实时分析的工具，利用Elasticsearch的聚合功能，生成各种图表，如柱形图，线状图，饼图等。



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


```



```sh
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service

启动
sudo systemctl start kibana.service
sudo systemctl stop kibana.service


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

```

验证码生成

不兼容

Couldn't configure Elastic
The Elasticsearch cluster (v8.7.1) is incompatible with this version of Kibana (v8.8.0).

升级

在安装完kibana后，直接启动kibana服务，只能在本机通过127.0.0.1:5601来访问。如果需要远端访问，则需要修改kibana.yml。

修改kibana服务绑定地址。

server.host: "0.0.0.0"
配置完成后，重新启动kibana服务即可通过远端访问。

