# Redis相关

## 1.介绍

## 2.作用

## 3.优点

## 4.实现原理

## 5.安装

解压安装包 

tar zvxf redis-6.2.7.tar.gz 

yum install gcc 

make PREFIX=/usr/local/redis install





## 6.使用

客户端登录

./bin/redis-cli -p 6499

### 数据类型
1.zset 
限制单个用户内容生产速度，不同等级的用户会有不同的频率控制参数

## 7.常见问题

1.redis 只有单线程吗？

redis是单线程的，主要是io线程，redis持久化、集群同步邓操作则是由另外的线程来执行的

2.redis 单线程为什么还这么快

redis大部分操作都是在内存中完成的，单线程模型避免了多线程之间的线程竞争，redis 采用I/O多路复用机制处理大量的socket 请求



## 参考资料