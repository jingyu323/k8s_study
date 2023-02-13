# nginx



1.下载地址

http://nginx.org/en/download.html

2.安装

安装编译工具

yum -y install gcc gcc-c++ kernel-devel  pcre-devel openssl openssl-devel



./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module  --with-http_ssl_module  #(--with-http_stub_status_module是一个状态统计的模块)



```
./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module  --with-http_ssl_module 
Configuration summary
  + using system PCRE library
  + using system OpenSSL library
  + using system zlib library

  nginx path prefix: "/usr/local/nginx"
  nginx binary file: "/usr/local/nginx/sbin/nginx"
  nginx modules path: "/usr/local/nginx/modules"
  nginx configuration prefix: "/usr/local/nginx/conf"
  nginx configuration file: "/usr/local/nginx/conf/nginx.conf"
  nginx pid file: "/usr/local/nginx/logs/nginx.pid"
  nginx error log file: "/usr/local/nginx/logs/error.log"
  nginx http access log file: "/usr/local/nginx/logs/access.log"
  nginx http client request body temporary files: "client_body_temp"
  nginx http proxy temporary files: "proxy_temp"
  nginx http fastcgi temporary files: "fastcgi_temp"
  nginx http uwsgi temporary files: "uwsgi_temp"
  nginx http scgi temporary files: "scgi_temp"

/usr/local/nginx/conf
切换到 /usr/local/nginx/sbin
cd /usr/local/nginx/sbin
执行 ./nginx 启动nginx
查看安装
ps -aux | grep nginx

关闭
 ./nginx -s stop
 ./nginx -s quit
 重新加载配置文件
 ./nginx -s reload
 
 启动nginx的命令为     /usr/local/nginx/sbin/nginx  
停止nginx的命令为    /usr/local/nginx/sbin/nginx -s stop
重启nginx的命令为    /usr/local/nginx/sbin/nginx -s reload

 
关闭防火墙，开启远程访问
首先需要关闭防火墙：默认端口是80

关闭防火墙
systemctl stop firewalld.service
禁止防火墙启动
systemctl disable firewalld.service

方法一：永久开放80端口

/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save
方法二：临时关闭系统防火墙

# service iptables stop  
 
 
```



配置nginx 为服务

```
vim /usr/lib/systemd/system/nginx.service
chmod +x /usr/lib/systemd/system/nginx.service

[Unit]                                                                                      
Description=nginx - high performance web server              
After=network.target remote-fs.target nss-lookup.target   

[Service]                                                                                 
Type=forking                                                                        
PIDFile=/usr/local/nginx/logs/nginx.pid                               
ExecStartPre=/usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf   
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf           
ExecReload=/usr/local/nginx/sbin/nginx -s reload                                                 
ExecStop=/usr/local/nginx/sbin/nginx -s stop                                                      
PrivateTmp=true                                                                  

[Install]
WantedBy=multi-user.target 

保存之后重载Ststemctl命令

在启动服务之前，需要先重载systemctl命令
systemctl daemon-reload

systemctl status nginx
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
```







安装遇到问题：

1.  install the PCRE library into the system

```
yum -y install pcre-devel
```

2. ./configure: error: SSL modules require the OpenSSL library.

`yum -y install openssl openssl-devel`

3. nginx: [emerg] getpwnam("nginx") failed 

这个是因为我编译安装nginx的时候指定了–user=nginx和–group=nginx

useradd nginx