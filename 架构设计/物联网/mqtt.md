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