server.3=192.168.99.165:2888:3888
server.2=192.168.99.175:2888:3888
server.1=192.168.99.118:2888:3888

192.168.99.165:2181,192.168.99.175:2181,192.168.99.118:2181

zookeeper.connect=192.168.99.165:2181,192.168.99.175:2181,192.168.99.118:2181
log.dir=/var/log/kafka/logs

启动kafka
cd /usr/local/kafka/bin &&   ./kafka-server-start.sh -daemon ../config/server.properties

./kafka-topics.sh  --bootstrap-server  192.168.99.165:9092,192.168.99.175:9092,192.168.99.118:9092 --create --topic topic01 --partitions 2 --replication-factor 1
./kafka-console-consumer.sh --bootstrap-server  192.168.99.165:9092,192.168.99.175:9092,192.168.99.118:9092 --from-beginning --topic  raintest

 

 
 
 
  
 创建topics
 ./kafka-topics.sh --create --bootstrap-server 192.168.99.165:9092,192.168.99.175:9092,192.168.99.118:9092 --partitions 3 --replication-factor 1 --topic raintest
 
 
 查看topic 列表
 
 ./kafka-topics.sh --list --bootstrap-server 192.168.99.165:9092
  
 
 
 创建topics
 
 ./kafka-topics.sh --bootstrap-server 192.168.99.165:9092 --create --partitions 1 --replication-factor 3 --topic first
 
 启动生产者
 ./kafka-console-producer.sh --bootstrap-server 192.192.168.99.165:9092,192.168.99.175:9092,192.168.99.118:9092 --topic raintest
 
 
 查看指定的主题
 ./kafka-topics.sh --describe --bootstrap-server  192.168.99.175:9092
 ./kafka-topics.sh --describe --bootstrap-server  192.168.99.175:9092  --topic raintest
