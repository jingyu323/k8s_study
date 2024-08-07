





http://blog.itpub.net/70003733/viewspace-2888774/

# 二进制安装Kubernetes（k8s） v1.24.0 IPv4/IPv6双栈 （三主俩从）

https://blog.csdn.net/qq_33921750/article/details/124958403

# 3台Master+3台Node

https://blog.csdn.net/jasonhe2018/article/details/112749146

# 安装集群的方式：



安装单master集群

1.设置hostname

hostnamectl set-hostname master

hostnamectl set-hostname master1

hostnamectl set-hostname master2

hostnamectl set-hostname node1
hostnamectl set-hostname node2

2.配置 /etc/hosts

 ```
 cat  >  /etc/hosts << EOF
 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
 ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
 192.168.182.128  node1
 192.168.182.130  node2
 192.168.182.131  node3
EOF
 
cat  /etc/hosts
 ```

安装时间同步服务

yum -y install  chrony 

systemctl start chronyd
systemctl enable chronyd

开启ipvs#

在每个节点安装ipset和ipvsadm：
yum -y install ipset ipvsadm
在所有节点执行如下脚本：

```
cat > /etc/sysconfig/modules/ipvs.modules  <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF
```

```
nf_conntrack_ipv4,有的教程跟着做会显示找不到nf_conntrack_ipv4,高版本的内核因为nf_conntrack_ipv4被nf_conntrack替换了,需要注意
```

4.关闭防火墙

- 授权、运行、检查是否加载：

  chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack

  检查是否加载

  lsmod | grep -e ipvs -e nf_conntrack

systemctl stop firewalld
systemctl disable firewalld

yum makecache      //更新yum软件包索引

yum -y install yum-utils



关闭交换
swapoff -a

永久关闭

```
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/g' /etc/selinux/config
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g'  /etc/fstab
sed -ri 's/.*swap.*/#&/' /etc/fstab
```



Swap 是交换分区，如果机器内存不够，会使用 swap 分区，但是 swap 分区的性能较低，k8s 设计的
时候为了能提升性能，默认是不允许使用姜欢分区的。Kubeadm 初始化的时候会检测 swap 是否关闭，如果没关闭，那就初始化失败。如果不想要关闭交换分区，安装 k8s 的时候可以指定--ignorepreflight-errors=Swap 来解决。

###### 关闭所有节点的Slinux/防火墙

```
setenforce 0 \
&& sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config \
&& getenforce
```

## 修改机器内核参数

```
# 所有节点都要执行
modprobe br_netfilter
echo "modprobe br_netfilter" >> /etc/profile
cat >/etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf
```



安装containerd

浏览器打开链接https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
查看containerd.io最新版本（一般是最后一个）

wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.6.6-3.1.el7.x86_64.rpm

yum install  containerd.io-1.6.6-3.1.el7.x86_64.rpm



## 配置containerd

cat > /etc/yum.repos.d/k8s.repo <<EOF
[k8s]
 name=k8s
 baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/
 gpgcheck=0
 enabled=1

[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/ yum/doc/yum-key.gpg
       https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg

EOF



产生config.toml

containerd config default > /etc/containerd/config.toml

替换镜像，不然镜像下载不下来

grep sandbox_image  /etc/containerd/config.toml
sed -i "s#k8s.gcr.io/pause#registry.aliyuncs.com/google_containers/pause#g"       /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml



#### 配置containerd cgroup 驱动程序systemd

kubernets自ｖ1.24.0后，就不再使用docker.shim，替换采用containerd作为容器运行时端点。因此需要安装containerd（在docker的基础下安装），上面安装docker的时候就自动安装了containerd了。这里的docker只是作为客户端而已。容器引擎还是containerd。 

```
    sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml
# 应用所有更改后,重新启动containerd

cat   /etc/containerd/config.toml | grep SystemdCgroup

systemctl restart containerd
```









### 替换阿里云`docker`仓库

删除之前安装的

```
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine \
                  docker-ce

```

安装工具包

```
yum install -y yum-utils \
 device-mapper-persistent-data \
 lvm2
```



 

yum-config-manager \
  --add-repo \
  https:**//**mirrors.tuna.tsinghua.edu.cn**/**docker-ce**/**linux**/**centos**/**docker-ce.repo



### 安装`docker`引擎

yum install --allowerasing docker-ce -y



```
查看是否安装poman
rpm -q podman
podman-1.4.2-5.module_el8.1.0+237+63e26edc.x86_64
删除poman
dnf remove podman

yum erase podman buildah
```



$ systemctl start docker



cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

查看版本，最新版
yum list kubeadm --showduplicates

yum list | grep kube	
指定版本安装

yum install -y  kubelet-1.24.1-0 kubeadm-1.24.1-0 kubectl-1.24.1-0

安装最新版本
yum install kubelet kubeadm kubectl -y



/etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}

cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

重启docker
 systemctl restart docker

systemctl enable docker.service 

systemctl enable kubelet.service 

安装 kubelet kubeadm kubectl 之后再配置crictl ， 安装的同时会安装依赖cri-tools等这样才能配置

crictl config runtime-endpoint unix:///run/containerd/containerd.sock

 原因：未配置endpoints

 crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock

systemctl restart containerd

mkdir -p /etc/docker
echo -e "{
   "registry-mirrors": ["https://r61ch9pn.mirror.aliyuncs.com"]
}" > /etc/docker/daemon.json
cat /etc/docker/daemon.json


cd /etc/yum.repos.d/ && wget -c https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo --no-check-certificate

如果执行失败， 先 kubeadm reset 再次执行    kubeadm init

```
kubeadm init \
--apiserver-advertise-address=192.168.93.82 \
--control-plane-endpoint="192.168.93.82:6443" \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.24.1 \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--ignore-preflight-errors=all \
--v=5 
```

### 添加集群

1.初始化集群

```
kubeadm init --kubernetes-version=v1.24.1  --control-plane-endpoint "192.168.99.142:6443" --apiserver-advertise-address=192.168.99.142  --pod-network-cidr=10.244.0.0/16 --service-cidr 10.1.0.0/16  --image-repository=registry.aliyuncs.com/google_containers  --ignore-preflight-errors=all    --v=5
```

```
kubeadm init \
--apiserver-advertise-address=192.168.99.104 \
--image-repository registry.aliyuncs.com/google_containers \
--control-plane-endpoint=cluster-endpoint \
--kubernetes-version v1.24.1 \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \
--v=5
# –image-repository string：    这个用于指定从什么位置来拉取镜像（1.13版本才有的），默认值是k8s.gcr.io，我们将其指定为国内镜像地址：registry.aliyuncs.com/google_containers
# –kubernetes-version string：  指定kubenets版本号，默认值是stable-1，会导致从https://dl.k8s.io/release/stable-1.txt下载最新的版本号，我们可以将其指定为固定版本（v1.22.1）来跳过网络请求。
# –apiserver-advertise-address  指明用 Master 的哪个 interface 与 Cluster 的其他节点通信。如果 Master 有多个 interface，建议明确指定，如果不指定，kubeadm 会自动选择有默认网关的 interface。这里的ip为master节点ip，记得更换。
# –pod-network-cidr             指定 Pod 网络的范围。Kubernetes 支持多种网络方案，而且不同网络方案对  –pod-network-cidr有自己的要求，这里设置为10.244.0.0/16 是因为我们将使用 flannel 网络方案，必须设置成这个 CIDR。
# --control-plane-endpoint     cluster-endpoint 是映射到该 IP 的自定义 DNS 名称，这里配置hosts映射：192.168.0.113   cluster-endpoint。 这将允许你将 --control-plane-endpoint=cluster-endpoint 传递给 kubeadm init，并将相同的 DNS 名称传递给 kubeadm join。 稍后你可以修改 cluster-endpoint 以指向高可用性方案中的负载均衡器的地址。
```



### 







https://blog.csdn.net/qq_35745940/article/details/125455467

1. 复制证书

```

```



3.  执行添加节点命令

```
kubeadm join 192.168.99.164:6443 --token 2xjsrr.w8eqw2k1yarjoar1 \
	--discovery-token-ca-cert-hash sha256:f3fc6976cce9cdbf24b280549b1a15bb8a0ef68e621f1462a97402cd72d1ec79 \
	--control-plane \   --v=5

```



[ERROR CRI]: container runtime is not running: output: E0712 01:49:47.179156   
 3917 remote_runtime.go:925] "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"

 解决办法
[root@master:~] rm -rf /etc/containerd/config.toml
[root@master:~] systemctl restart containerd



systemctl enable kubelet && systemctl start kubelet 

 systemctl status kubelet

kubeadm join 192.168.99.115:6443 --token 7wv2z1.h70wgh710h1woobs \
> config.toml --discovery-token-ca-cert-hash sha256:44bb791d1f393a96db0d224f247b8b2c4fb18f2db59346c6658b9f19f80aea0a
> accepts at most 1 arg(s), received 2
> To see the stack trace of this error execute with --v=5 or higher

解决办法：重新建立一个空目录，切换到空目录，再执行join命令

netstat -antpl  |grep kubelet

将桥接的 IPv4 的流量传递到 iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

kubectl -n kube-system get cm kubeadm-config -o yaml

添加controlPlaneEndpoint

kubectl -n kube-system edit cm kubeadm-config
大概在这么个位置：

kind: ClusterConfiguration
kubernetesVersion: v1.18.0
controlPlaneEndpoint: 192.168.2.124:6443//添加这个


/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf



cd /etc/sysconfig/network-scripts
ONBOOT=yes
重启网卡
 nmcli c reload



nmcli con reload/nmcli c reload

拉镜像
ctr -n k8s.io images import <your tar file>

查看镜像：
crictl img


journalctl -f -u kubelet.service

kubectl get pod --all-namespaces

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "registry-mirrors": ["https://registry.cn-hangzhou.aliyuncs.com"],
  "storage-driver": "overlay2"
}
EOF




docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6 k8s.gcr.io/pause:3.6

Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcr.io/piled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 74.125.203.82:443: connect: conne
  Warning  FailedCreatePodSandBox  4m51s (x12 over 18m)  kubelet            Failed to create pod sandde = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcriled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 142.250.157.82:443: connect: conn
  Warning  FailedCreatePodSandBox  3m7s (x8 over 16m)    kubelet            Failed to create pod sandde = Unknown desc = failed to get sandbox image "k8s.gcr.io/pause:3.6": failed to pull image "k8s.gcriled to pull and unpack image "k8s.gcr.io/pause:3.6": failed to resolve reference "k8s.gcr.io/pause:3request: Head "https://k8s.gcr.io/v2/pause/manifests/3.6": dial tcp 64.233.189.82:443: 

[root@localhost ~]#mkdir -p /etc/containerd
[root@localhost ~]#containerd config default > /etc/containerd/config.toml
[root@localhost ~]#systemctl daemon-reload
[root@localhost ~]#systemctl start containerd.service
[root@localhost ~]#systemctl enable containerd.service
[root@localhost ~]#runc -v 

sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.7"
执行
systemctl restart containerd



[plugins."io.containerd.grpc.v1.cri".registry]
   [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          		endpoint = ["https://registry-1.docker.io"] //到此为配置文件默认生成，之后为需要添加的内容
       [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.66.4"]
         		endpoint = ["https://192.168.66.4:443"]
   [plugins."io.containerd.grpc.v1.cri".registry.configs]
   		 [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".tls]
          		insecure_skip_verify = true
       	 [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".auth]
          		username = "admin"
          		password = "Harbor12345" 
				
				
				
				
节点init完成	

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

### 添加worknode

kubeadm join 192.168.109.134:6443 --token voyqtd.dn5fr6wm9oomycfk \
​	--discovery-token-ca-cert-hash sha256:1482bd7c078a97b2dd3c4655542a5809821ce474240f5303aa2789fc1da54947 
​

### 添加master

    kubeadm join 192.168.93.72:6443 --token pv895u.zugh48mqxx82ny2o \
     --discovery-token-ca-cert-hash sha256:ec9e6e5c9dd8476b008788ba9430e3b01b91d264d2bb378626f581ab6f943040  \
     --control-plane \
     --v=5 



#如果超过2小时忘记了令牌，可以这样做

$ kubeadm token create --print-join-command #新令牌
	kubeadm token create --print-join-command  

$ kubeadm token create --ttl 0 --print-join-command #永不过期的令牌

kubeadm join 192.168.43.23:6443 --token w2hiyq.429yixajmuvfvcnk --discovery-token-ca-cert-hash sha256:dae5c056947982c4e5463a4e450786ab248e88e91ee45b2a7bf8dba44dad22e2


– 命令解析：第二行：指定apiserver的地址，即master节点的地址
– 第三行：由于master初始化需要下载很多镜像，默认是从k8s.gcr.io拉取镜像，k8s.gcr.io镜像地址国内无法访问，这里指定阿里云镜像仓库地址。
– 第四行：kubernetes版本
– 第五行：service网络
– 第六行：pod网络
– cidr
科普:无类别域间路由(Classless Inter-Domain Routing、CIDR）是一个用于给用户分配IP地址以及在互联网上有效地路由IP数据包的对IP地址进行归类的方法。
第五行建议使用：–service-cidr=10.96.0.0/16
第六行建议使用：–pod-network-cidr=10.244.0.0/16
因为后续安装flannel默认的网段是10.244.0.0
为了导致不必要的麻烦所以建议使用 



删除pod 自动重建
kubectl delete pod  kube-proxy-p6q6w -n kube-system



# 部署网络插件

来看veth-eth映射关系

ip link show 



$ wget https://docs.projectcalico.org/manifests/calico.yaml --no-check-certificate

# 先下载下来，然后修改IPV4的网段，修改这两行：

- name: CALICO_IPV4POOL_CIDR

value: "10.244.0.0/16"

​	搜索Always ，再附近添加


- name: IP_AUTODETECTION_METHOD
  value: "interface=ens.*"  # ens 根据实际网卡开头配置

修改配置之后重新部署

kubectl apply -f calico.yaml

$ kubectl apply -f calico.yaml # 然后部署插件
# 如果calicio状态不是running，则尝试手动拉取镜像

$ cat calico.yaml | grep image

$ grep image calico.yaml

$ docker pull calico/cni:v3.15.1





kubeadm join失败：
1.先初始化
kubeadm reset -f
2.再执行jion


4分支就可以搞定node2 安装
node2    Ready    <none>          4m4s   v1.24.3


ContainerD：

查看镜像
crictl image


kubectl get pods -n kube-system 

#查看集群信息
kubectl cluster-info

#查看集群版本
kubectl version

#查看集群api版本
kubectl api-versions

#查看主机资源使用信息
kubectl top nodes

查看k8s-node1 节点信息
kubectl describe node k8s-node1

#创建namespace 
kubectl create namespace mysapce

#查看namespace信息
kube]# kubectl get namespaces
NAME          STATUS    AGE
default       Active    2d
kube-public   Active    2d
kube-system   Active    2d
mysapce       Active    6s

#删除namespace空间
kubectl delete namespaces mysapce
namespace "mysapce" deleted


查看不同namespace下的Pod

kubectl get pods --all-namespace

kubectl get pod --all-namespaces -o wide
如下，查看所有Pod信息，加上-o wide参数，能看到每个Pod的ip和k8s节点等信息，看的多了

# 配置其他节点能使用kubectl

1. 把主节点/etc/kubernetes/admin.conf 复制到其他节点对应的目录
2. export KUBECONFIG=/etc/kubernetes/admin.conf 目的是设置环境变量
3. kubectl  get node

第二种方法：

1、先进入master节点

cd 到/root.kube文件
cd /root/.kube
复制./kube文件下的config文件
2、到工作节点下

cd 到/root/目录下
mkdir .kube 创建.kube文件
cd .kube

# 添加worknode

## Rook 作为容器持久化存储插件

$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/common.yaml

$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml

$ kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/cluster.yaml

$ kubectl get pods -n rook-ceph-system
NAME                                  READY     STATUS    RESTARTS   AGE
rook-ceph-agent-7cv62                 1/1       Running   0          15s
rook-ceph-operator-78d498c68c-7fj72   1/1       Running   0          44s
rook-discover-2ctcv                   1/1       Running   0          15s

$ kubectl get pods -n rook-ceph
NAME                   READY     STATUS    RESTARTS   AGE
rook-ceph-mon0-kxnzh   1/1       Running   0          13s
rook-ceph-mon1-7dn2t   1/1       Running   0          2s





# k8s多master安装





创建默认的kubeadm-config.yaml文件

```
 kubeadm config print init-defaults  > kubeadm-config.yaml
```

https://www.cnblogs.com/wang-hongwei/p/14623753.html

```
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 1.2.3.4
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: node
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: 1.24.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

修改内容如下：

![](images\kubeamd_config.png)

kubeadm-config.yaml组成部署说明：
InitConfiguration： 用于定义一些初始化配置，如初始化使用的token以及apiserver地址等
ClusterConfiguration：用于定义apiserver、etcd、network、scheduler、controller-manager等master组件相关配置项
KubeletConfiguration：用于定义kubelet组件相关的配置项
KubeProxyConfiguration：用于定义kube-proxy组件相关的配置项
可以看到，在默认的kubeadm-config.yaml文件中只有InitConfiguration、ClusterConfiguration 两部分。我们可以通过如下操作生成另外两部分的示例文件：

##### 生成KubeletConfiguration示例文件 
kubeadm config print init-defaults --component-configs KubeletConfiguration

##### 生成KubeProxyConfiguration示例文件 
kubeadm config print init-defaults --component-configs KubeProxyConfiguration

#使用指定的yaml文件进行初始化安装 自动颁发证书(1.13后支持) 把所有的信息都写入到 kubeadm-init.log中
kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.log
--experimental-upload-certs已被弃用，官方推荐使用--upload-certs替代，官方公告：https://v1-15.docs.kubernetes.io/docs/setup/release/notes/ 

##### 初始化

```
kubeadm init --config=kubeadm-config.yaml --upload-certs   --ignore-preflight-errors=SystemVerification   --v=5 | tee kubeadm-init.log


kubeadm init --config=kubeadm-config.yaml     --ignore-preflight-errors=SystemVerification   --v=5 | tee kubeadm-init.log

 kubeadm join 192.168.99.104:6443 --token peou97.63943msx03iweetx \
	--discovery-token-ca-cert-hash sha256:3bc3b1fa29fb73ddd3f7e1b9e9caa8a3f1b2a99950ab30f508d9ee738b8e4a92 \
	--control-plane --v=5
```

复制证书

```
ssh k8s-master02 "cd /root && mkdir -p /etc/kubernetes/pki/etcd &&mkdir -p ~/.kube/"
scp /etc/kubernetes/pki/ca.crt k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/ca.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.pub k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.crt k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/etcd/ca.crt k8s-master02:/etc/kubernetes/pki/etcd/
scp /etc/kubernetes/pki/etcd/ca.key k8s-master02:/etc/kubernetes/pki/etcd/



```





etc外部配置

```
etcd:
  external:
    # 修改etcd服务器地址
    endpoints:
      - https://172.18.30.195:2379
      - https://172.18.30.196:2379
      - https://172.18.30.197:2379
    #搭建etcd集群时生成的ca证书
    caFile: /etc/etcd/pki/ca.pem
    #搭建etcd集群时生成的客户端证书
    certFile: /etc/etcd/pki/client.pem
    #搭建etcd集群时生成的客户端密钥
    keyFile: /etc/etcd/pki/client-key.pem
```



问题：

```

To see the stack trace of this error execute with --v=5 or higher
[root@master2 ~]#  kubeadm join 192.168.99.142:6443 --token 7fxtp2.jiaodl6y475m99uy --discovery-token-ca-cert-hash sha256:424384ad6a7f517f438423a570a31f837b58a3b4d62feff0d23734f63039cffe --control-plane 
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
error execution phase control-plane-prepare/certs: error creating PKI assets: failed to write or validate certificate "apiserver": certificate apiserver is invalid: x509: certificate is valid for kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local, master, not master2
To see the stack trace of this error execute with --v=5 or higher

解决方法：
证书复制的不对只需要复制如下证书：
scp /etc/kubernetes/pki/ca.crt k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/ca.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/sa.pub k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.crt k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/front-proxy-ca.key k8s-master02:/etc/kubernetes/pki/
scp /etc/kubernetes/pki/etcd/ca.crt k8s-master02:/etc/kubernetes/pki/etcd/
scp /etc/kubernetes/pki/etcd/ca.key k8s-master02:/etc/kubernetes/pki/etcd/

```

问题2：

```
15409 join.go:413] [preflight] found NodeName empty; using OS hostname as NodeName
I0903 04:12:18.403457   15409 join.go:417] [preflight] found advertiseAddress empty; using default interface's IP address as advertiseAddress
I0903 04:12:18.404096   15409 initconfiguration.go:117] detected and using CRI socket: unix:///var/run/containerd/containerd.sock
W0903 04:12:18.404239   15409 common.go:169] WARNING: could not obtain a bind address for the API Server: no default routes found in "/proc/net/route" or "/proc/net/ipv6_route"; using: 0.0.0.0
cannot use "0.0.0.0" as the bind address for the API Server

问题原因：
之前都是动态获取IP的，配置静态IP的时候设置做了网关IP
IPADDR="192.168.93.116"        # 设置的静态IP地址
NETMASK="255.255.255.0"         # 子网掩码
GATEWAY="192.168.93.255"         # 网关地址
DNS1="192.168.93.1"            # DNS服务器
本应该是
GATEWAY="192.168.93.1"         # 网关地址
导致本问题出现

修改之后重启，多了一条路由
0.0.0.0         192.168.93.1    0.0.0.0         UG    100    0        0 ens160
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.93.1    0.0.0.0         UG    100    0        0 ens160
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.93.0    0.0.0.0         255.255.255.0   U     100    0        0 ens160
192.168.122.0   0.0.0.0         255.255.255.0   U     0      0        0 virbr0

估计执行如下命令也是可以的
route add default gw 192.168.93.1

```

问题3：执行 crictl image 命令报错

```java
E0903 09:19:56.672281   48279 remote_image.go:121] "ListImages with filter from image service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.ImageService" filter="&ImageFilter{Image:&ImageSpec{Image:,Annotations:map[string]string{},},}"
FATA[0000] listing images: rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.ImageService 
    
 解决方案：
mv /etc/containerd/config.toml /tmp
    
产生config.toml
containerd config default > /etc/containerd/config.toml
替换镜像，不然镜像下载不下来
grep sandbox_image  /etc/containerd/config.toml
sed -i "s#k8s.gcr.io/pause#registry.aliyuncs.com/google_containers/pause#g"       /etc/containerd/config.toml
grep sandbox_image  /etc/containerd/config.toml
    
```





# 安装配置**calicoctl** 

官方路径，使用命令下载比较慢

https://projectcalico.docs.tigera.io/maintenance/clis/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host



# 安装配置Dashboard

https://github.com/kubernetes/dashboard







curl -o kubernetes-dashboard.yaml  https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml



kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
```

查看服务：

```
kubectl get po,svc -n kubernetes-dashboard
NAME                                TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
service/dashboard-metrics-scraper   ClusterIP   10.1.26.91    <none>        8000/TCP        99s
service/kubernetes-dashboard        NodePort    10.1.240.79   <none>        443:30001/TCP   99s
部署成功


```

kubernetes-dashbaord 安装完成后，kubernetes-dashbaord 默认 service 的类型为 ClusterIP，为了能从外部访问控制面板，需要修改为 NodePort 类型

```
kubectl edit services -n kubernetes-dashboard kubernetes-dashboard
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"k8s-app":"kubernetes-dashboard"},"name":"kubernetes-dashboard","namespace":"kubernetes-dashboard"},"spec":{"ports":[{"port":443,"targetPort":8443}],"selector":{"k8s-app":"kubernetes-dashboard"}}}
  creationTimestamp: "2021-04-11T10:18:54Z"
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  resourceVersion: "33097"
  selfLink: /api/v1/namespaces/kubernetes-dashboard/services/kubernetes-dashboard
  uid: 38jsd1sd-4045-448b-b70f-mia218mda8s
spec:
  clusterIP: 10.102.198.114
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8443
    # 添加固定端口
    nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
  sessionAffinity: None
  # 修改
  type: NodePort
status:
  loadBalancer: {}
```

想要访问dashboard服务，就要有访问权限，创建kubernetes-dashboard管理员角色，以下两种方式创建用户都是可以的

```
vim dashboard-svc-account.yaml
 
# 结果
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dashboard-admin
subjects:
  - kind: ServiceAccount
    name: dashboard-admin
    namespace: kubernetes-dashboard
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io


 
# 执行
kubectl apply -f dashboard-svc-account.yaml
```



 kubectl -n kubernetes-dashboard create token admin-user
error: failed to create token: serviceaccounts "admin-user" not found



```
vim create-admin.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
  
  
 kubectl apply -f  create-admin.yaml
```



 



查看Pod，没有找到相关的Pod，是因为节点之间通信有问题导致

```
kubectl  get pod -A -o wide
NAMESPACE     NAME                                       READY   STATUS    RESTARTS       AGE   IP               NODE     NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-555bc4b957-9q49b   1/1     Running   0              30h   10.244.166.131   node1    <none>           <none>
kube-system   calico-node-cxzq5                          1/1     Running   1 (30h ago)    31h   192.168.99.116   node2    <none>           <none>
kube-system   calico-node-kzbn9                          1/1     Running   0              31h   192.168.99.115   master   <none>           <none>
kube-system   calico-node-tkgmn                          1/1     Running   1 (31h ago)    31h   192.168.99.153   node1    <none>           <none>
kube-system   coredns-74586cf9b6-8n8qx                   1/1     Running   0              30h   10.244.219.65    master   <none>           <none>
kube-system   coredns-74586cf9b6-mbhpz                   1/1     Running   0              30h   10.244.166.130   node1    <none>           <none>
kube-system   etcd-master                                1/1     Running   1              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-apiserver-master                      1/1     Running   1              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-controller-manager-master             1/1     Running   13 (26h ago)   31h   192.168.99.115   master   <none>           <none>
kube-system   kube-proxy-4pq9b                           1/1     Running   1 (30h ago)    31h   192.168.99.116   node2    <none>           <none>
kube-system   kube-proxy-8lcjq                           1/1     Running   0              31h   192.168.99.115   master   <none>           <none>
kube-system   kube-proxy-j6sch                           1/1     Running   1 (31h ago)    31h   192.168.99.153   node1    <none>           <none>
kube-system   kube-scheduler-master                      1/1     Running   12 (26h ago)   31h   192.168.99.115   master   <none>           <none>

```

获取token

```
kubectl -n kubernetes-dashboard create token admin-user

eyJhbGciOiJSUzI1NiIsImtpZCI6IktaMm9Gd1h5azJReGNnbWt3dGhHZUNTaXBqM2VmVW1IcEExaUVKMG5MQ28ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjU4OTM2MTU1LCJpYXQiOjE2NTg5MzI1NTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJhZG1pbi11c2VyIiwidWlkIjoiMGJiODc2MzAtYWRiZS00YzU0LTkwN2YtZjYxM2E4ZjhiODBhIn19LCJuYmYiOjE2NTg5MzI1NTUsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDphZG1pbi11c2VyIn0.ncrjzGsZhPZhqg7zJ4IEH4CkTOhqDcUebzmRl7URLn05t7c_tXDreaBzczeGqYO8pQfUJ3oCsl_7WUdzlBDNNBmZBKI1JU356DNVBG8o7_thqfY-RtUf6BC76vuN3LV_l6-tzk-haxblOd5YnPqdwF_83ky62A3YGFN6eVLgyUQFFFQKWtde5wXXsxatLPeJdICF5U28n6Uu82_aW2tnjwQ3TsWjfunlFxSXJ4uxx2lotfzAGhvU4rSzUCwakFbeqDiLOTkmw374iCdN7d5MVcYWiAd_jcpMcxBLdkzUxlWGSUZv9oHI3IOSK-OdK2fIF1KBXfUQWyCMh4G0GMzgqw
```

删除用户

```
kubectl -n kubernetes-dashboard delete serviceaccount admin-user
kubectl -n kubernetes-dashboard delete clusterrolebinding admin-user
```

kubectl get secret -n kubernetes-dashboard



## 端口映射

可以通过service的nodePort模式，kubectl proxy,kubectl-port，ingress等各种方式进行访问。

本例通过port-forwad将service映射到主机上

```shell
nohup kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:443 --address='172.20.58.83' &
```





查看[命名空间](https://so.csdn.net/so/search?q=命名空间&spm=1001.2101.3001.7020)

```
# kubectl  get ns 
NAME                   STATUS        AGE
default                Active        31h
kube-node-lease        Active        31h
kube-public            Active        31h
kube-system            Active        31h
kubernetes-dashboard   Terminating   3h16m
```

**解决方法**
查看kubesphere-system的namespace描述

```
kubectl get ns  kubernetes-dashboard   -o json > kubernetes-dashboard.json
```

编辑json文件，删除spec字段的内存，因为k8s集群时需要认证的。

vi kubernetes-dashboard.json
将

"spec": {
        "finalizers": [
            "kubernetes"
        ]
    },
更改为：

"spec": {
    
  },



新开一个窗口运行kubectl proxy跑一个API代理在本地的8081端口

```
# kubectl proxy --port=8081
Starting to serve on 127.0.0.1:8081
```

```
curl -k -H "Content-Type:application/json" -X PUT --data-binary @kubernetes-dashboard.json http://127.0.0.1:8081/api/v1/namespaces/kubernetes-dashboard/finalize 
注意：命令中的kubernetes-dashboard就是命名空间。

再次查看命名空间

# kubectl get ns
	NAME              STATUS   AGE
default           Active   31h
kube-node-lease   Active   31h
kube-public       Active   31h
kube-system       Active   31h
```

查看Pod 状态

 kubectl get po,svc -n kubernetes-dashboard

删除服务

kubectl replace --force -f recommended.yaml



查看所有命名空间的Pod

*kubectl get pods -A -o wide*



# k8s删除Terminating状态的命名空间

# 部署Service



service[模式介绍](https://www.cnblogs.com/Ayanamidesu/p/15119636.html)

<img src="images\ipvs_model.png" style="zoom: 50%;" />



#### 开启ipvs模式

ipvs模式和iptables类似，kube-proxy监控pod的变化并创建相应的ipvs规则，ipvs相对iptables转发效率更高。除此以外，ipvs支持更多的LB算法

```
[root@master ~]# kubectl edit cm kube-proxy -n kube-system

找到mode:"" 默认是空的
改为 mode:"ipvs" 

```

 删除kube-proxy的pod并重建

```
[root@master ~]# kubectl delete pod -l k8s-app=kube-proxy -n kube-system
pod "kube-proxy-ck9sg" deleted
pod "kube-proxy-hlpd6" deleted
pod "kube-proxy-jh9gq" deleted
```

```
ipvsadm -Ln
未修改之前
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn


修改以后
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  172.17.0.1:30000 rr
  -> 10.244.104.2:8443            Masq    1      0          0         
TCP  172.17.0.1:31090 rr
  -> 10.244.104.4:80              Masq    1      0          0         
  -> 10.244.166.133:80            Masq    1      0          0         
TCP  172.17.0.1:31761 rr
  -> 10.244.104.6:443             Masq    1      0          0         
TCP  172.17.0.1:31833 rr
  -> 10.244.104.6:80              Masq    1      0          0         
TCP  172.18.0.1:30000 rr
  -> 10.244.104.2:8443            Masq    1      0          0         
TCP  172.18.0.1:31090 rr
  -> 10.244.104.4:80              Masq    1      0          0         
  -> 10.244.166.133:80            Masq    1      0          0         
TCP  172.18.0.1:31761 rr
  -> 10.244.104.6:443             Masq    1      0          0         
TCP  172.18.0.1:31833 rr
  -> 10.244.104.6:80              Masq    1      0          0         
TCP  192.168.93.112:30000 rr
  -> 10.244.104.2:8443            Masq    1      0          0         
TCP  192.168.93.112:31090 rr
  -> 10.244.104.4:80              Masq    1      0          0        

```



#### 创建namespace.[yaml](https://so.csdn.net/so/search?q=yaml&spm=1001.2101.3001.7020)文件

```
 cat  >  /home/rain/namespase.yaml << EOF
apiVersion: v1 #类型为Namespace
kind: Namespace  #类型为Namespace
metadata:
  name: ssx-nginx-ns  #命名空间名称
  labels:
    name: lb-ssx-nginx-ns
EOF
```

然后应用到k8s中  kubectl create -f namespace.yaml

####  创建deployment.yaml文件

```
 
cat  >  /home/rain/deployment.yaml  << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx #为该Deployment设置key为app，value为nginx的标签
  name: ssx-nginx-dm
  namespace: ssx-nginx-ns
spec:
  replicas: 2 #副本数量
  selector: #标签选择器，与上面的标签共同作用
    matchLabels: #选择包含标签app:nginx的资源
      app: nginx
  template: #这是选择或创建的Pod的模板
    metadata: #Pod的元数据
      labels: #Pod的标签，上面的selector即选择包含标签app:nginx的Pod
        app: nginx
    spec: #期望Pod实现的功能（即在pod中部署）
      containers: #生成container，与docker中的container是同一种
      - name: ssx-nginx-c
        image: nginx:latest #使用镜像nginx: 创建container，该container默认80端口可访问
        ports:
        - containerPort: 80  # 开启本容器的80端口可访问
        volumeMounts:  #挂载持久存储卷
        - name: volume #挂载设备的名字，与volumes[*].name 需要对应 
          mountPath: /usr/share/nginx/html #挂载到容器的某个路径下  
      volumes:
      - name: volume #和上面保持一致 这是本地的文件路径，上面是容器内部的路径
        hostPath:
          path: /opt/web/dist #此路径需要实现创建
EOF

```

然后应用到k8s中 kubectl create -f deployment.yaml

#### 创建service.yaml文件

```
cat  >  /home/rain/service.yaml  << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
   app: nginx
  name: ssx-nginx-sv
  namespace: ssx-nginx-ns
spec:
  ports:
  - port: 80 #写nginx本身端口
    name: ssx-nginx-last
    protocol: TCP
    targetPort: 80 # 容器nginx对外开放的端口 上面的dm已经指定了
    nodePort: 31090 #外网访问的端口
  selector:
    app: nginx    #选择包含标签app:nginx的资源
  type: NodePort
EOF
```

然后应用到k8s中

```bash
kubectl create -f ./service.yaml
```



查看创建的service

```
kubectl  get svc -A
NAMESPACE              NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
default                kubernetes                  ClusterIP   10.1.0.1       <none>        443/TCP                  42m   <none>
kube-system            kube-dns                    ClusterIP   10.1.0.10      <none>        53/UDP,53/TCP,9153/TCP   42m   k8s-app=kube-dns
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.1.24.143    <none>        8000/TCP                 39m   k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   kubernetes-dashboard        NodePort    10.1.124.236   <none>        443:30001/TCP            39m   k8s-app=kubernetes-dashboard
ssx-nginx-ns           ssx-nginx-sv                NodePort    10.1.90.83     <none>        80:31090/TCP             22m   app=nginx

```

分别在node1 和node2下创建/opt/web/dist/index.html 

访问：(不要带https)

在master 节点访问 10.1.90.83  因为端口是80 所以可以直接访问返回：node1 或者node2

外网访问：master IP:31090  访问返回node1 或者node2 ，主节点应该是有负载均衡的

node1  IP:31090 只能返回node1

node2  IP:31090 只能返回node2

#### Headless Service “无头服务”

Headless Service不需要分配一个VIP，而是直接以DNS记录的方式解析出被代理Pod的IP地址。

```
域名格式：$(servicename).$(namespace).svc.cluster.local
```

无头服务，不分配ip地址，使用域名

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  ports:
    - name: http
      port: 80
      targetPort: 80
  selector:
      app: nginx
  clusterIP: None
```





# Ingress

1）Ingress-nginx组成
ingress-nginx-controller：根据用户编写的ingress规则（创建的ingress的yaml文件），动态的去更改nginx服务的配置文件，并且reload重载使其生效（是自动化的，通过lua脚本来实现）
ingress资源对象：将Nginx的配置抽象成一个Ingress对象，每添加一个新的Service资源对象只需写一个新的Ingress规则的yaml文件即可（或修改已存在的ingress规则的yaml文件）
2）Ingress-nginx工作流程
Ingress 的实现分为两个部分 Ingress Controller 和 Ingress  

##### 用的是1.3.0  的配置

```
#下载配置 部署文件
$ wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/baremetal/deploy.yaml

# 修改镜像地址 , registry.cn-hangzhou.aliyuncs.com/google_containers
$ sed -i 's@k8s.gcr.io/ingress-nginx/controller:v1.0.0\(.*\)@willdockerhub/ingress-nginx-controller:v1.0.0@' deploy.yaml
$ sed -i 's@k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.0\(.*\)$@hzde0128/kube-webhook-certgen:v1.0@' deploy.yaml
kubectl apply -f deploy.yaml

docker pull aidasi/ingress-nginx-controller:v1.2.1
```

配置ingress策略：

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-nginx-service
spec:
  rules:
  - host: nginx.test.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ssx-nginx-sv
            port:
              number: 80
  ingressClassName: nginx
```

 

查看ingress配置情况

kubectl get ingress

```
NAME                    CLASS   HOSTS            ADDRESS   PORTS   AGE
ingress-nginx-service   nginx   nginx.test.com             80      3m38s
```

测试ingress

````
curl -H "Host:nginx.test.com" http://192.168.93.113:31090/
返回结果：
node2 test in file.....
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node1
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node2 test in file.....
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node1
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node2 test in file.....
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node1
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node2 test in file.....
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node1
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node2 test in file.....
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node1
[root@master rain]# curl -H "Host:nginx.test.com" http://192.168.93.113:31090/ 
node2 test in file.....

````



参考材料：

#### [使用ingress+service机制实现高可用负载均衡](https://www.cnblogs.com/kebibuluan/p/15143837.html)





# istio

https://blog.csdn.net/aa18855953229/article/details/109281007



# Harbor创建私有镜像

https://github.com/goharbor/harbor

**On a Linux host:** docker 17.06.0-ce+ and docker-compose 1.18.0+ .



# 制作镜像



# k8s的更换ip



切换到/etc/kubernetes/manifests， 将etcd.yaml kube-apiserver.yaml里的ip地址替换为新的ip

/etc/kubernetes/manifests # vim etcd.yaml
/etc/kubernetes/manifests # vim kube-apiserver.yaml

替换为新的IP



newIP=192.168.99.110

oldIP=192.168.93.63	



find . -type f | xargs sed -i "s/$oldIP/$newIP/"

查看修改结果

find . -type f | xargs grep $newIP

二，生成新的config文件

cd /etc/kubernetes

/etc/kubernetes# mv admin.conf admin.conf.bak
/etc/kubernetes# kubeadm init phase kubeconfig admin --apiserver-advertise-address $newIP
三，删除老证书，生成新证书

/etc/kubernetes# cd pki
 /etc/kubernetes/pki# mv apiserver.key apiserver.key.bak
/etc/kubernetes/pki# mv apiserver.crt apiserver.crt.bak
 /etc/kubernetes/pki# kubeadm init phase certs apiserver  --apiserver-advertise-address  $newIP
四，重启docker

/etc/kubernetes# cd ..
/etc/kubernetes# service docker restart
/etc/kubernetes# service kubelet restart

五，将配置文件config输出
/etc/kubernetes#kubectl get nodes --kubeconfig=admin.conf # 此时已经是通信成功了

六，将kubeconfig默认配置文件替换为admin.conf，这样就可以直接使用kubectl get nodes

/etc/kubernetes# cp  -f admin.conf  ~/.kube/config

此时kubectl的是能使用了原来创建的Pod IP都还未变。



# docker  使用命令

1. docker network inspect bridge 可以查看网桥的子网网络范围和网关

   docker network inspect bridge

 



# 问题定位：

  查看一下kubelet启动日志  *journalctl -f -u kubelet*

```
 journalctl -f -u kubelet
```



1. #####  *systemctl status  kubelet*  查看状态

   ```
   systemctl status  kubelet
   ```

2. ##### Failed to create pod sandbox: rpc error: code = Unknown desc = [failed to set up sandbox container...

   - 表现状态

   ```
   [root@linux03 ~]# kubectl get pods -n kube-system
   NAME                              READY   STATUS              RESTARTS   AGE
   coredns-7f89b7bc75-jzs26          0/1     ContainerCreating   0          63s
   coredns-7f89b7bc75-qg924          0/1     ContainerCreating   0          63s
   ```

 

- 更改calico.yaml

```
# Cluster type to identify the deployment type
  - name: CLUSTER_TYPE
  value: "k8s,bgp"
# 下方熙增新增
  - name: IP_AUTODETECTION_METHOD
    value: "interface=ens192"
    # ens192为本地网卡名字
```

- kubectl apply -f calico.yaml

  查看正常
  
- 可以查看 /var/log/pods 查看相关Pod日志

4.之前创建kubernetes-dashboard,只有service但是没有pod

 这个问题是因为修改过IP，修改IP之后节点之间不能正常通信，导致任务下发失败，所以就没看到创建的pod，重置节点之后，各个节点通信正常pod也创建正常

```
[root@master rain]# kubectl  get pod -A -o wide
NAMESPACE              NAME                                        READY   STATUS    RESTARTS   AGE    IP               NODE     NOMINATED NODE   READINESS GATES
kube-system            calico-kube-controllers-555bc4b957-7qxs4    1/1     Running   0          90m    10.244.166.129   node1    <none>           <none>
kube-system            calico-node-f6zvj                           1/1     Running   0          90m    192.168.93.63    master   <none>           <none>
kube-system            calico-node-w7skz                           1/1     Running   0          90m    192.168.93.64    node1    <none>           <none>
kube-system            calico-node-xlk4n                           1/1     Running   0          90m    192.168.93.65    node2    <none>           <none>
kube-system            coredns-74586cf9b6-pkx5r                    1/1     Running   0          102m   10.244.219.65    master   <none>           <none>
kube-system            coredns-74586cf9b6-r2j9v                    1/1     Running   0          102m   10.244.219.66    master   <none>           <none>
kube-system            etcd-master                                 1/1     Running   1          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-apiserver-master                       1/1     Running   1          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-controller-manager-master              1/1     Running   30         102m   192.168.93.63    master   <none>           <none>
kube-system            kube-proxy-ktnnt                            1/1     Running   0          102m   192.168.93.63    master   <none>           <none>
kube-system            kube-proxy-l5rgb                            1/1     Running   0          101m   192.168.93.64    node1    <none>           <none>
kube-system            kube-proxy-ldqqj                            1/1     Running   0          101m   192.168.93.65    node2    <none>           <none>
kube-system            kube-scheduler-master                       1/1     Running   29         102m   192.168.93.63    master   <none>           <none>
kubernetes-dashboard   dashboard-metrics-scraper-8c47d4b5d-n8bdf   1/1     Running   0          85m    10.244.104.1     node2    <none>           <none>
kubernetes-dashboard   kubernetes-dashboard-75d8f74d66-ck4sz       1/1     Running   0          86s    10.244.104.3     node2    <none>           <none>
```

大量的 ESTABLISHED

```
 netstat -aptn
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      1297/master         
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      14515/kubelet       
tcp        0      0 127.0.0.1:43432         0.0.0.0:*               LISTEN      14515/kubelet       
tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN      19553/kube-proxy    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1125/sshd           
tcp        0      0 192.168.192.130:22      192.168.192.1:54611     ESTABLISHED 2533/sshd: root@not 
tcp        0      0 192.168.192.130:22      192.168.192.1:57514     ESTABLISHED 40747/sshd: root@no 
tcp        0      0 192.168.192.130:52768   192.168.192.129:6443    ESTABLISHED 14515/kubelet       
tcp        0    116 192.168.192.130:22      192.168.192.1:57513     ESTABLISHED 40654/sshd: root@pt 
tcp        0      0 10.96.0.1:42564         10.96.0.1:443           ESTABLISHED 19998/flanneld      
tcp        0      0 192.168.192.130:52772   192.168.192.129:6443    ESTABLISHED 19553/kube-proxy    
tcp6       0      0 ::1:25                  :::*                    LISTEN      1297/master         
tcp6       0      0 :::10250                :::*                    LISTEN      14515/kubelet       
tcp6       0      0 :::10256                :::*                    LISTEN      19553/kube-proxy    
tcp6       1      0 :::31090                :::*                    LISTEN      19553/kube-proxy    
tcp6       0      0 :::22                   :::*                    LISTEN      1125/sshd           
tcp6      84      0 10.98.148.160:31090     192.168.192.130:45786   CLOSE_WAIT  -    
```

```

Unfortunately, an error has occurred:
	timed out waiting for the condition

This error is likely caused by:
	- The kubelet is not running
	- The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands:
	- 'systemctl status kubelet'
	- 'journalctl -xeu kubelet'

Additionally, a control plane component may have crashed or exited when started by the container runtime.
To troubleshoot, list all containers using your preferred container runtimes CLI.
Here is one example how you may list all running Kubernetes containers by using crictl:
	- 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a | grep kube | grep -v pause'
	Once you have found the failing container, you can inspect its logs with:
	- 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock logs CONTAINERID'
couldn't initialize a Kubernetes cluster


```





## keepalive配置

vim /etc/keepalived/keepalived.conf

```
global_defs { 
 notification_email { 
 acassen@firewall.loc 
 failover@firewall.loc 
 sysadmin@firewall.loc 
 } 
 notification_email_from Alexandre.Cassen@firewall.loc 
 smtp_server 127.0.0.1 
 smtp_connect_timeout 30 
 router_id NGINX_MASTER 
} 
 
vrrp_script check_nginx { 
 script "/etc/keepalived/check_nginx.sh" 
}

vrrp_instance VI_1 { 
 state MASTER 
 interface ens33 # 修改为实际网卡名 
 virtual_router_id 51 # VRRP 路由 ID 实例，每个实例是唯一的 
 priority 100 # 优先级，备服务器设置 90 
 advert_int 1 # 指定 VRRP 心跳包通告间隔时间，默认 1 秒 
 authentication { 
 auth_type PASS 
 auth_pass 1111 
 } 
 # 虚拟 IP 
 virtual_ipaddress { 
 192.168.48.199/24
 } 
 track_script { 
 check_nginx 
 } 
}
#vrrp_script：指定检查 nginx 工作状态脚本（根据 nginx 状态判断是否故障转移） 
#virtual_ipaddress：虚拟 IP（VIP） 
```



编写脚本/etc/keepalived/check_nginx.

```shell
#!/bin/bash 
count=$(ps -ef |grep nginx | grep sbin | egrep -cv "grep|$$") 
if [ "$count" -eq 0 ];then 
 systemctl stop keepalived 
fi 
```

启动nginx
systemctl daemon-reload && yum install nginx-mod-stream -y && systemctl start nginx
启动keepalived
systemctl start keepalived && systemctl enable nginx keepalived && systemctl status keepalived
注意:keepalived无法启动的时候，查看keepalived.conf配置权限
chmod 644 keepalived.conf

## 常用命令：

删除pod并重新创建

kubectl get pod -n kube-system | grep kube-proxy |awk '{system("kubectl delete pod "$1" -n kube-system")}'



kubectl get pod -n kube-system | grep kube-proxy

查看集群情况：kubectl get pod -n kube-system
查看kubelet情况:

```
systemctl status kubelet -l
```

查看kubelet系统日志：journalctl -xefu kubelet
docker ps 查看容器启动情况

systemctl restart networking

##### 强制删除pod(1.5以后)

kubectl  delete pod kubernetes-dashboard-75d8f74d66-bkxt7    -n kubernetes-dashboard  **--force --grace-period=0**

如果在这些命令后 Pod 仍处于 `Unknown` 状态，请使用以下命令从集群中删除 Pod:

```shell
kubectl patch pod <pod> -p '{"metadata":{"finalizers":null}}'
```



## doccker 镜像

ctr ns ls

指定命名空间引入镜像

ctr -n k8s.io  image import kubernetesui.tar



ctr 命令使用
Container命令ctr,crictl的用法
版本：ctr containerd.io 1.4.3
containerd 相比于docker , 多了namespace概念, 每个image和container 都会在各自的namespace下可见, 目前k8s会使用k8s.io 作为命名空间~~

1.1、查看ctr image可用操作
ctr image list, ctr i list , ctr i ls
COPY
1.2、镜像标记tag
ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
注意: 若新镜像reference 已存在, 需要先删除新reference, 或者如下方式强制替换
ctr -n k8s.io i tag --force registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
COPY
1.3、删除镜像
ctr -n k8s.io i rm k8s.gcr.io/pause:3.2
COPY
1.4、拉取镜像
ctr -n k8s.io i pull -k k8s.gcr.io/pause:3.2
COPY
1.5、推送镜像
ctr -n k8s.io i push -k k8s.gcr.io/pause:3.2
COPY
1.6、导出镜像
ctr -n k8s.io i export pause.tar k8s.gcr.io/pause:3.2
COPY
1.7、导入镜像

ctr -n k8s.io i import pause.tar

# 不支持 build,commit 镜像
COPY
1.8、查看容器相关操作
ctr c
COPY
1.9、运行容器

创建容器

 ctr c create docker.io/library/nginx:alpine nginx

创建并运行容器：

ctr run -d docker.io/library/nginx:alpine nginx

–null-io: 将容器内标准输出重定向到/dev/null
–net-host: 主机网络
-d: 当task执行后就进行下一步shell命令,如没有选项,则会等待用户输入,并定向到容器内
–mount 挂载本地目录或文件到容器
–env 环境变量
ctr -n k8s.io run --null-io --net-host -d \
–env PASSWORD="123456"
–mount type=bind,src=/etc,dst=/host-etc,options=rbind:rw
COPY
1.10、容器日志
注意: 容器默认使用fifo创建日志文件, 如果不读取日志文件,会因为fifo容量导致业务运行阻塞

如要创建日志文件,建议如下方式创建:
ctr -n k8s.io run --log-uri file:///var/log/xx.log
COPY

#####  docker inspect 

  ctr c info nginx 

进入容器： ctr task exec --exec-id 0 -t nginx sh

暂停容器： ctr task pause nginx

杀死容器ctr task kill nginx

ctr -n  <命名空间>  import 镜像名称，就可以指定镜像到固定命名空间



二、ctr和docker命令比较
Containerd命令    Docker命令    描述
ctr task ls    docker ps    查看运行容器
ctr image ls      docker images    获取image信息

  ctr i ls 

ctr image pull pause    docker pull pause    pull 应该pause镜像
ctr image push pause-test    docker push pause-test    改名
ctr image import pause.tar    docker load 镜像    导入本地镜像
ctr run -d pause-test pause    docker run -d --name=pause pause-test    运行容器
ctr image tag pause pause-test    docker tag pause pause-test    tag应该pause镜像
三、crictl 命令
3.1、crictl 配置



# 通过在配置文件中设置端点 --config=/etc/crictl.yaml
root@k8s-node-0001:~$ cat /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
COPY
3.2、列出业务容器状态
crictl inspect ee20ec2346fc5
COPY
3.3、查看运行中容器
root@k8s-node-0001:~$ crictl pods
POD ID              CREATED             STATE               NAME                                                     NAMESPACE           ATTEMPT             RUNTIME
b39a7883a433d       10 minutes ago      Ready               canal-server-quark-b477b5d79-ql5l5                       mbz-alpha           0                   (default)
COPY
3.4、打印某个固定pod
root@k8s-node-0001:~$ crictl pods --name canal-server-quark-b477b5d79-ql5l5
POD ID              CREATED             STATE               NAME                                 NAMESPACE           ATTEMPT             RUNTIME
b39a7883a433d       12 minutes ago      Ready               canal-server-quark-b477b5d79-ql5l5   mbz-alpha           0                   (default)
COPY
3.5、打印镜像
root@k8s-node-0001:~$ crictl images
IMAGE                                                          TAG                             IMAGE ID            SIZE
ccr.ccs.tencentyun.com/koderover-public/library-docker         stable-dind                     a6e51fd179fb8       74.6MB
ccr.ccs.tencentyun.com/koderover-public/library-nginx          stable                          588bb5d559c28       51MB
ccr.ccs.tencentyun.com/koderover-public/nsqio-nsq              v1.0.0-compat                   2714222e1b39d       22MB
COPY
3.6、只打印镜像 ID
root@k8s-node-0001:~$ crictl images -q
sha256:a6e51fd179fb849f4ec6faee318101d32830103f5615215716bd686c56afaea1
sha256:588bb5d559c2813834104ecfca000c9192e795ff3af473431497176b9cb5f2c3
sha256:2714222e1b39d8bd6300da72b0805061cabeca3b24def12ffddf47abd47e2263
sha256:be0f9cfd2d7266fdd710744ffd40e4ba6259359fc3bc855341a8c2adad5f5015
COPY
3.7、打印容器清单
root@k8s-node-0001:~$ crictl ps -a
CONTAINER           IMAGE               CREATED             STATE               NAME                     ATTEMPT             POD ID
ee20ec2346fc5       c769a1937d035       13 minutes ago      Running             canal-server             0                   b39a7883a433d
76226ddb736be       cc0c524d64c18       34 minutes ago      Running             mbz-rescue-manager       0                   2f9d48c49e891
e2a19ff0591b4       eb40a52eb437d       About an hour ago   Running             export                   0                   9844b5ea5fdbc
COPY
3.8、打印正在运行的容器清单
root@k8s-node-0001:~$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                   ATTEMPT             POD ID
ee20ec2346fc5       c769a1937d035       13 minutes ago      Running             canal-server           0                   b39a7883a433d
COPY
3.9、容器上执行命令
root@k8s-node-0001:~$ crictl exec -i -t ee20ec2346fc5 ls
app.sh  bin  canal-server  health.sh  node_exporter  node_exporter-0.18.1.linux-arm64
COPY
3.10、获取容器的所有日志
root@k8s-node-0001:~$ crictl logs ee20ec2346fc5
DOCKER_DEPLOY_TYPE=VM
==> INIT /alidata/init/02init-sshd.sh
==> EXIT CODE: 0
==> INIT /alidata/init/fix-hosts.py
COPY
3.11、获取最近的 N 行日志
root@k8s-node-0001:~$ crictl logs --tail=2 ee20ec2346fc5
start canal successful
==> START SUCCESSFUL ...
COPY
3.12、拉取镜像
crictl pull busybox

crictl pods



# 启动一个pod：给个名字mynginx，启动一个镜像nginx
kubectl run mynginx --image=nginx

# 查看default名称空间的Pod
kubectl get pod  # 所有集群范围内，其他node的也可以看到

# 描述
kubectl describe pod 你自己的Pod名字  # 查看默认名称空间pod
kubectl describe  -n [ns] pod 你自己的Pod名字  # 

# 删除
kubectl delete pod Pod名字

# 查看Pod的运行日志
kubectl logs Pod名字

#查找指定的运行中的容器
docker ps|grep mynginx

#删除镜像
kubectl delete -f pytest.yaml

# 每个Pod - k8s都会分配一个ip
kubectl get pod -owide  # 可以查看pod运行的node和ip地址，打印详细信息	

# 使用Pod的ip+pod里面运行容器的端口
curl xxx.xxx.xxx.xxx # 不写端口默认就是80端口

# 进入pod
kubectl exec -it myngix  -- /bin/bash

# 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod

kubectl get namespace  # 获取名称空间
kubectl get pods  # 获取默认名称空间pods
kubectl get pods -A  # 获取全部名称空间pods
kubectl get pods -n [namespace]  # 查看指定名称空间pod
kubectl creat ns hello  # 创建名称空间

也可以通过yaml文件创建ns：
apiVersion: v1
kind: Namespace
metadata:
  name: hello

vi hello.yaml
kubectl apply -f hello.yaml

# 描述
kubectl describe pod 你自己的Pod名字

# 删除
kubectl delete pod Pod名字  # 会删除该名称空间的所有资源
kubectl delete -f hello.yaml  # 用配置文件创建的ns用这种方式删，删的干净

# 查看Pod的运行日志
kubectl logs Pod名字

\# 每个Pod - k8s都会分配一个ip kubectl get pod -owide # 使用Pod的ip+pod里面运行容器的端口 curl 192.168.169.136 # 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod

# 部署策略实践

## 1.滚动跟新：Rolling update, 之前修改yaml后重新apply 就是这种方式

## 2.重新创建 : Recreate，先停止旧的服务 在启动新服务

## 3.蓝绿部署: 利用Service的Selector选择不同版本的服务

## 4.金丝雀部署： 通过Ingress，轮询访问不同的服务。

# 网络相关命令

 ip route list命令查看当前的路由表。

netstat -rn   查看路由表

ip link add veth0 type veth peer name veth1

创建Veth设备对：

ip link add veth0 type veth peer name veth1
创建后查看Veth设备对的信息，使用ip link show命令查看所有网络接口：

ip link show
会生成两个设备，一个是veth0,peer是veth1
两个设备都在同一个命名空间，将Veth看作是有两个头的网线，将另一个头甩给另一个命名空间

ip link set veth1 netns netns1
再次查看命名空间，只剩下一个veth0：

ip link show
在netns1命名空间可以看到veth1设备，符合预期。

现在看到的结果是两个不同的命名空间各自有一个Veth的网线头，各显示为一个Device。（Docker的实现里面，除了将Veth放入容器内）

下一步给两个设备veth0、veth1分配IP地址：

ip netns exec netns1 ip addr add 10.1.1.1/24 dev veth1

ip addr add 10.1.1.2/24 dev veth0
现在两个网络命名空间可以互相通信了：

ping 10.1.1.1

ip netns exec netns1 ping 10.1.1.2

## 网桥相关：

新增一个网桥设备：

brctl addbr xxxxx
为网桥增加网口，在Linux中，一个网口其实就是一个物理网卡，将物理网卡和网桥连接起来。

brctl addif xxxxx ethx
网桥的物理网卡作为一个网口，由于在链路层工作，就不再需要IP地址了，这样上面的IP地址自然失效。

ifconfig ethx 0.0.0.0
给网桥配置一个IP地址：

Ifconfig brxxx xxx.xxx.xxx.xxx



## 路由：

 1.路由表的创建
Linux的路由表至少包括两个表：一个是LOCAL，另一个是MAIN。在LOCAL表中会包含所有的本地设备地址。LOCAL路由表是在配置网络设备地址时自动创建的。LOCAL表用于供Linux协议栈识别本地地址，以及进行本地各个不同网络接口之间的数据转发。

可以通过下面的命令查看LOCAL表的内容：

ip route show table local type local
MAIN表用于各类网络IP地址的转发。MAIN表的建立可以使用静态配置生存，也可以使用动态路由发现协议生成。

2.路由表的查看
使用ip route list命令查看当前的路由表。

ip route list
另一个查看路由表的工具：

netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.128.232.1    0.0.0.0         UG        0 0          0 ens5
10.128.232.0    0.0.0.0         255.255.252.0   U         0 0          0 ens5
标志是U，说明是可达路由，标志是G,说明这个网络接口连接的是网关，否则说明是直连主机。



# k8s使用外部ETCD 

k8s 多master使用ETCD, 有两种方式

##  1.安装非容器话ETCD

##  2.安装容器化ETCD





# Helm 使用总结

https://blog.csdn.net/hjue/article/details/125881911

# Linux 相关操作

(centos7系统）：
开机启动：systemctl enable service_name

开机关闭：systemctl disable service_name

systemctl status firewalld.service

systemctl stop firewalld 



配置静态IP

IPADDR="192.168.93.112"        # 设置的静态IP地址
NETMASK="255.255.255.0"         # 子网掩码
GATEWAY="192.168.93.255"         # 网关地址
DNS1="192.168.93.1"            # DNS服务器



# harbor私有镜像仓库

官网：https://goharbor.io/docs/2.0.0/install-config/run-installer-script/



```
openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
    -x509 -days 365 -out ca.crt


openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout reg.secsmart.com.key \
    -out reg.secsmart.com.csr


openssl x509 -req -days 365 -in reg.secsmart.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out reg.secsmart.com.crt

```

2、解压

3、修改harbor配置文件harbor.yml



```
hostname : reg.secsmart.com

https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /etc/harbor/reg.secsmart.com.crt
  private_key: /etc/harbor/reg.secsmart.com.key
```

在harbor目录中执行

```bash
./prepare

./install
```

浏览器输入：https://192.168.99.104:80

账号：admin

密码：Harbor12345





mkdir -p /etc/docker/certs.d/reg.secsmart.com/



cp  /etc/harbor/reg.secsmart.com.crt /etc/docker/certs.d/reg.secsmart.com

mkdir -p /etc/docker/certs.d/reg.secsmart.com
scp root@192.168.18.229:/root/reg.secsmart.com.crt /etc/docker/certs.d/reg.secsmart.com/



docker login 192.168.99.104:80 -uadmin -pHarbor12345

重启所有容器

docker restart `docker ps -a |awk '{print $1}' `

docker tag nginx:latest 192.168.99.104:80/library/nginx:latest


docker login 192.168.99.104:80


cp  /etc/harbor/reg.secsmart.com.crt /etc/docker/certs.d/reg.secsmart.com/

镜像添加标签

docker tag tomcat:latest 192.168.99.104:80/library/tomcat:latest

docker tag nginx:tomcat 192.168.99.104:80/library/tomcat:latest

docker  push  192.168.99.104:80/library/tomcat:latest



docker tag busybox:latest 192.168.99.104:80/library/busybox:latest


docker login 192.168.99.104:80


cp  /etc/harbor/reg.secsmart.com.crt /etc/docker/certs.d/reg.secsmart.com/

docker tag williamyeh/java8 192.168.99.104:80/library/java:v8


docker  push  192.168.99.104:80/library/java:v8

ca_file = "/etc/containerd/ca.crt" # CA 证书
cert_file = "/etc/containerd/reg.secsmart.com.crt" # harbor 证书
key_file = "/etc/containerd/reg.secsmart.com.key" # harbor 私钥 

镜像搜索

docker search java8 



接下来我们来测试下如何在 containerd 中使用 Harbor 镜像仓库。

首先我们需要将私有镜像仓库配置到 containerd 中去，修改 containerd 的配置文件

```
[plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.k8s.local".tls]
      insecure_skip_verify = true
    [plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.k8s.local".auth]
      username = "admin"
      password = "Harbor12345"
```

在 `plugins."io.containerd.grpc.v1.cri".registry.configs` 下面添加对应 `harbor.k8s.local` 的配置信息，`insecure_skip_verify = true` 表示跳过安全校验，然后通过 `plugins."io.containerd.grpc.v1.cri".registry.configs."harbor.k8s.local".auth` 配置 Harbor 镜像仓库的用户名和密码。

配置完成后重启 containerd：

```text
$ systemctl restart containerd
```

```text
nerdctl login -u admin harbor.k8s.local
```



nerdctl 命令找不到

https://github.com/containerd/nerdctl







##### 遇到问题：

```
unauthorized: unauthorized to access repository: library/nginx, action: push: unauthorized to access repository: library/nginx, action: push
解决办法:未登录，重新登录
```





**received unexpected HTTP status: 502 Bad Gateway**



# 参考材料

##### 一套教程搞定k8s安装到实战

https://blog.csdn.net/guolianggsta/article/details/125275711

