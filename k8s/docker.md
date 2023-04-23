# Docker相关



https://bingohuang.gitbooks.io/docker_practice/content/install/mirror.html

## [Docker](https://so.csdn.net/so/search?q=Docker&spm=1001.2101.3001.7020) 网络模型



一个“容器”，实际上是一个由 Linux Namespace、Linux Cgroups 和 rootfs 三种技术构建出来的进程的隔离环境。

一组联合挂载在 /var/lib/docker/aufs/mnt 上的 rootfs，这一部分我们称为“容器镜像”（Container Image），是容器的静态视图；

一个由 Namespace+Cgroups 构成的隔离环境，这一部分我们称为“容器运行时”（Container Runtime），是容器的动态视图。

## 镜像制作

Docker 为你提供了一种更便捷的方式，叫作 Dockerfile，如下所示。

namespace 隔离机制不需要额外的OS

容器共享主机资源。

获取 Docker 容器的进程号（PID） ：

$ docker inspect --format '{{ .State.Pid }}'  4ddf4638572d
25686

查看namespace 对应文件

ls -l /proc/25686/ns

~~~

# 使用官方提供的Python开发镜像作为基础镜像
FROM python:2.7-slim

# 将工作目录切换为/app
WORKDIR /app

# 将当前目录下的所有内容复制到/app下
ADD . /app

# 使用pip命令安装这个应用所需要的依赖
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# 允许外界访问容器的80端口
EXPOSE 80

# 设置环境变量
ENV NAME World

# 设置容器进程为：python app.py，即：这个Python应用的启动命令
CMD ["python", "app.py"]
~~~

