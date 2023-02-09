# nginx



1.下载地址

http://nginx.org/en/download.html

2.安装

安装编译工具

yum -y install gcc gcc-c++ kernel-devel



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
```









安装遇到问题：

 install the PCRE library into the system



yum -y install pcre-devel



./configure: error: SSL modules require the OpenSSL library.

`yum -y install openssl openssl-devel`