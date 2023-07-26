# Netty相关

## 1.介绍

## 2.作用

## 3.优点

## 4.实现原理

## 5.安装

## 6.使用



### 6.1参数配置：

```
ChannelOption.SO_BACKLOG (一般用于option–>boss)
BACKLOG用于构造服务端套接字ServerSocket对象，标识当服务器请求处理线程都处于工作是(用完了)，用于临时存放已完成三次握手的请求的队列的最大长度。如果未设置或所设置的值小于1，Java将使用默认值50。

ChannelOption.SO_REUSEADDR (一般用于option–>boss)
SO_REUSEADDR 对应的是socket选项中SO_REUSEADDR，这个参数表示允许重复使用本地地址和端口，例如，某个服务占用了TCP的8080端口，其他服务再对这个端口进行监听就会报错，SO_REUSEADDR这个参数就是用来解决这个问题的，该参数允许服务公用一个端口，这个在服务器程序中比较常用，例如某个进程非正常退出，对一个端口的占用可能不会立即释放，这时候如果不设置这个参数，其他进程就不能立即使用这个端口

ChannelOption.TCP_NODELAY (一般用于childOption)
TCP_NODELAY 对应于socket选项中的TCP_NODELAY，该参数的使用和Nagle算法有关，Nagle算法是将小的数据包组装为更大的帧进行发送，而不会来一个数据包发送一次，目的是为了提高每次发送的效率，因此在数据包没有组成足够大的帧时，就会延迟该数据包的发送，虽然提高了网络负载却造成了延时，TCP_NODELAY参数设置为true，就可以禁用Nagle算法，即使用小数据包即时传输。

ChannelOption.SO_KEEPALIVE
Socket参数，连接保活，默认值为False。启用该功能时，TCP会主动探测空闲连接的有效性。可以将此功能视为TCP的心跳机制，需要注意的是：默认的心跳间隔是7200s即2小时。Netty默认关闭该功能





```







## 7.常见问题

## 8.参考资料