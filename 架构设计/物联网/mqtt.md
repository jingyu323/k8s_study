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