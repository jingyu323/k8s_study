#  ETCD简介

etcd是由CoreOS团队发的一个分布式一致性的KV存储系统，可用于服务注册发现和共享配置，随着CoreOS和Kubernetes等项目在开源社区日益火热，它们项目中都用到的etcd组件作为一个高可用强一致性的服务发现存储仓库，渐渐为开发人员所关注。在云计算时代，如何让服务快速透明地接入到计算集群中，如何让共享配置信息快速被集群中的所有机器发现，更为重要的是，如何构建这样一套高可用、安全、易于部署以及响应快速的服务集群，已经成为了迫切需要解决的问题。 





## 1.ETCD命令

启动

 ./etcd --config-file= /mnt/app//etcd/conf/etcd.json

查看节点

./etcdctl member list

查看集群状态（Leader节点）：

$ ./etcdctl cluster-health



#### 读写：

1.下面通过给message key设置Hello值示例：

$ ./etcdctl set /message Hello

Hello

$ curl -X PUT http://127.0.0.1:2379/v2/keys/message -d value="Hello"
{"action":"set","node":{"key":"/message","value":"Hello","modifiedIndex":4,"createdIndex":4}}
2.读取message的值：

$ ./etcdctl  get /message
Hello

$ curl http://127.0.0.1:2379/v2/keys/message
{"action":"get","node":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}
3.删除message key：

$ ./etcdctl  rm  /message

$ curl -X DELETE http://127.0.0.1:2379/v2/keys/message
{"action":"delete","node":{"key":"/message","modifiedIndex":10,"createdIndex":9},"prevNode":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}
说明：因为是集群，所以message在其中一个节点创建后，在集群中的任何节点都可以查询到。

4.查看所有key-value：

curl -s http://127.0.0.1:2379/v2/keys/?recursive=true



## 2.ETCD 安装

https://blog.51cto.com/u_12386780/5160982?abTest=51cto



