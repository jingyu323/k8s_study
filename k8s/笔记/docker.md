# Docker相关



https://bingohuang.gitbooks.io/docker_practice/content/install/mirror.html

## [Docker](https://so.csdn.net/so/search?q=Docker&spm=1001.2101.3001.7020) 网络模型



一个“容器”，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。

一组联合挂载在 /var/lib/docker/aufs/mnt 上的 rootfs，这一部分我们称为“容器镜像”（Container Image），是容器的静态视图；

一个由 Namespace+Cgroups 构成的隔离环境，这一部分我们称为“容器运行时”（Container Runtime），是容器的动态视图。