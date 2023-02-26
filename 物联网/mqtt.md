# MQTT

## 安装

https://www.emqx.io/zh/downloads?os=CentOS


1

配置 EMQX Yum 源

```
curl -s https://assets.emqx.com/scripts/install-emqx-rpm.sh | sudo bash
```

2

安装 EMQX

```
sudo yum install emqx -y
```

3

启动 EMQX

```
sudo systemctl start emqx
```

```
emqx ctl admins
```

The `admins` command can be used to create/update/delete administrative users

登录不了，更新或者设置下密码

emqx ctl admins
admins add <Username> <Password> <Description> # Add dashboard user
admins passwd <Username> <Password>            # Reset dashboard user password
admins del <Username>                          # Delete dashboard user
设置密码
emqx ctl  admins passwd  admin admin@123

http://192.168.99.179:18083/#/connections

MQTT 协议提供了 3 种消息服务质量等级（Quality of Service），保证了在不同的网络环境下消息传递的可靠性。

- QoS 0：消息最多传递一次。

  如果当时客户端不可用，则会丢失该消息。发布者发送一条消息之后，就不再关心它有没有发送到对方，也不设置任何重发机制。

- QoS 1：消息传递至少 1 次。

  包含了简单的重发机制，发布者发送消息之后等待接收者的 ACK，如果没收到 ACK 则重新发送消息。这种模式能保证消息至少能到达一次，但无法保证消息重复。

- QoS 2：消息仅传送一次。

  设计了重发和重复消息发现机制，保证消息到达对方并且严格只到达一次

## MQTT 桌面客户端

[MQTT X](https://mqttx.app/zh) 是 EMQ 开源的一款跨平台 MQTT 5.0 客户端工具，它支持 macOS, Linux, Windows，并且支持 MQTT 消息格式转换。

## IoTDB

IoTDB是针对时间序列数据收集、存储与分析一体化的数据管理引擎。它具有体量轻、性能高、易使用的特点，完美对接Hadoop与Spark生态，适用于工业物联网应用中海量时间序列数据高速写入和复杂分析查询的需求



规则的查询SQL Editor 如下：

```

SELECT
    clientid,
    now_timestamp('millisecond') as now_ts_ms,
    payload.msg as msg
FROM
    "python/mqtt"
```

Egress 是将本地消息送至远程，需要将EMQX收到的消息存入 IoTDB 需要配置这个.

Breaker Payload 内容如下

```
{
 "device": "root.sg.${clientid}",
 "timestamp": ${now_ts_ms},
 "measurements": [
   "msg"
 ],
 "values": [
   ${msg}
 ]
}
```



切换到安装目录

启动单机模式

./start-standalone.sh

启动客户端

./start-cli.sh



(1)创建存储组 set storage group to root.1n

 (2)查看存储组 show storage group

(1)创建时间序列
create timeseries root.1n.wf01.wt01.status with datatype=boolean,encoding=plain
create timeseries root.1n.wf01.wt01.temperature with datatype=float,encoding=rle
(2)查看时间序列
show timeseries  



插入数据时需要指定时间戳和路径后缀名称。

(1)向单个时间序列中插入数据
insert into root.1n.wf01.wt01(timestamp,status) values(100,true);
(2)向多个时间序列中同时插入数据
这些时间序列同属于一个时间戳：
insert into root.1n.wf01.wt01(timestamp,status,temperature) values(200,false,20.71)
