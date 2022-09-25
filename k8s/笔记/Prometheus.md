# **普罗米修斯 **Prometheus
## 介绍
Prometheus（普罗米修斯）是一个最初在SoundCloud上构建的监控系统。自2012年成为社区开源项目，拥有非常活跃的开发人员和用户社区。为强调开源及独立维护，Prometheus于2016年加入云原生云计算基金会（CNCF），成为继Kubernetes之后的第二个托管项目。

官方网站：https://prometheus.io
项目托管：https://github.com/prometheus
## Prometheus 特点

作为新一代的监控框架，Prometheus 具有以下特点：

1、多维数据模型：由度量名称和键值对标识的时间序列数据

2、PromSQL：一种灵活的查询语言，可以利用多维数据完成复杂的查询

3、不依赖分布式存储，单个服务器节点可直接工作

4、基于HTTP的pull方式采集时间序列数据

5、推送时间序列数据通过PushGateway组件支持

6、通过服务发现或静态配置发现目标

7、多种图形模式及仪表盘支持（grafana）

8、适用于以机器为中心的监控以及高度动态面向服务架构的监控


## Prometheus 组织架构

Prometheus 由多个组件组成，但是其中许多组件是可选的：

Prometheus Server：用于收集指标和存储时间序列数据，并提供查询接口
client Library：客户端库（例如Go，Python，Java等），为需要监控的服务产生相应的/metrics并暴露给Prometheus Server。目前已经有很多的软件原生就支持Prometheus，提供/metrics，可以直接使用。对于像操作系统已经不提供/metrics，可以使用exporter，或者自己开发exporter来提供/metrics服务。
push gateway：主要用于临时性的 jobs。由于这类 jobs 存在时间较短，可能在 Prometheus 来 pull 之前就消失了。对此Jobs定时将指标push到pushgateway，再由Prometheus Server从Pushgateway上pull。
这种方式主要用于服务层面的 metrics：

exporter：用于暴露已有的第三方服务的 metrics 给 Prometheus。
alertmanager：从 Prometheus server 端接收到 alerts 后，会进行去除重复数据，分组，并路由到对收的接受方式，发出报警。常见的接收方式有：电子邮件，pagerduty，OpsGenie, webhook 等。
Web UI：Prometheus内置一个简单的Web控制台，可以查询指标，查看配置信息或者Service Discovery等，实际工作中，查看指标或者创建仪表盘通常使用Grafana，Prometheus作为Grafana的数据源；
注：大多数 Prometheus 组件都是用 Go 编写的，因此很容易构建和部署为静态的二进制文件。

# 参考材料

部署和监控

https://blog.csdn.net/Jerry00713/article/details/113483794