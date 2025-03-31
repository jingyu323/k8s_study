# Netty相关

## 1.介绍

**select、poll、epoll的区别？**

这三种方式都是操作系统实现io多路复用的机制，其中select是每一种操作系统都支持，不管是window、linux、unix，而poll和epoll主要是在unix操作系统中才支持

**主要区别是：**

① 支持一个进程所能打开的最大连接数有限制

- select：一个进程最大能监控的文件描述符数量（连接数）是1024个（32位，64位支持2048）

  - select本质上是通过设置或者检查存放fd标志位的数据结构来进行下一步处理。这样所带来的缺点是：

    1、 单个进程可监视的fd数量被限制，即能监听端口的大小有限。

       一般来说这个数目和系统内存关系很大，具体数目可以cat /proc/sys/fs/file-max察看。32位机默认是1024个。64位机默认是2048.

    2、 对socket进行扫描时是线性扫描，即采用轮询的方法，效率较低：

    ​    当套接字比较多的时候，每次select()都要通过遍历FD_SETSIZE个Socket来完成调度,不管哪个Socket是活跃的,都遍历一遍。这会浪费很多CPU时间。如果能给套接字注册某个回调函数，当他们活跃时，自动完成相关操作，那就避免了轮询，这正是epoll与kqueue做的。

    3、需要维护一个用来存放大量fd的数据结构，这样会使得用户空间和内核空间在传递该结构时复制开销大

- poll：从本质上跟select没太大区别，但在连接数的维护上 select是用数组来维护，poll是用链表来维护，因此从最大连接数的角度来看，poll是没有限制的
- epoll：没有任何限制，只限制于机器内存的大小

② 如果服务器同时接收的共享连接很多很多，上到一万甚至十万百万之后，select和poll的性能会急剧下降，而epoll 和你同时连接的连接数没有关系，它只跟你当前有多少活跃的连接有关系

③ 消息的传递方式



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


需要添加至 childOption
.option(ChannelOption.RCVBUF_ALLOCATOR, new FixedRecvByteBufAllocator(65535))


```

```
future.channel().closeFuture().sync()	;“防止代码运行完服务就被关闭了，并且这里会一直阻塞着，防止进程结束。

```





## 7.常见问题

## 8.参考资料