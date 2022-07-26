

hostnamectl set-hostname master
hostnamectl set-hostname node1
hostnamectl set-hostname node2


cat  >  /etc/hosts << EOF

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.109.134 master
192.168.109.135 node1
192.168.109.133 node2

EOF


cat  /etc/hosts



systemctl start chronyd
systemctl enable chronyd

systemctl stop firewalld
systemctl disable firewalld

# 2 关闭iptables服务
systemctl stop iptables
systemctl disable iptables




cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720         
EOF



yum -y install docker-ce --allowerasing


# 设置开机启动
$ systemctl enable docker
# 启动docker
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

yum install -y  kubelet-1.24.3-0 kubeadm-1.24.3-0 kubectl-1.24.3-0


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




mkdir -p /etc/docker
echo -e "{
   "registry-mirrors": ["https://r61ch9pn.mirror.aliyuncs.com"]
}" > /etc/docker/daemon.json
cat /etc/docker/daemon.json


cd /etc/yum.repos.d/ && wget -c https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/docker-ce.repo --no-check-certificate



kubeadm init \
--apiserver-advertise-address=192.168.109.130 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.24.3  \
--service-cidr=10.1.0.0/16 \
--pod-network-cidr=10.244.0.0/16 \



如果执行失败， 先 kubeadm reset 再次执行    kubeadm init


kubeadm init \
  --apiserver-advertise-address=192.168.109.134 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.24.3 \
  --service-cidr=10.1.0.0/16 \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all \
  --v=5 





[ERROR CRI]: container runtime is not running: output: E0712 01:49:47.179156   
 3917 remote_runtime.go:925] "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"


 解决办法
[root@master:~] rm -rf /etc/containerd/config.toml
[root@master:~] systemctl restart containerd



netstat -antpl  |grep kubelet


将桥接的 IPv4 的流量传递到 iptables的链
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF


kubectl -n kube-system get cm kubeadm-config -o yaml


/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf


关闭交换
swapoff -a



cd /etc/sysconfig/network-scripts
ONBOOT=yes
重启网卡
 nmcli c reload

 

 原因：未配置endpoints

 crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock

拉镜像
ctr -n k8s.io images import <your tar file>

查看镜像：
crictl img

tee /etc/sysconfig/kubelet << EOF
KUBELET_EXTRA_ARGS="--pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7"
EOF


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
				
				
				
				
				

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf


​				
kubeadm join 192.168.109.134:6443 --token voyqtd.dn5fr6wm9oomycfk \
​	--discovery-token-ca-cert-hash sha256:1482bd7c078a97b2dd3c4655542a5809821ce474240f5303aa2789fc1da54947 
​	
​	
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

$ wget https://docs.projectcalico.org/manifests/calico.yaml --no-check-certificate

# 先下载下来，然后修改IPV4的网段，修改这两行：

- name: CALICO_IPV4POOL_CIDR

value: "10.244.0.0/16"


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



# Kubernetes 的安全机制 APIServer 认证、授权、准入控制

Kubernetes安全
安全永远是一个重大的话题，特别是云计算平台，更需要设计出一套完善的安全方案，以应对复杂的场景。 Kubernetes主要使用Docker作为应用承载环境，Kubernetes首先设计出一套API和敏感信息处理方案，当然也基于Docker提供容器安全控制。以下是Kubernetes的安全设计原则：

1. 保证容器与其运行的宿主机之间有明确的隔离
2. 限制容器对基础设施或者其它容器造成不良影响的能力
3. 最小特权原则——限定每个组件只被赋予了执行操作所必需的最小特权，由此确保可能产生的损失达到最小
4. 允许系统用户明确区别于管理员
5. 允许赋予管理权限给用户
6. 允许应用能够从公开数据中提取敏感信息（keys, certs, passwords）
 

kubenetes 默认在两个端口提供服务：一个是基于 https 安全端口 6443，另一个是基于 http 的非安全端口 8080。其中非安全端口 8080 限制只能本机访问，即绑定的是 localhost。

**对于安全端口来讲，一个 API 请求到达 6443 端口后，主要经过以下几步处理：**

- **认证**
- **授权**
- **准入控制**
- **实际的 API 请求**

# API Server**的** 认证Authentication

API Server认证 Authentication提供管理三种级别的客户端身份认证方式：

最严格的HTTPS证书认证：基于CA根证书签名的双向数字证书认证方式；
HTTP Token认证：通过一个Token来识别合法用户；
HTTP Base认证：通过用户名+密码的方式认证；
1、HTTPS证书认证：
HTTPS通信双方的务器端向CA机构申请证书，CA机构是可信的第三方机构，它可以是一个公认的权威的企业，也可以是企业自身。企业内部系统一般都使用企业自身的认证系统。CA机构下发根证书、服务端证书及私钥给申请者；
HTTPS通信双方的客户端向CA机构申请证书，CA机构下发根证书、客户端证书及私钥个申请者；
客户端向服务器端发起请求，服务端下发服务端证书给客户端。客户端接收到证书后，通过私钥解密证书，并利用服务器端证书中的公钥认证证书信息比较证书里的消息，例如域名和公钥与服务器刚刚发送的相关消息是否一致，如果一致，则客户端认为这个服务器的合法身份；
客户端发送客户端证书给服务器端，服务端接收到证书后，通过私钥解密证书，获得客户端的证书公钥，并用该公钥认证证书信息，确认客户端是否合法；
客户端通过随机秘钥加密信息，并发送加密后的信息给服务端。服务器端和客户端协商好加密方案后，客户端会产生一个随机的秘钥，客户端通过协商好的加密方案，加密该随机秘钥，并发送该随机秘钥到服务器端。服务器端接收这个秘钥后，双方通信的所有内容都都通过该随机秘钥加密；
 ![im](images\caauthor.png)

上述是双向SSL协议的具体通信过程，这种情况要求服务器和用户双方都有证书。单向认证SSL协议不需要客户拥有CA证书，对应上面的步骤，只需将服务器端验证客户端证书的过程去掉，以及在协商对称密码方案和对称通话秘钥时，服务器端发送给客户端的是没有加过密的（这并不影响SSL过程的安全性）密码方案。



2、HTTP Token原理：
HTTP Token的认证是用一个很长的特殊编码方式的并且难以被模仿的字符串——Token来表明客户身份的一种方式。在通常情况下，Token是一个复杂的字符串，比如我们用私钥签名一个字符串的数据就可以作为一个Token，此外每个Token对应一个用户名，存储在API Server能访问的一个文件中。当客户端发起API调用请求时，需要在HTTP Header里放入Token，这样一来API Server就能够识别合法用户和非法用户了。

3、HTTP Base：
常见的客户端账号登录程序，这种认证方式是把“用户名+冒号+密码”用BASE64算法进行编码后的字符串放在HTTP REQUEST中的Header Authorization域里发送给服务端，服务端收到后进行解码，获取用户名及密码，然后进行用户身份的鉴权过程。
 



## APIServer 授权

授权就是授予不同用户不同的访问权限，APIServer 目前支持以下几种授权策略：

- AlwaysDeny：表示拒绝所有的请求，该配置一般用于测试
- AlwaysAllow：表示接收所有请求，如果集群不需要授权，则可以采取这个策略
- ABAC：基于属性的访问控制，表示基于配置的授权规则去匹配用户请求，判断是否有权限。Beta 版本
- [RBAC](https://www.kubernetes.org.cn/1838.html)：基于角色的访问控制，允许管理员通过 api 动态配置授权策略。Beta 版本

## Admission Control 准入控制

通过了前面的认证和授权之后，还需要经过准入控制处理通过之后，apiserver 才会处理这个请求。Admission Control 有一个准入控制列表，我们可以通过命令行设置选择执行哪几个准入控制器。只有所有的准入控制器都检查通过之后，apiserver 才执行该请求，否则返回拒绝。

当前可配置的准入控制器主要有：

- AlwaysAdmit：允许所有请求
- AlwaysDeny：拒绝所有请求
- AlwaysPullImages：在启动容器之前总是去下载镜像
- ServiceAccount：将 secret 信息挂载到 pod 中，比如 service account token，registry key 等
- ResourceQuota 和 LimitRanger：实现配额控制
- SecurityContextDeny：禁止创建设置了 Security Context 的 pod