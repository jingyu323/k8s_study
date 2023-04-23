# Docker相关



https://bingohuang.gitbooks.io/docker_practice/content/install/mirror.html

## [Docker](https://so.csdn.net/so/search?q=Docker&spm=1001.2101.3001.7020) 网络模型



namespace 隔离机制不需要额外的OS

容器共享主机资源。



获取 Docker 容器的进程号（PID） ：

$ docker inspect --format '{{ .State.Pid }}'  4ddf4638572d
25686

查看namespace 对应文件

ls -l /proc/25686/ns