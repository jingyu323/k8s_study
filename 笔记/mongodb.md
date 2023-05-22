# MongoDB相关

## 1.介绍

### 1.1 角色

1. 数据库用户角色：read、readWrite;
2. 数据库管理角色：dbAdmin、dbOwner、userAdmin；
3. 集群管理角色：clusterAdmin、clusterManager、clusterMonitor、hostManager；
4. 备份恢复角色：backup、restore；
5. 所有数据库角色：readAnyDatabase、readWriteAnyDatabase、userAdminAnyDatabase、dbAdminAnyDatabase
6. 超级用户角色：root  
// 这里还有几个角色间接或直接提供了系统超级用户的访问（dbOwner 、userAdmin、userAdminAnyDatabase）
7. 内部角色：__system





## 2.作用

## 3.优点

## 4.实现原理

## 5.安装



```
vim /etc/profile
# 添加mongodb环境变量
export PATH=$PATH:/usr/local/mongodb/bin
# 重新加载配置文件
source /etc/profile
# 检查环境变量
echo $PATH

启动
./mongod -f ../mongodb.conf
```

连接mogodb,使用 mongosh

```
 yum install -y mongodb-mongosh
 
 执行
 mongosh
 连接到不同端口
 mongosh --port 28015
```

设置密码：

```
1.auth改为false
show dbs

test> show dbs
admin   40.00 KiB
config  12.00 KiB
local   72.00 KiB

查看用户
show users


#切换到admin数据库
use admin
#使用db.createUser()函数在admin数据库下创建用户
db.createUser({user:"root",pwd:"root",roles:[{role:"userAdminAnyDatabase",db:"admin"},{role:"readWriteAnyDatabase",db:"admin"}]})


#进行验证，认证通过返回：1
db.auth('root','root')


```





## 6.使用

### 数据类型
###  6.1 用户操作 

```
#切换到admin数据库
use admin
#查看所有用户
db.system.users.find()

#使用db.createUser()函数在admin数据库下创建用户
db.createUser({user:"root",pwd:"root",roles:[{role:"userAdminAnyDatabase",db:"admin"},{role:"readWriteAnyDatabase",db:"admin"}]})

#删除用户 删除时需要切换到该账户所在的数据库
db.system.users.remove({user:"user"})

```



## 7.常见问题

## 参考资料