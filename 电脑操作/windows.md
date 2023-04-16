# windows 相关命令

## 1.电池

电池使用报告

**powercfg /batteryreport**

2.在VMware虚拟机中创建与Windows的共享文件夹

#### 查看共享文件夹情况

```c
sudo vmware-hgfsclient
```

mkdir /mnt/hgfs

sudo vmhgfs-fuse .host:/ /mnt/code -o allow_other -o uid=1000 -o gid=1000 -o umask=022







sudo vmhgfs-fuse .host:/ /mnt/code  -o allow_other  **-o nonempty** 


windows  cmd

 type  文件名 | more    分页查看

详细参考

https://blog.csdn.net/NRWHF/article/details/127848959