#/bin/bash

##本脚本需要以root权限执行
###  /home/soft/tomcat/logs/catalina.out 需要修改为服务器安装路径
## 定时任务需要手动添加
# dateext 指定文件以时间结尾
cat > /etc/logrotate.d/tomcat <<EOF
/home/soft/tomcat/logs/catalina.out{
    copytruncate
    daily
    rotate 90
    missingok
    compress
    dateext
    size 100M
}
EOF

# 设置定时执行
# 第一步:crontab -e
# 第二步： 输入a ，开始编辑
# 第三步 输入  30 0 * * * /usr/sbin/logrotate -f /etc/logrotate.d/tomcat
#保存退出

#/usr/sbin/logrotate  /etc/logrotate.conf 手动生成日志轮转文件，查看配置是否生效
#logrotate -d   /etc/logrotate.d/tomcat  测试logrotate 执行状态

#/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf