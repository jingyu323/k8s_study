# ElasticSearch相关

## 1.介绍

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
```



官网

https://www.elastic.co/guide/en/elasticsearch/reference/8.7/rpm.html#rpm-repo

```sh
下载rpm包
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.7.1-x86_64.rpm

 rpm --install elasticsearch-8.7.1-x86_64.rpm

开机启动
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
启动/停止
sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

journalctl --unit elasticsearch

```

## 6.使用

## 7.常见问题

## 8.参考资料